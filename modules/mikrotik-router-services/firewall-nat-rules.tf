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
    Mumble = {
      ip  = "10.10.0.50",
      tcp = ["64738"],
      udp = ["64738"]
    },
    Forgejo = {
      ip  = "10.10.0.51",
      tcp = ["2222"],
      udp = ["2222"]
    },
    TS6 = {
      ip  = "10.10.0.52",
      tcp = ["40000-40010"],
      udp = ["40000-40010"]
    },
    Coturn = {
      ip  = "10.10.0.53",
      udp = ["3478-3479", "5349", "49152-49252"],  # TURN + TURNS (TLS) + media relay
      tcp = ["3478-3479", "5349", "49152-49252"]   # TURN + TURNS (TLS) + media relay
    },
    Minecraft = {
      ip  = "10.10.0.60",
      udp = ["25565"]
    },
    Factorio = {
      ip  = "10.10.0.61",
      udp = ["34197"]
    },
    RimWorld = {
      ip  = "10.10.0.62",
      udp = ["25555"],
      tcp = ["25555"]
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
resource "routeros_ip_firewall_nat" "wan" {
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
