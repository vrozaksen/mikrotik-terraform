include "root" {
  path = find_in_parent_folders("root.hcl")
}
include "shared_provider" {
  path = find_in_parent_folders("provider.hcl")
}

dependencies {
    paths = [
      find_in_parent_folders("mikrotik/router-rb5009")
    ]
}

locals {
  mikrotik_hostname = "10.10.0.2"
  shared_locals = read_terragrunt_config(find_in_parent_folders("locals.hcl")).locals
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
    "sfp-sfpplus1"  = { comment = "Uplink", tagged = local.shared_locals.all_vlans, mtu = 9000 }
    "sfp-sfpplus2"  = { comment = "HORRACO Downlink", tagged = local.shared_locals.all_vlans, mtu = 9000 }
    "sfp-sfpplus3"  = { comment = "K8S_1", mtu = 9000, bridge_port = false }
    "sfp-sfpplus4"  = { comment = "K8S_1", mtu = 9000, bridge_port = false }
    "sfp-sfpplus5"  = { comment = "K8S_2", mtu = 9000, bridge_port = false }
    "sfp-sfpplus6"  = { comment = "K8S_2", mtu = 9000, bridge_port = false }
    "sfp-sfpplus7"  = { comment = "K8S_3", mtu = 9000, bridge_port = false }
    "sfp-sfpplus8"  = { comment = "K8S_3", mtu = 9000, bridge_port = false }
    "sfp-sfpplus9"  = { comment = "SRV", untagged = local.shared_locals.vlans.Servers.name, tagged = [local.shared_locals.vlans.IoT.name], mtu = 9000 }
    "sfp-sfpplus10" = { comment = "SRV", untagged = local.shared_locals.vlans.Servers.name, tagged = [local.shared_locals.vlans.IoT.name], mtu = 9000 }
    "sfp-sfpplus11" = {}
    "sfp-sfpplus12" = {}
    "sfp-sfpplus13" = {}
    "sfp-sfpplus14" = {}
    "sfp-sfpplus15" = {}
    "sfp-sfpplus16" = {}
    "sfp-sfpplus17" = {}
    "sfp-sfpplus18" = {}
    "sfp-sfpplus19" = {}
    "sfp-sfpplus20" = {}
    "sfp-sfpplus21" = {}
    "sfp-sfpplus22" = {}
    "sfp-sfpplus23" = {
      comment  = "Trusted",
      untagged = local.shared_locals.vlans.Trusted.name
      tagged   = [local.shared_locals.vlans.Servers.name, local.shared_locals.vlans.Guest.name, local.shared_locals.vlans.IoT.name]
      mtu = 9000
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
      slaves  = ["sfp-sfpplus3", "sfp-sfpplus4"]
      comment = "K8S_1"
      untagged = local.shared_locals.vlans.Servers.name
      tagged  = [for name, vlan in local.shared_locals.vlans : vlan.name if name != "Servers"]
    }
    "K8S_2" = {
      slaves  = ["sfp-sfpplus5", "sfp-sfpplus6"]
      comment = "K8S_2"
      untagged = local.shared_locals.vlans.Servers.name
      tagged  = [for name, vlan in local.shared_locals.vlans : vlan.name if name != "Servers"]
    }
    "K8S_3" = {
      slaves  = ["sfp-sfpplus7", "sfp-sfpplus8"]
      comment = "K8S_3"
      untagged = local.shared_locals.vlans.Servers.name
      tagged  = [for name, vlan in local.shared_locals.vlans : vlan.name if name != "Servers"]
    }
  }
}
