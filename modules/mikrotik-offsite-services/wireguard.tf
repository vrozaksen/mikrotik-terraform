# =================================================================================================
# WireGuard Interface
# =================================================================================================
resource "routeros_interface_wireguard" "wireguard" {
  name        = "wg0"
  comment     = "WireGuard to main site"
  listen_port = 13231
  mtu         = 1420
}

resource "routeros_ip_address" "wireguard" {
  address   = var.wireguard_address
  interface = routeros_interface_wireguard.wireguard.name
  comment   = "WireGuard VPN"
}

# =================================================================================================
# WireGuard Routes to remote networks
# =================================================================================================
resource "routeros_ip_route" "wireguard_routes" {
  for_each = var.wireguard_remote_networks

  dst_address = each.value
  gateway     = routeros_interface_wireguard.wireguard.name
  comment     = "WireGuard route to ${each.key}"
}
