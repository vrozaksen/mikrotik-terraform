# =================================================================================================
# Wireguard Interface
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_wireguard
# =================================================================================================
resource "routeros_interface_wireguard" "wireguard" {
  name        = "wg0"
  comment     = "Wireguard VPN"
  listen_port = "13231"
  mtu         = 1420
}

# =================================================================================================
# Wireguard IP Address
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_address
# =================================================================================================
resource "routeros_ip_address" "wireguard" {
  address   = "10.255.0.1/24"
  interface = routeros_interface_wireguard.wireguard.name
  comment   = "Wireguard VPN"
  network   = "10.255.0.0"
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

# =================================================================================================
# Wireguard — untrusted peers (honeypot)
# =================================================================================================
# A separate interface, port and subnet from wg0 on purpose. The honeypot exists
# to be attacked, so it must not share a tunnel with the phone and laptops, whose
# peers carry allowed-address 10.10.0.0/24. Firewall rules below match on this
# interface, so the isolation holds even if a peer key leaks.
resource "routeros_interface_wireguard" "untrusted" {
  name        = "wg1"
  comment     = "Wireguard — untrusted peers"
  listen_port = "13232"
  mtu         = 1420
}

resource "routeros_ip_address" "untrusted" {
  address   = "10.255.9.1/24"
  interface = routeros_interface_wireguard.untrusted.name
  comment   = "Wireguard — untrusted peers"
  network   = "10.255.9.0"
}

# Public keys are not secrets, so they live in git rather than Infisical.
resource "routeros_interface_wireguard_peer" "honeypot" {
  interface       = routeros_interface_wireguard.untrusted.name
  name            = "honeypot"
  comment         = "Cowrie honeypot (OVH SBG) — logs only, see firewall rule 1750"
  public_key      = "ua436TFdN1X3wBkUcabrfEXRBHMhSpqR16Qj1EnoTEs="
  allowed_address = ["10.255.9.2/32"]
}
