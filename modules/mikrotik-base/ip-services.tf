## ================================================================================================
## IP Services Configuration
## https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_service
## ================================================================================================
locals {
  tls_service     = { "api-ssl" = 8729, "www-ssl" = 443 }
  disable_service = { "ftp" = 21, "telnet" = 23, "www" = 80 }
  enable_service  = { "winbox" = 8291, "api" = 8728, "ssh" = 22 }
}


## ================================================================================================
## Enable/Disable Services
## ================================================================================================
resource "routeros_ip_service" "disabled" {
  for_each = local.disable_service
  numbers  = each.key
  port     = each.value
  disabled = true
}

moved {
  from = routeros_ip_service.disabled["api"]
  to   = routeros_ip_service.enabled["api"]
}

moved {
  from = routeros_ip_service.disabled["ssh"]
  to   = routeros_ip_service.enabled["ssh"]
}

resource "routeros_ip_service" "enabled" {
  for_each = local.enable_service
  numbers  = each.key
  port     = each.value
  disabled = false
}


## ================================================================================================
## TLS Services
## ================================================================================================
resource "routeros_ip_service" "ssl" {
  for_each    = local.tls_service
  numbers     = each.key
  port        = each.value
  tls_version = "only-1.2"
  disabled    = false
  #  certificate = routeros_system_certificate.webfig.name
  certificate = var.tls_certificate != null ? var.tls_certificate : routeros_system_certificate.webfig.name
}
