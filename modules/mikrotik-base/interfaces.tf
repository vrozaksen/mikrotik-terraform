resource "routeros_interface_ethernet" "ethernet" {
  for_each = var.ethernet_interfaces

  factory_name = each.key
  name         = each.key
  comment      = each.value.comment
  l2mtu        = each.value.l2mtu
  mtu          = each.value.mtu

  # null leaves non-PoE ports untouched (provider suppresses the diff)
  power_cycle_ping_enabled = each.value.power_cycle_ping_address != null ? true : null
  power_cycle_ping_address = each.value.power_cycle_ping_address
  power_cycle_ping_timeout = each.value.power_cycle_ping_timeout
}
