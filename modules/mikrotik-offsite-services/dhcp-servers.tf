# =================================================================================================
# IP Addresses for VLANs
# =================================================================================================
resource "routeros_ip_address" "vlans" {
  for_each  = var.vlans
  address   = "${each.value.gateway}/${each.value.cidr_suffix}"
  interface = each.value.name
  network   = each.value.network

  lifecycle {
    ignore_changes = [vrf]
  }
}

# =================================================================================================
# DHCP Servers (using submodule)
# =================================================================================================
module "dhcp-server" {
  for_each = var.vlans
  source   = "./modules/dhcp-server"

  interface_name = each.value.name
  network        = "${each.value.network}/${each.value.cidr_suffix}"
  gateway        = each.value.gateway
  dhcp_pool      = each.value.dhcp_pool
  dns_servers    = each.value.dns_servers
  domain         = each.value.domain
  static_leases  = each.value.static_leases
}


