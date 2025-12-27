include "root" {
  path = find_in_parent_folders("root.hcl")
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
    "ether2" = { comment = "LTE Uplink", bridge_port = false }
    "ether3" = { comment = "SLZB", untagged = local.shared_locals.vlans.Servers.name }
    "ether4" = { comment = "RIPE Atlas Probe", untagged = local.shared_locals.vlans.DMZ.name }
    "ether5" = { 
      comment = "TV-Living-Room", 
      untagged = local.shared_locals.vlans.IoT.name 
      tagged = [local.shared_locals.vlans.Servers.name, local.shared_locals.vlans.Trusted.name]
      }
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
    "sfp-sfpplus1" = { comment = "CRS326 Downlink", tagged = local.shared_locals.all_vlans }
  }

  # BGP Configuration
  bgp_enabled = true
  bgp_instance = {
    name      = "bgp-instance-1"
    as        = 64513
    router_id = "10.10.0.1"
  }
  bgp_peer_connections = {
    "crs326" = {
      name             = "CRS326_UPLINK"
      local_address    = "10.10.0.1"
      remote_address   = "10.10.0.2"
      remote_as        = 64514
      address_families = "ip"
      multihop         = true
    }
  }
  bgp_k8s_peers = local.shared_locals.bgp_k8s_peers
  bgp_k8s_asn   = local.shared_locals.bgp_asn_k8s

  # DHCP Client Configuration
  dhcp_clients = {
    "vectra" = {
      interface              = "ether1"
      comment                = "Vectra DHCP Client"
      add_default_route      = "yes"
      default_route_distance = 1
      dhcp_options           = "hostname,clientid"
      use_peer_dns           = false
      use_peer_ntp           = false
    }
    "lte" = {
      interface              = "ether2"
      comment                = "LTE DHCP Client"
      add_default_route      = "yes"
      default_route_distance = 2
      dhcp_options           = "hostname,clientid"
      use_peer_dns           = false
      use_peer_ntp           = false
    }
  }
}
