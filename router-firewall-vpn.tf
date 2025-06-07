# WIREGUARD
resource "routeros_ip_firewall_filter" "allow_wireguard_connections" {
  provider     = routeros.rb5009
  comment      = "Allow Wireguard Incoming Connections"
  action       = "accept"
  chain        = "input"
  protocol     = "udp"
  dst_port     = routeros_interface_wireguard.wireguard.listen_port
  place_before = routeros_ip_firewall_filter.allow_wireguard_to_internet.id
}

resource "routeros_ip_firewall_filter" "allow_wireguard_to_internet" {
  provider           = routeros.rb5009
  comment            = "Allow Wireguard to Internet"
  action             = "accept"
  chain              = "forward"
  in_interface       = routeros_interface_wireguard.wireguard.name
  out_interface_list = routeros_interface_list.wan.name
  place_before       = routeros_ip_firewall_filter.allow_wireguard_to_trusted.id
}
resource "routeros_ip_firewall_filter" "allow_wireguard_to_trusted" {
  provider      = routeros.rb5009
  comment       = "Allow Wireguard to Trusted"
  action        = "accept"
  chain         = "forward"
  in_interface  = routeros_interface_wireguard.wireguard.name
  out_interface = local.vlans.Trusted.name
  place_before  = routeros_ip_firewall_filter.allow_wireguard_to_servers.id
}
resource "routeros_ip_firewall_filter" "allow_wireguard_to_servers" {
  provider         = routeros.rb5009
  comment          = "Allow Wireguard to Servers"
  action           = "accept"
  chain            = "forward"
  in_interface     = routeros_interface_wireguard.wireguard.name
  out_interface    = local.vlans.Servers.name
  #dst_address_list = routeros_ip_firewall_addr_list.k8s_services.list
  place_before     = routeros_ip_firewall_filter.drop_wireguard_forward.id
}
resource "routeros_ip_firewall_filter" "drop_wireguard_forward" {
  provider     = routeros.rb5009
  comment      = "Drop all Wireguard forward"
  action       = "drop"
  chain        = "forward"
  in_interface = routeros_interface_wireguard.wireguard.name
  place_before = routeros_ip_firewall_filter.allow_wireguard_dns_tcp.id
}
resource "routeros_ip_firewall_filter" "allow_wireguard_dns_tcp" {
  provider     = routeros.rb5009
  comment      = "Allow local DNS (TCP) for Wireguard"
  action       = "accept"
  chain        = "input"
  protocol     = "tcp"
  in_interface = routeros_interface_wireguard.wireguard.name
  place_before = routeros_ip_firewall_filter.allow_wireguard_dns_udp.id
}
resource "routeros_ip_firewall_filter" "allow_wireguard_dns_udp" {
  provider     = routeros.rb5009
  comment      = "Allow local DNS (UDP) for Wireguard"
  action       = "accept"
  chain        = "input"
  protocol     = "udp"
  in_interface = routeros_interface_wireguard.wireguard.name
  place_before = routeros_ip_firewall_filter.drop_wireguard_input.id
}
resource "routeros_ip_firewall_filter" "drop_wireguard_input" {
  provider     = routeros.rb5009
  comment      = "Drop all Wireguard input"
  action       = "drop"
  chain        = "input"
  in_interface = routeros_interface_wireguard.wireguard.name
  place_before = routeros_ip_firewall_filter.accept_post_nat.id
}
