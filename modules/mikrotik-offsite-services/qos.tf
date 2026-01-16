# =================================================================================================
# QoS - CAKE with Simple Queue for bufferbloat mitigation (RouterOS 7+)
# =================================================================================================

# CAKE Queue Types
resource "routeros_queue_type" "cake_upload" {
  count = var.qos_enabled ? 1 : 0

  name            = "cake-upload"
  kind            = "cake"
  cake_diffserv   = "diffserv3"
  cake_flowmode   = "dual-srchost"
  cake_nat        = true
}

resource "routeros_queue_type" "cake_download" {
  count = var.qos_enabled ? 1 : 0

  name            = "cake-download"
  kind            = "cake"
  cake_diffserv   = "besteffort"
  cake_flowmode   = "dual-dsthost"
  cake_nat        = true
}

# Build list of all VLAN networks for QoS target
locals {
  qos_target_networks = var.qos_enabled ? [
    for vlan in var.vlans : "${vlan.network}/${vlan.cidr_suffix}"
  ] : []
}

# Simple Queue targeting all LAN networks
# Note: max-limit format is upload/download
resource "routeros_queue_simple" "wan_shaping" {
  count = var.qos_enabled ? 1 : 0

  name   = "WAN-Shaping"
  target = local.qos_target_networks

  # Limit to 85% of actual speed for bufferbloat headroom
  max_limit = "${floor(var.qos_upload_mbps * 0.85)}M/${floor(var.qos_download_mbps * 0.85)}M"

  # Use CAKE queue types: upload/download
  queue = "${routeros_queue_type.cake_upload[0].name}/${routeros_queue_type.cake_download[0].name}"

  comment = "LTE QoS - CAKE bufferbloat mitigation"
}
