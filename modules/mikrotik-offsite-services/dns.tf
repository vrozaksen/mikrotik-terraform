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
