## ================================================================================================
## Mikrotik Variables
## ================================================================================================
variable "mikrotik_username" {
  type        = string
  default     = "admin"
  description = "The username to authenticate against the RouterOS API."
}
variable "mikrotik_password" {
  type        = string
  description = "The password to authenticate against the RouterOS API."
  sensitive   = true
}

variable "snmp_contact" {
  type        = string
  description = "SNMP contact person."
  sensitive   = true
}

variable "hc_uuid" {
  type        = string
  description = "healthchecks.io UUID"
  sensitive   = true
}

# ================================================================================================
# WiFi Variables
# ================================================================================================
variable "trusted_wifi_password" {
  type        = string
  sensitive   = true
  description = "The password for the Untrusted Wi-Fi network."
}
variable "guest_wifi_password" {
  type        = string
  sensitive   = true
  description = "The password for the Guest Wi-Fi network."
}
variable "iot_wifi_password" {
  type        = string
  sensitive   = true
  description = "The password for the IoT Wi-Fi network."
}

## ================================================================================================
## Cloudflare Variables
## ================================================================================================
variable "cloudflare_api_token" {
  type        = string
  description = "The API token for Cloudflare."
  sensitive   = true
}

## ================================================================================================
## Netbox Variables
## ================================================================================================
variable "netbox_server_url" {
  type        = string
  default     = "localhost"
  description = "NetBox server URL."
}
variable "netbox_api_token" {
  type        = string
  description = "The API token for NetBox."
  sensitive   = true
}
