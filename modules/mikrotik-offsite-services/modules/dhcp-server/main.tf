# ================================================================================================
# DHCP Pool Range
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_pool
# ================================================================================================
resource "routeros_ip_pool" "this" {
  name    = "${var.interface_name}-dhcp-pool"
  comment = "${var.interface_name} DHCP Pool"
  ranges  = var.dhcp_pool
}

# ================================================================================================
# DHCP Network Configuration
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dhcp_server_network
# ================================================================================================
resource "routeros_ip_dhcp_server_network" "this" {
  comment    = "${var.interface_name} DHCP Network"
  domain     = var.domain
  address    = var.network
  gateway    = var.gateway
  dns_server = var.dns_servers
}


# ================================================================================================
# DHCP Server Configuration
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dhcp_server
# ================================================================================================
resource "routeros_ip_dhcp_server" "this" {
  name                      = var.interface_name
  comment                   = "${var.interface_name} DHCP Server"
  address_pool              = routeros_ip_pool.this.name
  interface                 = var.interface_name
  lease_time                = "1d"
  conflict_detection        = false
  dynamic_lease_identifiers = "client-mac,client-id"

  lifecycle {
    ignore_changes = [client_mac_limit]
  }
}

# ================================================================================================
# Static DHCP Leases
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dhcp_server_lease
# ================================================================================================
resource "routeros_ip_dhcp_server_lease" "this" {
  for_each    = var.static_leases
  server      = routeros_ip_dhcp_server.this.name
  address     = each.key
  mac_address = each.value.mac
  comment     = each.value.name
}
