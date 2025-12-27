## ================================================================================================
## Network Configuration Variables
## ================================================================================================
variable "vlans" {
  type = map(object({
    name        = string
    vlan_id     = number
    network     = string
    cidr_suffix = string
    gateway     = string
    dhcp_pool   = list(string)
    dns_servers = list(string)
    domain      = string
    mtu         = optional(number, 1500)
    static_leases = map(object({
      name = string
      mac  = string
    }))
  }))
  default     = {}
  description = "Map of VLANs to configure"
}

variable "static_dns" {
  type = map(object({
    address         = optional(string)
    cname           = optional(string)
    match_subdomain = optional(bool, false)
    comment         = string
    type            = string
  }))
  default     = {}
  description = "Map of static DNS records"
}

variable "upstream_dns" {
  type        = list(string)
  description = "List of upstream DNS servers"
}

variable "adlists" {
  type = map(object({
    url = string
  }))
  description = "Map of adblock lists for DNS"
  default     = {}
}

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


# =================================================================================================
# Interface Lists
# =================================================================================================
variable "wan_interfaces" {
  type        = list(string)
  default     = []
  description = "List of WAN interface names to add to WAN interface list"
}
