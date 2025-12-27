# =================================================================================================
# DHCP Client
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dhcp_client
# =================================================================================================
resource "routeros_ip_dhcp_client" "clients" {
  for_each = var.dhcp_clients

  interface              = each.value.interface
  comment                = each.value.comment
  add_default_route      = each.value.add_default_route
  default_route_distance = each.value.default_route_distance
  disabled               = each.value.disabled
  dhcp_options           = each.value.dhcp_options
  use_peer_dns           = each.value.use_peer_dns
  use_peer_ntp           = each.value.use_peer_ntp
}
