# =================================================================================================
# VLAN Configuration (passed from parent)
# =================================================================================================
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
  description = "Map of VLANs to configure"
}

# =================================================================================================
# DNS Configuration
# =================================================================================================
variable "upstream_dns" {
  type        = list(string)
  default     = ["1.1.1.1", "1.0.0.1"]
  description = "Upstream DNS servers"
}

variable "adlists" {
  type = map(object({
    url = string
  }))
  default     = {}
  description = "Adblock lists"
}

# =================================================================================================
# WireGuard Configuration
# =================================================================================================
variable "wireguard_address" {
  type        = string
  description = "WireGuard interface address"
}

variable "wireguard_remote_networks" {
  type        = map(string)
  default     = {}
  description = "Remote networks reachable via WireGuard (name => CIDR)"
}

# =================================================================================================
# WiFi Configuration
# =================================================================================================
variable "trusted_wifi_ssid" {
  type        = string
  description = "Trusted WiFi SSID"
}

variable "trusted_wifi_password" {
  type        = string
  sensitive   = true
  description = "Trusted WiFi password"
}

variable "guest_wifi_ssid" {
  type        = string
  description = "Guest WiFi SSID"
}

variable "guest_wifi_password" {
  type        = string
  sensitive   = true
  description = "Guest WiFi password"
}

# =================================================================================================
# QoS Configuration
# =================================================================================================
variable "qos_enabled" {
  type        = bool
  default     = false
  description = "Enable QoS with fq_codel for bufferbloat mitigation"
}

variable "qos_download_mbps" {
  type        = number
  default     = 100
  description = "WAN download speed in Mbps"
}

variable "qos_upload_mbps" {
  type        = number
  default     = 50
  description = "WAN upload speed in Mbps"
}
