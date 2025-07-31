variable "hc_uuid" {
  description = "Healthcheck UUID for hc-ping.com"
  type        = string
  default     = null
  sensitive   = true
}

variable "trusted_wifi_password" {
  description = "Password for the Trusted Wi-Fi network."
  type        = string
  default     = null
  sensitive   = true
}

variable "guest_wifi_password" {
  description = "Password for the Guest Wi-Fi network."
  type        = string
  default     = null
  sensitive   = true
}

variable "iot_wifi_password" {
  description = "Password for the IoT Wi-Fi network."
  type        = string
  default     = null
  sensitive   = true
}