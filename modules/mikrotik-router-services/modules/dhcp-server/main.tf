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

  next_server     = var.pxe != null ? var.pxe.server : null
  dhcp_option_set = var.pxe != null ? routeros_ip_dhcp_server_option_sets.pxe["uefi"].name : null
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
  client_mac_limit          = 1
  conflict_detection        = false
  dynamic_lease_identifiers = "client-mac,client-id"
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

# ================================================================================================
# PXE Chainload (iPXE)
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dhcp_server_option_matcher
# ================================================================================================
locals {
  pxe_boot_files = var.pxe == null ? {} : {
    uefi = var.pxe.uefi_file
    bios = var.pxe.bios_file
    ipxe = var.pxe.script_url
  }
}

resource "routeros_ip_dhcp_server_option" "pxe_next_server" {
  count = var.pxe != null ? 1 : 0
  name  = "${var.interface_name}-pxe-next-server"
  code  = 66
  value = "s'${var.pxe.server}'"
}

resource "routeros_ip_dhcp_server_option" "pxe_boot_file" {
  for_each = local.pxe_boot_files
  name     = "${var.interface_name}-pxe-${each.key}-boot-file"
  code     = 67
  value    = "s'${each.value}'"
}

resource "routeros_ip_dhcp_server_option_sets" "pxe" {
  for_each = local.pxe_boot_files
  name     = "${var.interface_name}-pxe-${each.key}"
  options  = join(",", [routeros_ip_dhcp_server_option.pxe_boot_file[each.key].name, routeros_ip_dhcp_server_option.pxe_next_server[0].name])
}

resource "routeros_ip_dhcp_server_option_matcher" "pxe_ipxe" {
  count         = var.pxe != null ? 1 : 0
  name          = "${var.interface_name}-pxe-user-class-ipxe"
  server        = routeros_ip_dhcp_server.this.name
  address_pool  = routeros_ip_pool.this.name
  code          = 77
  value         = "0x69505845"
  matching_type = "exact"
  option_set    = routeros_ip_dhcp_server_option_sets.pxe["ipxe"].name
}

resource "routeros_ip_dhcp_server_option_matcher" "pxe_bios" {
  count         = var.pxe != null ? 1 : 0
  name          = "${var.interface_name}-pxe-arch-bios"
  server        = routeros_ip_dhcp_server.this.name
  address_pool  = routeros_ip_pool.this.name
  code          = 93
  value         = "0x0000"
  matching_type = "exact"
  option_set    = routeros_ip_dhcp_server_option_sets.pxe["bios"].name

  depends_on = [routeros_ip_dhcp_server_option_matcher.pxe_ipxe]
}
