# =================================================================================================
# Shared Configuration
# =================================================================================================
locals {
  # Allowed ports structure: ["80", "64738-64739"]
  services = {
    qBittorrent = {
      ip  = "10.10.0.41",
      udp = ["54535"],
      tcp = ["54535"]
    },
    Minecraft = {
      ip  = "10.10.0.60",
      udp = ["25565"]
    },
    Factorio-Fun-Mode = {
      ip  = "10.10.0.61",
      udp = ["34197"]
    },
    Mumble = {
      ip  = "10.10.0.50",
      tcp = ["64738"],
      udp = ["64738"]
    },
    Gitea = {
      ip  = "10.10.0.51",
      tcp = ["2222"],
      udp = ["2222"]
    },
    Mirotalk = {
      ip  = "10.10.0.52",
      tcp = ["40000-40010"],
      udp = ["40000-40010"]
    },
    Sunshine-Firend = {
      ip  = "10.110.0.100",
      udp = ["61337"]
    },
    Local-Friend = {
      ip  = "10.100.0.103",
      udp = ["62237"]
    }
  }

  # Generate all forwarding rules with formatted comments
  forwarding_rules = merge(
    flatten([
      for service_name, config in local.services : [
        for proto in ["tcp", "udp"] : [
          for port_spec in try(config[proto], []) : {
            "${service_name}-${proto}-${port_spec}" = {
              ip          = config.ip,
              protocol    = proto,
              port        = port_spec,
              description = "${service_name} (${upper(proto)} ${port_spec})"
            }
          }
        ]
      ]
    ])...
  )
}

# =================================================================================================
# NAT Rules
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_nat
# =================================================================================================
resource "routeros_ip_firewall_nat" "wan_masquerade" {
  comment            = "WAN masquerade"
  chain              = "srcnat"
  action             = "masquerade"
  out_interface_list = routeros_interface_list.wan.name
}

resource "routeros_ip_firewall_nat" "service_port_forward" {
  for_each          = local.forwarding_rules
  comment           = "PF: ${each.value.description} → ${each.value.ip}"
  chain             = "dstnat"
  action            = "dst-nat"
  protocol          = each.value.protocol
  dst_port          = each.value.port
  to_addresses      = each.value.ip
  to_ports          = each.value.port
  in_interface_list = routeros_interface_list.wan.name
}

# =================================================================================================
# Firewall Rules (For Services)
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter
# =================================================================================================
resource "routeros_ip_firewall_filter" "accept_post_nat" {
  comment              = "Base: Accept all forwarded traffic after NAT processing"
  action               = "accept"
  chain                = "forward"
  connection_nat_state = "dstnat"
  place_before         = routeros_ip_firewall_filter.accept_trusted_devices_input.id
}

# =================================================================================================
# Base Firewall Rules (Global)
# =================================================================================================
resource "routeros_ip_firewall_filter" "fasttrack" {
  comment          = "Base: Fasttrack established/related connections"
  action           = "fasttrack-connection"
  chain            = "forward"
  connection_state = "established,related"
  hw_offload       = true
  place_before     = routeros_ip_firewall_filter.accept_established_related_untracked_forward.id
}
resource "routeros_ip_firewall_filter" "accept_established_related_untracked_forward" {
  comment          = "Base: Allow established, related, untracked (forward)"
  action           = "accept"
  chain            = "forward"
  connection_state = "established,related,untracked"
  place_before     = routeros_ip_firewall_filter.drop_invalid_forward.id
}
resource "routeros_ip_firewall_filter" "drop_invalid_forward" {
  comment          = "Base: Drop invalid connections (forward)"
  action           = "drop"
  chain            = "forward"
  connection_state = "invalid"
  place_before     = routeros_ip_firewall_filter.drop_bogons_forward.id
  # log              = true
  # log_prefix       = "DROPPED INVALID:"
}
resource "routeros_ip_firewall_filter" "drop_bogons_forward" {
  comment          = "Base: Drop traffic to bogon networks"
  action           = "drop"
  chain            = "forward"
  dst_address_list = "Bogons"
  place_before     = routeros_ip_firewall_filter.accept_capsman_loopback.id
}
resource "routeros_ip_firewall_filter" "accept_capsman_loopback" {
  comment      = "Base: Accept to local loopback for CAPsMAN"
  action       = "accept"
  chain        = "input"
  dst_address  = "127.0.0.1"
  place_before = routeros_ip_firewall_filter.allow_input_icmp.id
}
resource "routeros_ip_firewall_filter" "allow_input_icmp" {
  comment      = "Base: Allow input ICMP"
  action       = "accept"
  chain        = "input"
  protocol     = "icmp"
  place_before = routeros_ip_firewall_filter.accept_router_established_related_untracked.id
}
resource "routeros_ip_firewall_filter" "accept_router_established_related_untracked" {
  comment          = "Base: Allow established, related, untracked to router"
  action           = "accept"
  chain            = "input"
  connection_state = "established,related,untracked"
  place_before     = routeros_ip_firewall_filter.accept_post_nat.id
}
