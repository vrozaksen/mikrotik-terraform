# =================================================================================================
# Interface Lists
# =================================================================================================
resource "routeros_interface_list" "wan" {
  name    = "WAN"
  comment = "WAN interfaces"
}

resource "routeros_interface_list" "lan" {
  name    = "LAN"
  comment = "LAN interfaces (bridge VLANs)"
}

resource "routeros_interface_list" "management" {
  name    = "MGMT"
  comment = "Management interfaces - full access"
}

resource "routeros_interface_list_member" "wan" {
  list      = routeros_interface_list.wan.name
  interface = "ether1"
}

resource "routeros_interface_list_member" "bridge" {
  list      = routeros_interface_list.lan.name
  interface = "bridge"
}

resource "routeros_interface_list_member" "mgmt" {
  list      = routeros_interface_list.management.name
  interface = "ether4"
}

# =================================================================================================
# NAT - Masquerade
# =================================================================================================
resource "routeros_ip_firewall_nat" "masquerade" {
  chain              = "srcnat"
  action             = "masquerade"
  out_interface_list = routeros_interface_list.wan.name
  comment            = "Masquerade outgoing traffic"
}

# =================================================================================================
# Address Lists
# =================================================================================================
resource "routeros_ip_firewall_addr_list" "private" {
  list    = "private-ranges"
  address = "10.0.0.0/8"
  comment = "Private range"
}

# =================================================================================================
# Filter Rules
# =================================================================================================
locals {
  # VLAN interfaces
  servers_iface = lookup(var.vlans, "Servers", null) != null ? var.vlans["Servers"].name : null
  trusted_iface = lookup(var.vlans, "Trusted", null) != null ? var.vlans["Trusted"].name : null
  guest_iface   = lookup(var.vlans, "Guest", null) != null ? var.vlans["Guest"].name : null

  filter_rules = {
    # =========================================================================
    # INPUT CHAIN
    # =========================================================================
    "input-established" = {
      chain            = "input"
      action           = "accept"
      connection_state = "established,related,untracked"
      order            = 100
    }
    "input-invalid" = {
      chain            = "input"
      action           = "drop"
      connection_state = "invalid"
      order            = 110
    }
    "input-icmp" = {
      chain    = "input"
      action   = "accept"
      protocol = "icmp"
      order    = 120
    }
    "input-lan" = {
      chain             = "input"
      action            = "accept"
      in_interface_list = routeros_interface_list.lan.name
      order             = 130
    }
    "input-mgmt" = {
      chain             = "input"
      action            = "accept"
      in_interface_list = routeros_interface_list.management.name
      order             = 140
    }
    "input-wireguard" = {
      chain    = "input"
      action   = "accept"
      protocol = "udp"
      dst_port = tostring(routeros_interface_wireguard.wireguard.listen_port)
      order    = 150
    }
    "input-wg-interface" = {
      chain        = "input"
      action       = "accept"
      in_interface = routeros_interface_wireguard.wireguard.name
      order        = 160
    }
    "input-drop-wan" = {
      chain             = "input"
      action            = "drop"
      in_interface_list = routeros_interface_list.wan.name
      order             = 900
    }

    # =========================================================================
    # FORWARD CHAIN
    # =========================================================================
    "forward-fasttrack" = {
      chain            = "forward"
      action           = "fasttrack-connection"
      connection_state = "established,related"
      disabled         = var.qos_enabled  # Disable FastTrack when QoS is enabled
      order            = 1000
    }
    "forward-established" = {
      chain            = "forward"
      action           = "accept"
      connection_state = "established,related,untracked"
      order            = 1010
    }
    "forward-invalid" = {
      chain            = "forward"
      action           = "drop"
      connection_state = "invalid"
      order            = 1020
    }

    # WireGuard -> Servers ONLY
    "forward-wg-servers" = {
      chain         = "forward"
      action        = "accept"
      in_interface  = routeros_interface_wireguard.wireguard.name
      out_interface = local.servers_iface
      order         = 1100
    }

    # Servers -> WireGuard (return traffic + access to main network)
    "forward-servers-wg" = {
      chain         = "forward"
      action        = "accept"
      in_interface  = local.servers_iface
      out_interface = routeros_interface_wireguard.wireguard.name
      order         = 1110
    }

    # All VLANs -> WAN (Internet)
    "forward-lan-wan" = {
      chain              = "forward"
      action             = "accept"
      in_interface_list  = routeros_interface_list.lan.name
      out_interface_list = routeros_interface_list.wan.name
      order              = 1200
    }

    # Management -> everywhere
    "forward-mgmt" = {
      chain             = "forward"
      action            = "accept"
      in_interface_list = routeros_interface_list.management.name
      order             = 1300
    }

    # Drop WAN new connections (not DSTNAT)
    "forward-drop-wan" = {
      chain                = "forward"
      action               = "drop"
      in_interface_list    = routeros_interface_list.wan.name
      connection_state     = "new"
      connection_nat_state = "!dstnat"
      order                = 9000
    }
  }

  # VLAN isolation rules (conditional)
  vlan_isolation_rules = merge(
    # Guest isolation - no access to private ranges
    lookup(var.vlans, "Guest", null) != null ? {
      "forward-guest-isolation" = {
        chain            = "forward"
        action           = "drop"
        src_address      = "${var.vlans["Guest"].network}/${var.vlans["Guest"].cidr_suffix}"
        dst_address_list = "private-ranges"
        order            = 1400
      }
    } : {},

    # Trusted isolation - no access to Servers
    lookup(var.vlans, "Trusted", null) != null && lookup(var.vlans, "Servers", null) != null ? {
      "forward-trusted-servers-drop" = {
        chain         = "forward"
        action        = "drop"
        in_interface  = local.trusted_iface
        out_interface = local.servers_iface
        order         = 1410
      }
    } : {},

    # Servers isolation - no access to Trusted
    lookup(var.vlans, "Servers", null) != null && lookup(var.vlans, "Trusted", null) != null ? {
      "forward-servers-trusted-drop" = {
        chain         = "forward"
        action        = "drop"
        in_interface  = local.servers_iface
        out_interface = local.trusted_iface
        order         = 1420
      }
    } : {}
  )

  # Merge all rules
  all_filter_rules = merge(local.filter_rules, local.vlan_isolation_rules)

  # Create ordered map for for_each
  filter_rules_ordered = [
    for k, v in local.all_filter_rules : merge(v, {
      key      = k
      sort_key = format("%04d-%s", v.order, k)
    })
  ]

  filter_rules_map = {
    for rule in local.filter_rules_ordered :
    rule.sort_key => rule
  }
}

resource "routeros_ip_firewall_filter" "rules" {
  for_each = local.filter_rules_map

  comment = each.value.key
  chain   = each.value.chain
  action  = each.value.action

  disabled             = lookup(each.value, "disabled", null)
  connection_state     = lookup(each.value, "connection_state", null)
  connection_nat_state = lookup(each.value, "connection_nat_state", null)
  in_interface         = lookup(each.value, "in_interface", null)
  out_interface        = lookup(each.value, "out_interface", null)
  in_interface_list    = lookup(each.value, "in_interface_list", null)
  out_interface_list   = lookup(each.value, "out_interface_list", null)
  protocol             = lookup(each.value, "protocol", null)
  dst_port             = lookup(each.value, "dst_port", null)
  src_address          = lookup(each.value, "src_address", null)
  dst_address_list     = lookup(each.value, "dst_address_list", null)
  hw_offload           = lookup(each.value, "hw_offload", null)

  lifecycle {
    create_before_destroy = true
  }
}

resource "routeros_move_items" "firewall_rules" {
  resource_path = "/ip/firewall/filter"
  sequence      = [for idx in sort(keys(local.filter_rules_map)) : routeros_ip_firewall_filter.rules[idx].id]
  depends_on    = [routeros_ip_firewall_filter.rules]
}
