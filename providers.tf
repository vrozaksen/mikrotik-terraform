# =================================================================================================
# Provider Configuration
# =================================================================================================
terraform {
  required_version = "v1.12.1"
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.85.3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.5.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# =================================================================================================
# Cloudflare Zones
# =================================================================================================
data "cloudflare_zone" "main" {
  filter = {
    name   = "vzkn.eu"
    status = "active"
  }
}
# data "cloudflare_zone" "secondary" {
#   filter = {
#     name   = "vzkn.eu"
#     status = "active"
#   }
# }