locals {
  filter_rules = {
    # =========================================================================
    # GLOBAL RULES - Forward Chain
    # =========================================================================
    "fasttrack" = {
      chain            = "forward"
      action           = "fasttrack-connection"
      connection_state = "established,related"
      hw_offload       = true
      order            = 100
    }
    "accept-established-related-untracked-forward" = {
      chain            = "forward"
      action           = "accept"
      connection_state = "established,related,untracked"
      order            = 110
    }
    "asymmetric-routing-fix-trusted-servers" = {
      chain            = "forward"
      action           = "accept"
      connection_state = "invalid"
      in_interface     = var.vlans.Trusted.name
      out_interface    = var.vlans.Servers.name
      order            = 120
    }
    "asymmetric-routing-fix-servers-trusted" = {
      chain            = "forward"
      action           = "accept"
      connection_state = "invalid"
      in_interface     = var.vlans.Servers.name
      out_interface    = var.vlans.Trusted.name
      order            = 121
    }
    "drop-invalid-forward" = {
      chain            = "forward"
      action           = "drop"
      connection_state = "invalid"
      order            = 198
      # log              = true
      # log_prefix       = "DROPPED INVALID:"
    }

    # =========================================================================
    # GLOBAL RULES - Input Chain
    # =========================================================================
    "accept-capsman-loopback" = {
      chain       = "input"
      action      = "accept"
      dst_address = "127.0.0.1"
      order       = 200
    }
    "allow-input-icmp" = {
      chain    = "input"
      action   = "accept"
      protocol = "icmp"
      order    = 210
    }
    "accept-router-established-related-untracked" = {
      chain            = "input"
      action           = "accept"
      connection_state = "established,related,untracked"
      order            = 220
    }
    "accept-post-nat" = {
      chain                = "forward"
      action               = "accept"
      connection_nat_state = "dstnat"
      order                = 230
    }

    # =========================================================================
    # GLOBAL SERVICE ACCESS (using auto-generated address lists)
    # =========================================================================
    "allow-dns-udp-global" = {
      chain            = "input"
      action           = "accept"
      protocol         = "udp"
      dst_port         = "53"
      src_address_list = "ag_dns_access"
      order            = 300
    }
    "allow-ntp-global" = {
      chain            = "input"
      action           = "accept"
      protocol         = "udp"
      dst_port         = "123"
      src_address_list = "ag_ntp_access"
      order            = 310
    }
    "allow-wan-access-global" = {
      chain              = "forward"
      action             = "accept"
      src_address_list   = "ag_wan_access"
      out_interface_list = routeros_interface_list.wan.name
      order              = 320
    }

    # =========================================================================
    # WIREGUARD ZONE (VPN Access)
    # =========================================================================
    "allow-wireguard-connections" = {
      chain    = "input"
      action   = "accept"
      protocol = "udp"
      dst_port = routeros_interface_wireguard.wireguard.listen_port
      order    = 1000
    }
    "allow-wireguard-to-internet" = {
      chain              = "forward"
      action             = "accept"
      in_interface       = routeros_interface_wireguard.wireguard.name
      out_interface_list = routeros_interface_list.wan.name
      order              = 1010
    }
    "allow-wireguard-to-trusted" = {
      chain         = "forward"
      action        = "accept"
      in_interface  = routeros_interface_wireguard.wireguard.name
      out_interface = var.vlans.Trusted.name
      order         = 1020
    }
    "allow-wireguard-to-servers" = {
      chain         = "forward"
      action        = "accept"
      in_interface  = routeros_interface_wireguard.wireguard.name
      out_interface = var.vlans.Servers.name
      order         = 1030
    }
    "allow-wireguard-dns-tcp" = {
      chain        = "input"
      action       = "accept"
      protocol     = "tcp"
      dst_port     = "53"
      in_interface = routeros_interface_wireguard.wireguard.name
      order        = 1040
    }
    "allow-wireguard-dns-udp" = {
      chain        = "input"
      action       = "accept"
      protocol     = "udp"
      dst_port     = "53"
      in_interface = routeros_interface_wireguard.wireguard.name
      order        = 1050
    }

    # =========================================================================
    # TRUSTED ZONE (with Trusted Devices special access via address list)
    # =========================================================================
    "accept-trusted-devices-input" = {
      chain            = "input"
      action           = "accept"
      in_interface     = var.vlans.Trusted.name
      src_address_list = "st_trusted_devices"
      order            = 1100
    }
    "accept-trusted-devices-forward" = {
      chain            = "forward"
      action           = "accept"
      in_interface     = var.vlans.Trusted.name
      src_address_list = "st_trusted_devices"
      order            = 1110
    }
    "accept-trusted-forward" = {
      chain        = "forward"
      action       = "accept"
      in_interface = var.vlans.Trusted.name
      order        = 1199
    }

    # =========================================================================
    # GUEST ZONE
    # =========================================================================
    # Nothing specific yet

    # =========================================================================
    # IoT ZONE (restrictive - uses address lists for granular control)
    # =========================================================================
    "allow-iot-wan-restricted" = {
      chain              = "forward"
      action             = "accept"
      in_interface       = var.vlans.IoT.name
      src_address_list   = "st_iot_internet"
      out_interface_list = routeros_interface_list.wan.name
      order              = 1800
    }
    "allow-iot-to-servers-restricted" = {
      chain            = "forward"
      action           = "accept"
      in_interface     = var.vlans.IoT.name
      out_interface    = var.vlans.Servers.name
      src_address_list = "st_iot_servers"
      order            = 1810
    }

    # =========================================================================
    # SERVERS ZONE (Infrastructure + K8s services with special access)
    # =========================================================================
    "accept-infrastructure-input" = {
      chain            = "input"
      action           = "accept"
      in_interface     = var.vlans.Servers.name
      src_address_list = "st_infrastructure"
      order            = 2000
    }
    "accept-k8s-services-input" = {
      chain            = "input"
      action           = "accept"
      in_interface     = var.vlans.Servers.name
      src_address_list = "st_k8s_services"
      order            = 2010
    }

    # =========================================================================
    # DMZ ZONE (RIPE Atlas probe, etc)
    # =========================================================================
    # Nothing specific yet

    # =========================================================================
    # DEFAULT DENY
    # =========================================================================
    "drop-all-forward" = {
      chain  = "forward"
      action = "drop"
      order  = 9000
    }
    "drop-all-input" = {
      chain  = "input"
      action = "drop"
      order  = 9010
    }
  }

  # Convert to ordered list for move_items
  # Create entries with sort keys based on order field
  filter_rules_ordered = [
    for k, v in local.filter_rules : merge(v, {
      key      = k
      sort_key = format("%04d-%s", v.order, k)
    })
  ]

  # Create a map with lexicographically sortable keys for for_each
  # Map keys are always iterated in lexicographical order
  filter_rules_map = {
    for rule in local.filter_rules_ordered :
    rule.sort_key => rule
  }
}

# =================================================================================================
# Firewall Filter Rules
# =================================================================================================
resource "routeros_ip_firewall_filter" "rules" {
  for_each = local.filter_rules_map

  comment = "Managed by Terraform - ${each.value.key}"
  chain   = each.value.chain
  action  = each.value.action

  # Optional fields - only set if present in rule definition
  connection_state   = lookup(each.value, "connection_state", null)
  in_interface       = lookup(each.value, "in_interface", null)
  out_interface      = lookup(each.value, "out_interface", null)
  in_interface_list  = lookup(each.value, "in_interface_list", null)
  out_interface_list = lookup(each.value, "out_interface_list", null)
  protocol           = lookup(each.value, "protocol", null)
  dst_port           = lookup(each.value, "dst_port", null)
  src_port           = lookup(each.value, "src_port", null)
  src_address        = lookup(each.value, "src_address", null)
  dst_address        = lookup(each.value, "dst_address", null)
  jump_target        = lookup(each.value, "jump_target", null)
  hw_offload         = lookup(each.value, "hw_offload", null)

  lifecycle {
    create_before_destroy = true
  }
}

# Move rules to correct order after creation
resource "routeros_move_items" "firewall_rules" {
  resource_path = "/ip/firewall/filter"
  sequence      = [for idx in sort(keys(local.filter_rules_map)) : routeros_ip_firewall_filter.rules[idx].id]
  depends_on    = [routeros_ip_firewall_filter.rules]
}
