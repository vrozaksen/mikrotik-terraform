include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  mikrotik_hostname = "10.11.10.1"
  offsite_locals    = read_terragrunt_config(find_in_parent_folders("offsite-locals.hcl")).locals
}

terraform {
  source = find_in_parent_folders("modules/mikrotik-base")
}

inputs = {
  mikrotik_hostname = "https://${local.mikrotik_hostname}"
  mikrotik_username = get_env("MIKROTIK_USERNAME")
  mikrotik_password = get_env("MIKROTIK_PASSWORD")
  mikrotik_insecure = true

  # System
  hostname                = "Router-Offsite"
  certificate_common_name = local.mikrotik_hostname
  timezone                = local.offsite_locals.timezone
  ntp_servers             = [local.offsite_locals.cloudflare_ntp]

  # VLANs
  vlans = local.offsite_locals.vlans

  # Interfaces
  ethernet_interfaces = {
    "ether1" = {
      comment     = "WAN"
      bridge_port = false
    }
    "ether2" = {
      comment  = "Trusted"
      untagged = local.offsite_locals.vlans.Trusted.name
    }
    "ether3" = {
      comment  = "Servers"
      untagged = local.offsite_locals.vlans.Servers.name
    }
    "ether4" = {
      comment  = "Emergency/Management"
      untagged = local.offsite_locals.vlans.Servers.name
    }
  }

  # DHCP Client (WAN)
  dhcp_clients = {
    "wan" = {
      interface              = "ether1"
      comment                = "WAN DHCP Client"
      add_default_route      = "yes"
      default_route_distance = 1
      use_peer_dns           = false
      use_peer_ntp           = false
    }
  }
}
