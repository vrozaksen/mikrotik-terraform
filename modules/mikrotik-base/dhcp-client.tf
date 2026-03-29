# =================================================================================================
# DHCP Client
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dhcp_client
# =================================================================================================
locals {
  dhcp_failover_script = {
    for k, v in var.dhcp_clients : k => ":if ($bound=1) do={ /ip/route/remove [find comment=\"probe-${k}\"]; /ip/route/add dst-address=${v.failover_probe_target}/32 gateway=$\"gateway-address\" scope=10 comment=\"probe-${k}\" }"
    if v.failover_probe_target != null
  }
}

resource "routeros_ip_dhcp_client" "clients" {
  for_each = var.dhcp_clients

  interface              = each.value.interface
  comment                = each.value.comment
  add_default_route      = each.value.failover_probe_target != null ? "no" : each.value.add_default_route
  default_route_distance = each.value.default_route_distance
  disabled               = each.value.disabled
  dhcp_options           = each.value.dhcp_options
  use_peer_dns           = each.value.use_peer_dns
  use_peer_ntp           = each.value.use_peer_ntp
  script                 = each.value.failover_probe_target != null ? local.dhcp_failover_script[each.key] : each.value.script
}
