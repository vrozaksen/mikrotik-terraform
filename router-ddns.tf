# DDNS
resource "routeros_ip_cloud" "cloud" {
  provider             = routeros.rb5009
  ddns_enabled         = "yes"
  update_time          = true
  ddns_update_interval = "1m"
}

resource "cloudflare_dns_record" "ddns_vpn" {
  for_each = {
    main      = data.cloudflare_zone.main
    #secondary = data.cloudflare_zone.secondary
  }

  zone_id = each.value.zone_id
  name    = "vpn.${each.value.name}"
  comment = "Terraform: Mikrotik DDNS for VPN"
  type    = "CNAME"
  proxied = false
  ttl     = 3600
  content = routeros_ip_cloud.cloud.dns_name
}

resource "cloudflare_dns_record" "ddns_ipv4" {
  for_each = {
    main      = data.cloudflare_zone.main
    #secondary = data.cloudflare_zone.secondary
  }

  zone_id = each.value.zone_id
  name    = "ipv4.${each.value.name}"
  comment = "Terraform: Mikrotik DDNS for ipv4 subdomain"
  type    = "CNAME"
  proxied = false
  ttl     = 3600
  content = routeros_ip_cloud.cloud.dns_name
}