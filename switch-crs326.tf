# =================================================================================================
# Provider Configuration
# =================================================================================================
provider "routeros" {
  alias    = "crs326"
  hosturl  = "https://10.10.0.2"
  username = var.mikrotik_username
  password = var.mikrotik_password
  insecure = true
}

# =================================================================================================
# Base System Configs
# =================================================================================================
module "crs326" {
  source    = "./modules/base"
  providers = { routeros = routeros.crs326 }

  certificate_common_name = "10.10.0.2"
  hostname                = "Switch"
  timezone                = local.timezone
  ntp_servers             = [local.cloudflare_ntp]

  vlans = local.vlans
  ethernet_interfaces = {
    # "ether1" = { comment = "MGMT", untagged = local.vlans.Servers.name }
    "sfp-sfpplus1"  = { comment = "Uplink", tagged = local.all_vlans, mtu = 9216 }
    "sfp-sfpplus2"  = { comment = "Uplink", tagged = local.all_vlans, mtu = 9216 }
    "sfp-sfpplus3"  = { comment = "K8S_1", mtu = 9216, bridge_port = false }
    "sfp-sfpplus4"  = { comment = "K8S_1", mtu = 9216, bridge_port = false }
    "sfp-sfpplus5"  = { comment = "K8S_2", mtu = 9216, bridge_port = false }
    "sfp-sfpplus6"  = { comment = "K8S_2", mtu = 9216, bridge_port = false }
    "sfp-sfpplus7"  = { comment = "K8S_3", mtu = 9216, bridge_port = false }
    "sfp-sfpplus8"  = { comment = "K8S_3", mtu = 9216, bridge_port = false }
    "sfp-sfpplus9"  = { comment = "SRV", untagged = local.vlans.Servers.name, tagged = [local.vlans.IoT.name], mtu = 9216 }
    "sfp-sfpplus10" = { comment = "SRV", untagged = local.vlans.Servers.name, tagged = [local.vlans.IoT.name], mtu = 9216 }
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
      untagged = local.vlans.Trusted.name
      tagged   = [local.vlans.Servers.name, local.vlans.Guest.name, local.vlans.IoT.name]
    }
    "sfp-sfpplus24" = {
      comment  = "Trusted",
      untagged = local.vlans.Trusted.name
      tagged   = [local.vlans.Servers.name, local.vlans.Guest.name, local.vlans.IoT.name]
    }
    "qsfpplus1-1" = {}
    "qsfpplus1-2" = {}
    "qsfpplus1-3" = {}
    "qsfpplus1-4" = {}
    "qsfpplus2-1" = {}
    "qsfpplus2-2" = {}
    "qsfpplus2-3" = {}
    "qsfpplus2-4" = {}
    "K8S_1" = { comment = "K8S_1", untagged = local.vlans.Servers.name, tagged = [local.vlans.IoT.name], mtu = 9216, bond = true }
    "K8S_2" = { comment = "K8S_2", untagged = local.vlans.Servers.name, tagged = [local.vlans.IoT.name], mtu = 9216, bond = true }
    "K8S_3" = { comment = "K8S_3", untagged = local.vlans.Servers.name, tagged = [local.vlans.IoT.name], mtu = 9216, bond = true }
  }
}

# =================================================================================================
# DHCP Client
# =================================================================================================
resource "routeros_ip_dhcp_client" "crs326" {
  provider     = routeros.crs326
  interface    = local.vlans.Servers.name
  use_peer_dns = true
  use_peer_ntp = true
}

# =================================================================================================
# Bonding
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_bonding
# =================================================================================================
resource "routeros_interface_bonding" "K8S_1" {
  provider             = routeros.crs326
  name                 = "K8S_1"
  slaves               = ["sfp-sfpplus3", "sfp-sfpplus4"]
  link_monitoring      = "mii"
  mii_interval         = 1000
  min_links            = 1
  mode                 = "802.3ad"
  mtu                  = 9000
  transmit_hash_policy = "layer-3-and-4"
}
resource "routeros_interface_bonding" "K8S_2" {
  provider             = routeros.crs326
  name                 = "K8S_2"
  slaves               = ["sfp-sfpplus5", "sfp-sfpplus6"]
  link_monitoring      = "mii"
  mii_interval         = 1000
  min_links            = 1
  mode                 = "802.3ad"
  mtu                  = 9000
  transmit_hash_policy = "layer-3-and-4"
}
resource "routeros_interface_bonding" "K8S_3" {
  provider             = routeros.crs326
  name                 = "K8S_3"
  slaves               = ["sfp-sfpplus7", "sfp-sfpplus8"]
  link_monitoring      = "mii"
  mii_interval         = 1000
  min_links            = 1
  mode                 = "802.3ad"
  mtu                  = 9000
  transmit_hash_policy = "layer-3-and-4"
}