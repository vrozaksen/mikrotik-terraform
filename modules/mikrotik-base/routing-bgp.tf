# =================================================================================================
# BGP Instance
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/routing_bgp_instance
# =================================================================================================
resource "routeros_routing_bgp_instance" "main" {
  count = var.bgp_enabled ? 1 : 0

  name      = var.bgp_instance.name
  as        = var.bgp_instance.as
  router_id = var.bgp_instance.router_id
}

# =================================================================================================
# BGP Peer Connections (to other routers/switches)
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/routing_bgp_connection
# =================================================================================================
resource "routeros_routing_bgp_connection" "peers" {
  for_each = var.bgp_enabled ? var.bgp_peer_connections : {}

  name             = each.value.name
  as               = var.bgp_instance.as
  instance         = routeros_routing_bgp_instance.main[0].name
  address_families = each.value.address_families
  multihop         = each.value.multihop

  local {
    role    = "ebgp"
    address = each.value.local_address
    ttl     = 2
  }

  remote {
    address = each.value.remote_address
    as      = each.value.remote_as
  }
}

# =================================================================================================
# BGP K8s Peer Connections
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/routing_bgp_connection
# =================================================================================================
resource "routeros_routing_bgp_connection" "k8s_peers" {
  for_each = var.bgp_enabled && var.bgp_k8s_asn != null ? var.bgp_k8s_peers : {}

  name             = upper(replace(each.key, "-", "_"))
  as               = var.bgp_instance.as
  instance         = routeros_routing_bgp_instance.main[0].name
  address_families = "ip"
  nexthop_choice   = "force-self"

  hold_time      = "1m30s"
  keepalive_time = "60s"
  multihop       = true

  local {
    role    = "ebgp"
    address = var.bgp_instance.router_id
    ttl     = 2
  }

  remote {
    address = each.value.ip
    as      = var.bgp_k8s_asn
  }

  output {
    default_originate = "always"
  }
}
