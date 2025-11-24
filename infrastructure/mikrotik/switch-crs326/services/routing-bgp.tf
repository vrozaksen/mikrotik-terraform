locals {
  k8s_peers = {
    "k8s-cp-1" = { ip = "10.10.0.21/32" },
    "k8s-cp-2" = { ip = "10.10.0.22/32" },
    "k8s-cp-3" = { ip = "10.10.0.23/32" },
    "k8s-w-1"  = { ip = "10.10.0.31/32" }
  }
  asn_rb5009 = 64513
  asn_crs326 = 64514
  asn_k8s    = 64515
}

# =================================================================================================
# BGP Instance
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/routing_bgp_instance
# =================================================================================================
resource "routeros_routing_bgp_instance" "main" {
  name      = "bgp-instance-1"
  as        = local.asn_crs326
  router_id = "10.10.0.2"
}

# =================================================================================================
# BGP Connection
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/routing_bgp_connection
# =================================================================================================

resource "routeros_routing_bgp_connection" "crs326_to_rb5009" {
  name     = "RB5009_UPLINK"
  as       = local.asn_crs326
  instance = routeros_routing_bgp_instance.main.name
  local {
    role    = "ebgp"
    address = "10.10.0.2"
    ttl     = 2
  }
  remote {
    address = "10.10.0.1"
    as      = local.asn_rb5009
  }
}


# Peerzy CRS326 ↔ k8s-node
resource "routeros_routing_bgp_connection" "k8s_peers_crs326" {
  for_each = local.k8s_peers

  name             = upper(replace(each.key, "-", "_"))
  as               = local.asn_crs326
  instance         = routeros_routing_bgp_instance.main.name
  address_families = "ip"
  nexthop_choice   = "force-self"

  hold_time      = "1m30s"
  keepalive_time = "60s"
  multihop       = true
  local {
    role    = "ebgp"
    address = "10.10.0.2"
    ttl     = 2
  }
  remote {
    address = each.value.ip
    as      = local.asn_k8s
  }
  output { default_originate = "always" }
}
