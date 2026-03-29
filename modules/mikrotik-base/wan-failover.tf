# =================================================================================================
# WAN Failover - Recursive Default Routes
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_route
# =================================================================================================
locals {
  failover_clients = {
    for k, v in var.dhcp_clients : k => v if v.failover_probe_target != null
  }
}

resource "routeros_ip_route" "wan_failover" {
  for_each = local.failover_clients

  dst_address   = "0.0.0.0/0"
  gateway       = each.value.failover_probe_target
  distance      = coalesce(each.value.failover_distance, each.value.default_route_distance)
  check_gateway = "ping"
  target_scope  = 11
  comment       = "WAN Failover: ${each.value.comment}"
}
