# =================================================================================================
# DHCP Client
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dhcp_client
# =================================================================================================
resource "routeros_ip_dhcp_client" "vectra" {
  interface              = "ether1"
  add_default_route      = "yes"
  comment                = "Vectra DHCP Client"
  default_route_distance = 1
  disabled               = false
  dhcp_options           = "hostname,clientid"
  use_peer_dns           = false
  use_peer_ntp           = false
}
