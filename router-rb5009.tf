# =================================================================================================
# Provider Configuration
# =================================================================================================
provider "routeros" {
  alias = "rb5009"
  hosturl  = "https://10.10.0.1"
  username = var.mikrotik_username
  password = var.mikrotik_password
  insecure = true
}

# =================================================================================================
# Base System Configs
# =================================================================================================
module "rb5009" {
  source    = "./modules/base"
  providers = { routeros = routeros.rb5009 }

  certificate_common_name = "10.10.0.1"
  hostname                = "Router"
  timezone                = local.timezone
  ntp_servers             = [local.cloudflare_ntp]

  vlans = local.vlans
  ethernet_interfaces = {
    "ether1" = { comment = "Vectra Uplink", bridge_port = false }
    "ether2" = { comment = "SLZB", untagged = local.vlans.Servers.name }
    "ether3" = { comment = "Aincrad", untagged = local.vlans.Servers.name }
    "ether4" = { comment = "k8s_1", untagged = local.vlans.Servers.name, tagged = [local.vlans.IoT.name] } # TODO
    "ether5" = { comment = "k8s_2", untagged = local.vlans.Servers.name, tagged = [local.vlans.IoT.name] } # TODO
    "ether6" = { comment = "k8s_3", untagged = local.vlans.Servers.name, tagged = [local.vlans.IoT.name] } # TODO
    "ether7" = {
      comment  = "EMG",
      untagged = local.vlans.Trusted.name
      tagged   = [local.vlans.Servers.name, local.vlans.Guest.name, local.vlans.IoT.name]
    }
    "ether8" = {
      comment  = "Access Point",
      untagged = local.vlans.Servers.name
      tagged   = [local.vlans.Trusted.name, local.vlans.Guest.name, local.vlans.IoT.name]
    }
    "sfp-sfpplus1" = { comment = "Switch Downlink", tagged = local.all_vlans, mtu = 9216 } # mtu = 1514 
  }
}

# =================================================================================================
# DHCP Client
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dhcp_client
# =================================================================================================
resource "routeros_ip_dhcp_client" "vectra" {
  provider               = routeros.rb5009
  interface              = "ether1"
  add_default_route      = "yes"
  comment                = "Vectra DHCP Client"
  default_route_distance = 1
  disabled               = false
  dhcp_options           = "hostname,clientid"
  use_peer_dns           = false
  use_peer_ntp           = false
}

# =================================================================================================
# SNMP 
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/snmp
# =================================================================================================
resource "routeros_snmp" "snmp" {
  provider = routeros.rb5009
  contact  = var.snmp_contact
  enabled  = true
  location = "Homelab"
}
