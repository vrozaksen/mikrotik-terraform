include "root" {
  path = find_in_parent_folders("root.hcl")
}


dependencies {
  paths = [
    find_in_parent_folders("mikrotik/router-services")
  ]
}

locals {
  mikrotik_hostname = "10.10.0.2"
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
  hostname                = "Switch"
  timezone                = local.shared_locals.timezone
  ntp_servers             = [local.shared_locals.cloudflare_ntp]

  vlans = local.shared_locals.vlans
  ethernet_interfaces = {
    # "ether1" = { comment = "MGMT", untagged = local.shared_locals.vlans.Servers.name }
    "sfp-sfpplus1"  = { comment = "Uplink", tagged = local.shared_locals.all_vlans }
    "sfp-sfpplus2"  = { comment = "HORRACO Downlink", tagged = local.shared_locals.all_vlans }
    "sfp-sfpplus3"  = { comment = "K8S_1", bridge_port = false }
    "sfp-sfpplus4"  = { comment = "K8S_1", bridge_port = false }
    "sfp-sfpplus5"  = { comment = "K8S_2", bridge_port = false }
    "sfp-sfpplus6"  = { comment = "K8S_2", bridge_port = false }
    "sfp-sfpplus7"  = { comment = "K8S_3", bridge_port = false }
    "sfp-sfpplus8"  = { comment = "K8S_3", bridge_port = false }
    "sfp-sfpplus9"  = { comment = "SRV", untagged = local.shared_locals.vlans.Servers.name, tagged = [local.shared_locals.vlans.IoT.name] }
    "sfp-sfpplus10" = { comment = "SRV", untagged = local.shared_locals.vlans.Servers.name, tagged = [local.shared_locals.vlans.IoT.name] }
    "sfp-sfpplus11" = {}
    "sfp-sfpplus12" = {}
    "sfp-sfpplus13" = {}
    "sfp-sfpplus14" = {}
    "sfp-sfpplus15" = {}
    "sfp-sfpplus16" = {}
    "sfp-sfpplus17" = { comment = "Aincrad", bridge_port = false }
    "sfp-sfpplus18" = { comment = "Aincrad", bridge_port = false }
    "sfp-sfpplus19" = {}
    "sfp-sfpplus20" = {}
    "sfp-sfpplus21" = {}
    "sfp-sfpplus22" = {}
    "sfp-sfpplus23" = {
      comment  = "Trusted",
      untagged = local.shared_locals.vlans.Trusted.name
      tagged   = [local.shared_locals.vlans.Servers.name, local.shared_locals.vlans.Guest.name, local.shared_locals.vlans.IoT.name]
    }
    "sfp-sfpplus24" = {
      comment  = "Trusted",
      untagged = local.shared_locals.vlans.Trusted.name
      tagged   = [local.shared_locals.vlans.Servers.name, local.shared_locals.vlans.Guest.name, local.shared_locals.vlans.IoT.name]
    }
    "qsfpplus1-1" = {}
    "qsfpplus1-2" = {}
    "qsfpplus1-3" = {}
    "qsfpplus1-4" = {}
    "qsfpplus2-1" = {}
    "qsfpplus2-2" = {}
    "qsfpplus2-3" = {}
    "qsfpplus2-4" = {}
  }
  bond_interfaces = {
    "K8S_1" = {
      slaves   = ["sfp-sfpplus3", "sfp-sfpplus4"]
      comment  = "K8S_1"
      untagged = local.shared_locals.vlans.Servers.name
      tagged   = [for name, vlan in local.shared_locals.vlans : vlan.name if name != "Servers"]
    }
    "K8S_2" = {
      slaves   = ["sfp-sfpplus5", "sfp-sfpplus6"]
      comment  = "K8S_2"
      untagged = local.shared_locals.vlans.Servers.name
      tagged   = [for name, vlan in local.shared_locals.vlans : vlan.name if name != "Servers"]
    }
    "K8S_3" = {
      slaves   = ["sfp-sfpplus7", "sfp-sfpplus8"]
      comment  = "K8S_3"
      untagged = local.shared_locals.vlans.Servers.name
      tagged   = [for name, vlan in local.shared_locals.vlans : vlan.name if name != "Servers"]
    }
    "Aincrad" = {
      slaves               = ["sfp-sfpplus17", "sfp-sfpplus18"]
      comment              = "Aincrad"
      untagged             = local.shared_locals.vlans.Servers.name
      transmit_hash_policy = "layer-3-and-4"
      # tagged   = [for name, vlan in local.shared_locals.vlans : vlan.name if name != "Servers"]
    }
  }

  # BGP Configuration
  bgp_enabled = true
  bgp_instance = {
    name      = "bgp-instance-1"
    as        = 64514
    router_id = "10.10.0.2"
  }
  bgp_peer_connections = {
    "rb5009" = {
      name           = "RB5009_UPLINK"
      local_address  = "10.10.0.2"
      remote_address = "10.10.0.1"
      remote_as      = 64513
    }
  }
  bgp_k8s_peers = local.shared_locals.bgp_k8s_peers
  bgp_k8s_asn   = local.shared_locals.bgp_asn_k8s

  # DHCP Client Configuration
  dhcp_clients = {
    "uplink" = {
      interface         = local.shared_locals.vlans.Servers.name
      comment           = "Uplink DHCP"
      add_default_route = "yes"
      use_peer_dns      = true
      use_peer_ntp      = true
    }
  }
}
