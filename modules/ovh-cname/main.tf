resource "ovh_domain_zone_record" "this" {
  zone      = var.zone
  subdomain = var.subdomain
  fieldtype = "CNAME"
  ttl       = 3600
  target    = "${var.target}."
}
