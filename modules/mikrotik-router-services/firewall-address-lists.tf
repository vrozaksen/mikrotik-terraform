# =================================================================================================
# Address Lists
# =================================================================================================
# Static lists (manual) - define specific IP ranges
resource "routeros_ip_firewall_addr_list" "infrastructure" {
  list    = "st_infrastructure"
  comment = "Static: Infrastructure devices (router, switch)"
  address = "10.10.0.1-10.10.0.10"
}
resource "routeros_ip_firewall_addr_list" "k8s_services" {
  list    = "st_k8s_services"
  comment = "Static: IPs allocated to K8S Services."
  address = "10.10.0.20-10.10.0.29"
}
resource "routeros_ip_firewall_addr_list" "iot_internet" {
  list    = "st_iot_internet"
  comment = "Static: IoT IPs allowed to the internet."
  address = "10.20.0.201-10.20.0.250"
}
resource "routeros_ip_firewall_addr_list" "iot_servers" {
  list    = "st_iot_servers"
  comment = "Static: IoT IPs allowed to servers."
  address = "10.20.0.230-10.20.0.250"
}
resource "routeros_ip_firewall_addr_list" "trusted_devices" {
  list    = "st_trusted_devices"
  comment = "Static: Devices with full trusted access"
  address = "10.100.0.100-10.100.0.104"
}

# Dynamic lists (auto-generated) - define access per VLAN for services
locals {
  service_access = {
    dns = ["Trusted", "IoT", "Servers", "DMZ"],
    ntp = ["Trusted", "Servers", "DMZ"],
    wan = ["Trusted", "IoT", "Servers", "Guest", "DMZ"],
  }
}
resource "routeros_ip_firewall_addr_list" "ag_service_lists" {
  for_each = {
    for entry in flatten([
      for service, vlans in local.service_access : [
        for vlan in vlans : {
          service   = service
          vlan      = vlan
          key       = "ag_${service}_access_${vlan}"
          list_name = "ag_${service}_access"
        } if contains(keys(var.vlans), vlan)
      ]
    ]) : entry.key => entry
  }

  list    = each.value.list_name
  comment = "Auto-Generated: ${upper(each.value.service)} access for ${each.value.vlan}"
  address = "${var.vlans[each.value.vlan].network}/${var.vlans[each.value.vlan].cidr_suffix}"
}
