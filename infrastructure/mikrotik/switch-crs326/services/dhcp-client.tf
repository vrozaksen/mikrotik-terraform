# =================================================================================================
# DHCP Client
# =================================================================================================
resource "routeros_ip_dhcp_client" "crs326" {
  interface    = local.vlans.Servers.name
  use_peer_dns = true
  use_peer_ntp = true
}
