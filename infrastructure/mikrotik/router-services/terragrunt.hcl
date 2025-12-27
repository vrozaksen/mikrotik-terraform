include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = [
    find_in_parent_folders("mikrotik/router-base")
  ]
}

locals {
  mikrotik_hostname = "10.10.0.1"
  network_config    = read_terragrunt_config(find_in_parent_folders("locals.hcl"))
}

terraform {
  source = find_in_parent_folders("modules/mikrotik-router-services")
}

inputs = {
  mikrotik_hostname = "https://${local.mikrotik_hostname}"
  mikrotik_username = get_env("MIKROTIK_USERNAME")
  mikrotik_password = get_env("MIKROTIK_PASSWORD")
  mikrotik_insecure = true

  vlans        = local.network_config.locals.vlans
  static_dns   = local.network_config.locals.static_dns
  upstream_dns = local.network_config.locals.upstream_dns
  adlists      = local.network_config.locals.adlists

  # Interface Lists - WAN interfaces for router-base
  wan_interfaces = ["ether1", "ether2"]

  # WiFi Passwords
  hc_uuid               = get_env("HC_UUID")
  trusted_wifi_password = get_env("TRUSTED_WIFI_PASSWORD")
  guest_wifi_password   = get_env("GUEST_WIFI_PASSWORD")
  iot_wifi_password     = get_env("IOT_WIFI_PASSWORD")
}
