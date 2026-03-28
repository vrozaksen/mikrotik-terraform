variable "zone" {
  description = "The OVH DNS zone (e.g. vzkn.eu)"
  type        = string
}

variable "subdomain" {
  description = "The subdomain/hostname part of the CNAME record"
  type        = string
}

variable "target" {
  description = "The target/destination for the CNAME record"
  type        = string
}
