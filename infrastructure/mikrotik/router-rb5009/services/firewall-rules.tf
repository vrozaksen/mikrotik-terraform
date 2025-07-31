# =================================================================================================
# Lists
# =================================================================================================
# Static lists (manual)
resource "routeros_ip_firewall_addr_list" "k8s_services" {
  list     = "st_k8s_services"
  comment  = "Static: IPs allocated to K8S Services."
  address  = "10.10.0.20-10.10.0.29"
}
resource "routeros_ip_firewall_addr_list" "iot_internet" {
  list     = "st_iot_internet"
  comment  = "Static: IoT IPs allowed to the internet."
  address  = "10.20.0.201-10.20.0.250"
}
resource "routeros_ip_firewall_addr_list" "iot_servers" {
  list     = "st_iot_servers"
  comment  = "Static: IoT IPs allowed to servers."
  address  = "10.20.0.240-10.20.0.250"
}
resource "routeros_ip_firewall_addr_list" "trusted_devices" {
  list     = "st_trusted_devices"
  comment  = "Static: Devices with full trusted access"
  address  = "10.100.0.100-10.100.0.104"
}

# Dynamic lists (auto-generated)
locals {
  service_access = {
    dns = ["Trusted", "IoT", "Servers"],
    ntp = ["Trusted", "Servers"],
    wan = ["Trusted", "IoT", "Servers", "Guest"],
  }
}
resource "routeros_ip_firewall_addr_list" "ag_service_lists" {
  for_each = {
    for entry in flatten([
      for service, vlans in local.service_access : [
        for vlan in vlans : {
          service = service
          vlan    = vlan
          key = "ag_${service}_access_${vlan}"
          list_name = "ag_${service}_access"
        } if contains(keys(local.vlans), vlan)
      ]
    ]) : entry.key => entry
  }

  list     = each.value.list_name
  comment  = "Auto-Generated: ${upper(each.value.service)} access for ${each.value.vlan}"
  address  = "${local.vlans[each.value.vlan].network}/${local.vlans[each.value.vlan].cidr_suffix}"
}

# =================================================================================================
# Firewall Rules
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter
# =================================================================================================
### Trusted Devices Special Rules
resource "routeros_ip_firewall_filter" "accept_trusted_devices_input" {
  comment          = "Auto-Generated: Full access for Trusted_Devices (input)"
  action           = "accept"
  chain            = "input"
  in_interface     = local.vlans.Trusted.name
  src_address_list = "st_trusted_devices"
  place_before     = routeros_ip_firewall_filter.accept_trusted_devices_forward.id
}
resource "routeros_ip_firewall_filter" "accept_trusted_devices_forward" {
  comment          = "Auto-Generated: Full access for Trusted_Devices (forward)"
  action           = "accept"
  chain            = "forward"
  in_interface     = local.vlans.Trusted.name
  src_address_list = "st_trusted_devices"
  place_before     = routeros_ip_firewall_filter.allow_trusted_forward.id
}

### Trusted VLAN Rules
resource "routeros_ip_firewall_filter" "allow_trusted_forward" {
  comment      = "Auto-Generated: Allow Trusted → Any"
  action       = "accept"
  chain        = "forward"
  in_interface = local.vlans.Trusted.name
  place_before = routeros_ip_firewall_filter.accept_k8s_services_input.id
}

### Servers Special Rules
resource "routeros_ip_firewall_filter" "accept_k8s_services_input" {
  comment          = "Auto-Generated: Full access for Trusted_Devices (input) - API"
  action           = "accept"
  chain            = "input"
  in_interface     = local.vlans.Servers.name
  src_address_list = "st_k8s_services"
  place_before     = routeros_ip_firewall_filter.allow_dns_udp.id
}

### Service Rules
resource "routeros_ip_firewall_filter" "allow_dns_udp" {
  comment          = "Auto-Generated: Allow DNS (UDP)"
  action           = "accept"
  chain            = "input"
  protocol         = "udp"
  dst_port         = "53"
  src_address_list = "ag_dns_access"
  place_before     = routeros_ip_firewall_filter.allow_ntp.id
}
resource "routeros_ip_firewall_filter" "allow_ntp" {
  comment          = "Auto-Generated: Allow NTP"
  action           = "accept"
  chain            = "input"
  protocol         = "udp"
  dst_port         = "123"
  src_address_list = "ag_ntp_access"
  place_before     = routeros_ip_firewall_filter.allow_wan_access.id
}
resource "routeros_ip_firewall_filter" "allow_wan_access" {
  comment            = "Auto-Generated: Allow WAN access"
  action             = "accept"
  chain              = "forward"
  src_address_list   = "ag_wan_access"
  out_interface_list = routeros_interface_list.wan.name
  place_before       = routeros_ip_firewall_filter.allow_iot_wan_restricted.id
}

### Special IoT Restrictions
resource "routeros_ip_firewall_filter" "allow_iot_wan_restricted" {
  comment            = "Auto-Generated: Allow IoT to WAN (restricted IPs)"
  action             = "accept"
  chain              = "forward"
  in_interface       = local.vlans.IoT.name
  src_address_list   = "st_iot_internet"
  out_interface_list = routeros_interface_list.wan.name
  place_before       = routeros_ip_firewall_filter.allow_iot_to_servers.id
}

### Special Access Rules
resource "routeros_ip_firewall_filter" "allow_iot_to_servers" {
  comment          = "Auto-Generated: Allow some IoT to Servers"
  action           = "accept"
  chain            = "forward"
  # protocol         = "tcp"
  # dst_port         = "8096"
  # dst_address      = "10.10.0.42"
  src_address_list = "st_iot_servers"
  in_interface     = local.vlans.IoT.name
  out_interface    = local.vlans.Servers.name
  place_before     = routeros_ip_firewall_filter.drop_all_forward.id
}
# resource "routeros_ip_firewall_filter" "allow_iot_to_home_assistant" {
#   comment          = "Auto-Generated: Allow IoT to Home Assistant"
#   action           = "accept"
#   chain            = "forward"
#   protocol         = "tcp"
#   dst_port         = "8123"
#   dst_address      = "10.10.0.43"
#   src_address_list = "st_iot_internet"
#   in_interface     = local.vlans.IoT.name
#   out_interface    = local.vlans.Servers.name
#   place_before     = routeros_ip_firewall_filter.drop_all_forward.id
# }

### Default Deny Rules
resource "routeros_ip_firewall_filter" "drop_all_forward" {
  comment      = "Auto-Generated: Default drop all forward"
  action       = "drop"
  chain        = "forward"
  place_before = routeros_ip_firewall_filter.drop_all_input.id
}
resource "routeros_ip_firewall_filter" "drop_all_input" {
  comment  = "Auto-Generated: Default drop all input"
  action   = "drop"
  chain    = "input"
}
