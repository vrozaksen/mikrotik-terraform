# =================================================================================================
# DNS Configuration
# =================================================================================================
resource "routeros_ip_dns" "dns" {
  allow_remote_requests = true
  servers               = var.upstream_dns
}

resource "routeros_ip_dns_adlist" "adlists" {
  for_each = var.adlists
  url      = each.value.url
}

# =================================================================================================
# Static DNS Records
# =================================================================================================
resource "routeros_ip_dns_record" "static" {
  for_each = var.static_dns

  name    = each.key
  comment = each.value.comment
  address = lookup(each.value, "address", null)
  cname   = lookup(each.value, "cname", null)
  type    = each.value.type
}
