include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  mikrotik_hostname = "10.11.10.1"
  offsite_locals    = read_terragrunt_config(find_in_parent_folders("offsite-locals.hcl")).locals
}

terraform {
  source = find_in_parent_folders("modules/mikrotik-offsite-services")
}

inputs = {
  mikrotik_hostname = "https://${local.mikrotik_hostname}"
  mikrotik_username = get_env("MIKROTIK_USERNAME")
  mikrotik_password = get_env("MIKROTIK_PASSWORD")
  mikrotik_insecure = true

  # VLANs
  vlans = local.offsite_locals.vlans

  # DNS
  upstream_dns = local.offsite_locals.upstream_dns
  adlists      = local.offsite_locals.adlists
  static_dns = {
    "external.vzkn.eu" = {
      type    = "A"
      address = "10.10.0.91"
      comment = "Homelab envoy external"
    }
    "requests.vzkn.eu" = {
      type    = "CNAME"
      cname   = "external.vzkn.eu"
      comment = "Requests via envoy"
    }
    "emby.vzkn.eu" = {
      type    = "CNAME"
      cname   = "external.vzkn.eu"
      comment = "Emby via envoy"
    }
  }

  # WireGuard
  wireguard_address = "10.255.0.100/24"
  wireguard_remote_networks = {
    "homelab-servers"  = "10.10.0.0/24"
    "homelab-vx-prime" = "10.100.0.100/30"  # .100-.103 (cable, wlan, 10g-1, 10g-2)
  }

  # Allowed hosts in remote homelab (firewall whitelist)
  homelab_allowed_hosts = {
    "router"         = "10.10.0.1"
    "envoy-external" = "10.10.0.91"
  }

  # WiFi
  trusted_wifi_ssid     = "VZKN_M_END"
  trusted_wifi_password = get_env("OFFSITE_TRUSTED_WIFI_PASSWORD", "changeme")
  guest_wifi_ssid       = "VZKN_M_GUEST"
  guest_wifi_password   = get_env("OFFSITE_GUEST_WIFI_PASSWORD", "changeme")

  # QoS - LTE bufferbloat mitigation
  qos_enabled       = true
  qos_download_mbps = 71
  qos_upload_mbps   = 24

  # Healthcheck
  hc_uuid = get_env("HC_OFFSITE")
}
