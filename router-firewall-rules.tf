# =================================================================================================
# NAT Rules
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_nat
# =================================================================================================
resource "routeros_ip_firewall_nat" "wan" {
  provider           = routeros.rb5009
  comment            = "WAN masquerade"
  chain              = "srcnat"
  action             = "masquerade"
  out_interface_list = routeros_interface_list.wan.name
}

resource "routeros_ip_firewall_addr_list" "k8s_services" {
  provider = routeros.rb5009
  list     = "k8s_services"
  comment  = "IPs allocated to K8S Services."
  address  = "10.10.0.20-10.10.0.29"
}
resource "routeros_ip_firewall_addr_list" "iot_internet" {
  provider = routeros.rb5009
  list     = "iot_internet"
  comment  = "IoT IPs allowed to the internet."
  address  = "10.20.0.201-10.20.0.250"
}

# =================================================================================================
# Port Forwarding Rules
# =================================================================================================
# qBit
resource "routeros_ip_firewall_nat" "port_forward_udp_54535" {
  provider     = routeros.rb5009
  comment      = "Port forwarding to 10.10.0.31 UDP 54535"
  chain        = "dstnat"
  action       = "dst-nat"
  protocol     = "udp"
  dst_port     = "54535"
  to_addresses = "10.10.0.31"
  to_ports     = "54535"
}

# Minecraft
resource "routeros_ip_firewall_nat" "port_forward_minecraft" {
  provider     = routeros.rb5009
  comment      = "Port forwarding to Minecraft server 10.10.0.90 UDP 25565"
  chain        = "dstnat"
  action       = "dst-nat"
  protocol     = "udp"
  dst_port     = "25565"
  to_addresses = "10.10.0.90"
  to_ports     = "25565"
}

# Mumble HTTP (TCP 80)
resource "routeros_ip_firewall_nat" "port_forward_mumble_http" {
  provider     = routeros.rb5009
  comment      = "Port forwarding to Mumble HTTP 10.10.0.99 TCP 80"
  chain        = "dstnat"
  action       = "dst-nat"
  protocol     = "tcp"
  dst_port     = "80"
  to_addresses = "10.10.0.99"
  to_ports     = "80"
}

# Mumble (TCP/UDP 64738)
resource "routeros_ip_firewall_nat" "port_forward_mumble_tcp" {
  provider     = routeros.rb5009
  comment      = "Port forwarding to Mumble 10.10.0.99 TCP 64738"
  chain        = "dstnat"
  action       = "dst-nat"
  protocol     = "tcp"
  dst_port     = "64738"
  to_addresses = "10.10.0.99"
  to_ports     = "64738"
}

resource "routeros_ip_firewall_nat" "port_forward_mumble_udp" {
  provider     = routeros.rb5009
  comment      = "Port forwarding to Mumble 10.10.0.99 UDP 64738"
  chain        = "dstnat"
  action       = "dst-nat"
  protocol     = "udp"
  dst_port     = "64738"
  to_addresses = "10.10.0.99"
  to_ports     = "64738"
}

# Neko (TCP 8080)
resource "routeros_ip_firewall_nat" "port_forward_neko_http" {
  provider     = routeros.rb5009
  comment      = "Port forwarding to Neko 10.10.0.98 TCP 8080"
  chain        = "dstnat"
  action       = "dst-nat"
  protocol     = "tcp"
  dst_port     = "8080"
  to_addresses = "10.10.0.98"
  to_ports     = "8080"
}

# Neko WebRTC (TCP/UDP 5100)
resource "routeros_ip_firewall_nat" "port_forward_neko_webrtc_tcp" {
  provider     = routeros.rb5009
  comment      = "Port forwarding to Neko WebRTC 10.10.0.98 TCP 5100"
  chain        = "dstnat"
  action       = "dst-nat"
  protocol     = "tcp"
  dst_port     = "5100"
  to_addresses = "10.10.0.98"
  to_ports     = "5100"
}

resource "routeros_ip_firewall_nat" "port_forward_neko_webrtc_udp" {
  provider     = routeros.rb5009
  comment      = "Port forwarding to Neko WebRTC 10.10.0.98 UDP 5100"
  chain        = "dstnat"
  action       = "dst-nat"
  protocol     = "udp"
  dst_port     = "5100"
  to_addresses = "10.10.0.98"
  to_ports     = "5100"
}

# =================================================================================================
# IoT > Servers
# =================================================================================================
# Emby
resource "routeros_ip_firewall_filter" "allow_iot_to_emby" {
  provider         = routeros.rb5009
  comment          = "Allow IoT to access Emby 10.10.0.32 TCP 8096"
  action           = "accept"
  chain            = "forward"
  protocol         = "tcp"
  dst_port         = "8096"
  dst_address      = "10.10.0.32"
  src_address_list = "iot_internet"
  in_interface     = local.vlans.IoT.name
  out_interface    = local.vlans.Servers.name
  place_before     = routeros_ip_firewall_filter.drop_iot_forward.id
}

# Home Assistant
resource "routeros_ip_firewall_filter" "allow_iot_to_home_assistant" {
  provider         = routeros.rb5009
  comment          = "Allow IoT to access Home Assistant 10.10.0.60 TCP 8123"
  action           = "accept"
  chain            = "forward"
  protocol         = "tcp"
  dst_port         = "8123"
  dst_address      = "10.10.0.60"
  src_address_list = "iot_internet"
  in_interface     = local.vlans.IoT.name
  out_interface    = local.vlans.Servers.name
  place_before     = routeros_ip_firewall_filter.drop_iot_forward.id
}

# =================================================================================================
# Firewall Rules
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter
# =================================================================================================
# Global Rules
resource "routeros_ip_firewall_filter" "fasttrack" {
  provider         = routeros.rb5009
  comment          = "Fasttrack"
  action           = "fasttrack-connection"
  chain            = "forward"
  connection_state = "established,related"
  hw_offload       = true
  place_before     = routeros_ip_firewall_filter.accept_established_related_untracked_forward.id
}
resource "routeros_ip_firewall_filter" "accept_established_related_untracked_forward" {
  provider         = routeros.rb5009
  comment          = "Allow established, related, untracked"
  action           = "accept"
  chain            = "forward"
  connection_state = "established,related,untracked"
  place_before     = routeros_ip_firewall_filter.drop_invalid_forward.id
}
resource "routeros_ip_firewall_filter" "drop_invalid_forward" {
  provider         = routeros.rb5009
  comment          = "Drop invalid"
  action           = "drop"
  chain            = "forward"
  connection_state = "invalid"
  place_before     = routeros_ip_firewall_filter.accept_capsman_loopback.id
  # log              = true
  # log_prefix       = "DROPPED INVALID:"
}
resource "routeros_ip_firewall_filter" "accept_capsman_loopback" {
  provider     = routeros.rb5009
  comment      = "Accept to local loopback for CAPsMAN"
  action       = "accept"
  chain        = "input"
  dst_address  = "127.0.0.1"
  place_before = routeros_ip_firewall_filter.allow_input_icmp.id
}
resource "routeros_ip_firewall_filter" "allow_input_icmp" {
  provider     = routeros.rb5009
  comment      = "Allow input ICMP"
  action       = "accept"
  chain        = "input"
  protocol     = "icmp"
  place_before = routeros_ip_firewall_filter.accept_router_established_related_untracked.id
}
resource "routeros_ip_firewall_filter" "accept_router_established_related_untracked" {
  provider         = routeros.rb5009
  comment          = "Allow established, related, untracked to router"
  action           = "accept"
  chain            = "input"
  connection_state = "established,related,untracked"
  place_before     = routeros_ip_firewall_filter.accept_trusted_input.id
}

# TRUSTED
resource "routeros_ip_firewall_filter" "accept_trusted_input" {
  provider     = routeros.rb5009
  comment      = "Accept all Trusted input"
  action       = "accept"
  chain        = "input"
  in_interface = local.vlans.Trusted.name
  place_before = routeros_ip_firewall_filter.accept_trusted_forward.id
}
resource "routeros_ip_firewall_filter" "accept_trusted_forward" {
  provider     = routeros.rb5009
  comment      = "Accept all Trusted forward"
  action       = "accept"
  chain        = "forward"
  in_interface = local.vlans.Trusted.name
  place_before = routeros_ip_firewall_filter.allow_guest_to_internet.id
}

# GUEST
resource "routeros_ip_firewall_filter" "allow_guest_to_internet" {
  provider           = routeros.rb5009
  comment            = "Allow Guest to Internet"
  action             = "accept"
  chain              = "forward"
  in_interface       = local.vlans.Guest.name
  out_interface_list = routeros_interface_list.wan.name
  place_before       = routeros_ip_firewall_filter.drop_guest_forward.id
}
resource "routeros_ip_firewall_filter" "drop_guest_forward" {
  provider     = routeros.rb5009
  comment      = "Drop all Guest forward"
  action       = "drop"
  chain        = "forward"
  in_interface = local.vlans.Guest.name
  place_before = routeros_ip_firewall_filter.drop_guest_input.id
  # log          = true
  # log_prefix   = "DROPPED GUEST FORWARD:"
}
resource "routeros_ip_firewall_filter" "drop_guest_input" {
  provider     = routeros.rb5009
  comment      = "Drop all Guest input"
  action       = "drop"
  chain        = "input"
  in_interface = local.vlans.Guest.name
  place_before = routeros_ip_firewall_filter.allow_iot_to_internet.id
  # log          = true
  # log_prefix   = "DROPPED GUEST INPUT:"
}

# IOT
resource "routeros_ip_firewall_filter" "allow_iot_to_internet" {
  provider           = routeros.rb5009
  comment            = "Allow SOME IoT to Internet"
  action             = "accept"
  chain              = "forward"
  in_interface       = local.vlans.IoT.name
  out_interface_list = routeros_interface_list.wan.name
  src_address_list   = routeros_ip_firewall_addr_list.iot_internet.list
  place_before       = routeros_ip_firewall_filter.drop_iot_forward.id
}
resource "routeros_ip_firewall_filter" "drop_iot_forward" {
  provider     = routeros.rb5009
  comment      = "Drop all IoT forward"
  action       = "drop"
  chain        = "forward"
  in_interface = local.vlans.IoT.name
  place_before = routeros_ip_firewall_filter.allow_iot_dns_tcp.id
  # log          = true
  # log_prefix   = "DROPPED IoT FORWARD:"
}
resource "routeros_ip_firewall_filter" "allow_iot_dns_tcp" {
  provider     = routeros.rb5009
  comment      = "Allow local DNS (TCP) for IoT"
  action       = "accept"
  chain        = "input"
  protocol     = "tcp"
  in_interface = local.vlans.IoT.name
  place_before = routeros_ip_firewall_filter.allow_iot_dns_udp.id
}
resource "routeros_ip_firewall_filter" "allow_iot_dns_udp" {
  provider     = routeros.rb5009
  comment      = "Allow local DNS (UDP) for IoT"
  action       = "accept"
  chain        = "input"
  protocol     = "udp"
  in_interface = local.vlans.IoT.name
  place_before = routeros_ip_firewall_filter.drop_iot_input.id
}
resource "routeros_ip_firewall_filter" "drop_iot_input" {
  provider     = routeros.rb5009
  comment      = "Drop all IoT input"
  action       = "drop"
  chain        = "input"
  in_interface = local.vlans.IoT.name
  place_before = routeros_ip_firewall_filter.allow_servers_to_internet.id
  # log          = true
  # log_prefix   = "DROPPED IoT INPUT:"
}

# SERVERS
resource "routeros_ip_firewall_filter" "allow_servers_to_internet" {
  provider           = routeros.rb5009
  comment            = "Allow Servers to Internet"
  action             = "accept"
  chain              = "forward"
  in_interface       = local.vlans.Servers.name
  out_interface_list = routeros_interface_list.wan.name
  place_before       = routeros_ip_firewall_filter.drop_servers_forward.id
}
resource "routeros_ip_firewall_filter" "drop_servers_forward" {
  provider     = routeros.rb5009
  comment      = "Drop all Servers forward"
  action       = "drop"
  chain        = "forward"
  in_interface = local.vlans.Servers.name
  place_before = routeros_ip_firewall_filter.allow_servers_dns_tcp.id
  # log          = true
  # log_prefix   = "DROPPED Servers FORWARD:"
}
resource "routeros_ip_firewall_filter" "allow_servers_dns_tcp" {
  provider     = routeros.rb5009
  comment      = "Allow local DNS (TCP) for Servers"
  action       = "accept"
  chain        = "input"
  protocol     = "tcp"
  in_interface = local.vlans.Servers.name
  place_before = routeros_ip_firewall_filter.allow_servers_dns_udp.id
}
resource "routeros_ip_firewall_filter" "allow_servers_dns_udp" {
  provider     = routeros.rb5009
  comment      = "Allow local DNS (UDP) for Servers"
  action       = "accept"
  chain        = "input"
  protocol     = "udp"
  in_interface = local.vlans.Servers.name
  place_before = routeros_ip_firewall_filter.drop_servers_input.id
}
resource "routeros_ip_firewall_filter" "drop_servers_input" {
  provider     = routeros.rb5009
  comment      = "Drop all Servers input"
  action       = "drop"
  chain        = "input"
  in_interface = local.vlans.Servers.name
  place_before = routeros_ip_firewall_filter.drop_all_forward.id
  # log          = true
  # log_prefix   = "DROPPED Servers INPUT:"
}

# DEFAULT DENY
resource "routeros_ip_firewall_filter" "drop_all_forward" {
  provider     = routeros.rb5009
  comment      = "Drop all forward not from Trusted"
  action       = "drop"
  chain        = "forward"
  in_interface = "!${local.vlans.Trusted.name}"
  place_before = routeros_ip_firewall_filter.drop_all_input.id
}
resource "routeros_ip_firewall_filter" "drop_all_input" {
  provider     = routeros.rb5009
  comment      = "Drop all input not from Trusted"
  action       = "drop"
  chain        = "input"
  in_interface = "!${local.vlans.Trusted.name}"
}
