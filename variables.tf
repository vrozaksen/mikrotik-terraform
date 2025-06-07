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
  type = string
  description = "SNMP contact person."
  sensitive   = true
}

variable "hc_uuid" {
  type = string
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
