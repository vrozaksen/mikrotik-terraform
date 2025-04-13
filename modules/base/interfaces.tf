resource "routeros_interface_ethernet" "ethernet" {
  for_each = {
    for k, v in var.ethernet_interfaces : k => v
    if v.bond != true
  }

  factory_name = each.key
  name         = each.key
  comment      = each.value.comment != null ? each.value.comment : ""
  l2mtu        = each.value.mtu != null ? each.value.mtu : 1514
  disabled     = each.value.disabled != null ? each.value.disabled : false

  # Set sfp_shutdown_temperature if defined
  sfp_shutdown_temperature = each.value.sfp_shutdown_temperature
}
