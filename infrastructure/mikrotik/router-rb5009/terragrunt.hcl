include "root" {
  path = find_in_parent_folders("root.hcl")
}
include "shared_provider" {
  path = find_in_parent_folders("provider.hcl")
}

locals {
  mikrotik_hostname = "10.10.0.1"
  shared_locals     = read_terragrunt_config(find_in_parent_folders("locals.hcl")).locals
}

terraform {
  source = find_in_parent_folders("modules/mikrotik-base")
}

inputs = {
  mikrotik_hostname = "https://${local.mikrotik_hostname}"
  mikrotik_username = get_env("MIKROTIK_USERNAME")
  mikrotik_password = get_env("MIKROTIK_PASSWORD")
  mikrotik_insecure = true

  certificate_common_name = local.mikrotik_hostname
  hostname                = "Router"
  timezone                = local.shared_locals.timezone
  ntp_servers             = [local.shared_locals.cloudflare_ntp]

  vlans = local.shared_locals.vlans
  ethernet_interfaces = {
    "ether1" = { comment = "Vectra Uplink", bridge_port = false }
    "ether2" = { comment = "SLZB", untagged = local.shared_locals.vlans.Servers.name }
    "ether3" = { comment = "Aincrad", untagged = local.shared_locals.vlans.Servers.name }
    "ether4" = {}
    "ether5" = {}
    "ether6" = { comment = "pi-nut", untagged = local.shared_locals.vlans.Servers.name }
    "ether7" = {
      comment  = "EMG",
      untagged = local.shared_locals.vlans.Trusted.name
      tagged   = [local.shared_locals.vlans.Servers.name, local.shared_locals.vlans.Guest.name, local.shared_locals.vlans.IoT.name]
    }
    "ether8" = {
      comment  = "Access Point",
      untagged = local.shared_locals.vlans.Servers.name
      tagged   = [local.shared_locals.vlans.Trusted.name, local.shared_locals.vlans.Guest.name, local.shared_locals.vlans.IoT.name]
    }
    "sfp-sfpplus1" = { comment = "CRS326 Downlink", tagged = local.shared_locals.all_vlans, mtu = 9000 } # mtu = 1514 
  }
}
