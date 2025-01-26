# =================================================================================================
# DNS Server
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dns
# =================================================================================================
resource "routeros_ip_dns" "dns-server" {
  allow_remote_requests = true

  servers = ["1.1.1.1", "8.8.8.8"]

  cache_size    = 2048
  cache_max_ttl = "1d"

  mdns_repeat_ifaces = [
    routeros_interface_vlan.iot.name,
    routeros_interface_vlan.untrusted.name
  ]
}

# =================================================================================================
# AdList
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dns_adlist
# =================================================================================================
resource "routeros_ip_dns_adlist" "dns_blocker" {
  disabled   = false
  url        = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
  ssl_verify = false
}


# =================================================================================================
# Static DNS Records
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dns_record
# =================================================================================================
resource "routeros_ip_dns_record" "static" {
  for_each = {
    "truenas.home.mirceanton.com" = { address = "10.0.0.245", type = "A" },
    "hass.home.mirceanton.com"    = { address = "192.168.42.253", type = "A" },
  }
  name    = each.key
  address = each.value.address
  type    = each.value.type
}