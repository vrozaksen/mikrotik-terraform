locals {
  k8s_peers = {
    "k8s-node-1" = { ip = "10.10.0.21/32" },
    "k8s-node-2" = { ip = "10.10.0.22/32" },
    "k8s-node-3" = { ip = "10.10.0.23/32" }
  }
}

# =================================================================================================
# BGP Connection
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/routing_bgp_connection
# =================================================================================================

resource "routeros_routing_bgp_connection" "k8s_peers" {
  provider = routeros.rb5009
  for_each = local.k8s_peers

  name             = upper(replace(each.key, "-", "_"))
  as               = "64513"
  address_families = "ip"
  nexthop_choice   = "force-self"

  hold_time      = "1m30s"
  keepalive_time = "60s"

  local { role = "ebgp" }
  remote { address = each.value.ip }
  output { default_originate = "always" }
}
