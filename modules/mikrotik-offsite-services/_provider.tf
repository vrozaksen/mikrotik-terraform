# =================================================================================================
# Terraform & Provider Configuration
# =================================================================================================
terraform {
  required_version = ">= 1.0"
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.98.0"
    }
  }
}

variable "mikrotik_hostname" { type = string }
variable "mikrotik_username" { type = string }
variable "mikrotik_password" {
  type      = string
  sensitive = true
}
variable "mikrotik_insecure" {
  type    = bool
  default = true
}

provider "routeros" {
  hosturl  = var.mikrotik_hostname
  username = var.mikrotik_username
  password = var.mikrotik_password
  insecure = var.mikrotik_insecure
}
