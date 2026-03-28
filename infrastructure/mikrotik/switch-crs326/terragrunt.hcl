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
  # Port layout:
  # Top     [2-DL] [4-CP1m] [6-CP1e] [8-CP2m] [10-CP2e] [12-CP3m] [14-CP3e] [16-] [18-] [20-] [22-] [24-Tr]
  # Bottom  [1-UL] [3-W1  ] [5-W1  ] [7-W2  ] [9-W2   ] [11-W3  ] [13-W3  ] [15-W4] [17-W4] [19-Ain] [21-Ain] [23-Tr]
  ethernet_interfaces = {
    # "ether1" = { comment = "MGMT", untagged = local.shared_locals.vlans.Servers.name }

    # === Uplinks (1-2) ===
    "sfp-sfpplus1" = { comment = "Uplink", tagged = local.shared_locals.all_vlans }
    "sfp-sfpplus2" = { comment = "HORRACO Downlink", tagged = local.shared_locals.all_vlans }

    # === K8S Workers - bottom row bonds (3+5, 7+9, 11+13, 15+17) ===
    "sfp-sfpplus3"  = { comment = "K8S_W1", bridge_port = false }
    "sfp-sfpplus5"  = { comment = "K8S_W1", bridge_port = false }
    "sfp-sfpplus7"  = { comment = "K8S_W2", bridge_port = false }
    "sfp-sfpplus9"  = { comment = "K8S_W2", bridge_port = false }
    "sfp-sfpplus11" = { comment = "K8S_W3", bridge_port = false }
    "sfp-sfpplus13" = { comment = "K8S_W3", bridge_port = false }
    "sfp-sfpplus15" = { comment = "K8S_W4", bridge_port = false }
    "sfp-sfpplus17" = { comment = "K8S_W4", bridge_port = false }

    # === K8S Control Plane - top row (4+6, 8+10, 12+14) - active-backup on node side ===
    "sfp-sfpplus4"  = { comment = "K8S_CP1", untagged = local.shared_locals.vlans.Servers.name }
    "sfp-sfpplus6"  = { comment = "K8S_CP1", untagged = local.shared_locals.vlans.Servers.name }
    "sfp-sfpplus8"  = { comment = "K8S_CP2", untagged = local.shared_locals.vlans.Servers.name }
    "sfp-sfpplus10" = { comment = "K8S_CP2", untagged = local.shared_locals.vlans.Servers.name }
    "sfp-sfpplus12" = { comment = "K8S_CP3", untagged = local.shared_locals.vlans.Servers.name }
    "sfp-sfpplus14" = { comment = "K8S_CP3", untagged = local.shared_locals.vlans.Servers.name }

    # === Free (16, 18, 20, 22) ===
    "sfp-sfpplus16" = {}
    "sfp-sfpplus18" = {}
    "sfp-sfpplus20" = {}
    "sfp-sfpplus22" = {}

    # === Aincrad NAS - bond (19+21) ===
    "sfp-sfpplus19" = { comment = "Aincrad", bridge_port = false }
    "sfp-sfpplus21" = { comment = "Aincrad", bridge_port = false }

    # === Trusted (23-24) ===
    "sfp-sfpplus23" = {
      comment  = "Trusted"
      untagged = local.shared_locals.vlans.Trusted.name
      tagged   = [local.shared_locals.vlans.Servers.name, local.shared_locals.vlans.Guest.name, local.shared_locals.vlans.IoT.name]
    }
    "sfp-sfpplus24" = {
      comment  = "Trusted"
      untagged = local.shared_locals.vlans.Trusted.name
      tagged   = [local.shared_locals.vlans.Servers.name, local.shared_locals.vlans.Guest.name, local.shared_locals.vlans.IoT.name]
    }

    # === QSFP+ (unused) ===
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
    # === K8S Workers - bottom row bonds ===
    "K8S_W1" = {
      slaves   = ["sfp-sfpplus3", "sfp-sfpplus5"]
      comment  = "K8S_W1 alfheim"
      untagged = local.shared_locals.vlans.Servers.name
      tagged   = [for name, vlan in local.shared_locals.vlans : vlan.name if name != "Servers"]
    }
    "K8S_W2" = {
      slaves   = ["sfp-sfpplus7", "sfp-sfpplus9"]
      comment  = "K8S_W2 alne"
      untagged = local.shared_locals.vlans.Servers.name
      tagged   = [for name, vlan in local.shared_locals.vlans : vlan.name if name != "Servers"]
    }
    "K8S_W3" = {
      slaves   = ["sfp-sfpplus11", "sfp-sfpplus13"]
      comment  = "K8S_W3 ainias"
      untagged = local.shared_locals.vlans.Servers.name
      tagged   = [for name, vlan in local.shared_locals.vlans : vlan.name if name != "Servers"]
    }
    "K8S_W4" = {
      slaves   = ["sfp-sfpplus15", "sfp-sfpplus17"]
      comment  = "K8S_W4 granzam"
      untagged = local.shared_locals.vlans.Servers.name
      tagged   = [for name, vlan in local.shared_locals.vlans : vlan.name if name != "Servers"]
    }
    # === Aincrad NAS ===
    "Aincrad" = {
      slaves               = ["sfp-sfpplus19", "sfp-sfpplus21"]
      comment              = "Aincrad NAS"
      untagged             = local.shared_locals.vlans.Servers.name
      transmit_hash_policy = "layer-3-and-4"
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
