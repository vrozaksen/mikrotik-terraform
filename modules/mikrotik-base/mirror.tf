# =================================================================================================
# Port mirroring (Marvell 88E6393X)
# The chip has no switch-level mirror-target; the target is set per source port.
# Ingress-only is deliberate: every packet crossing the router enters on exactly
# one port, so mirroring ingress on each source captures it once, without the
# duplicates egress mirroring would add.
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_ethernet_switch_port
# =================================================================================================
resource "routeros_interface_ethernet_switch_port" "mirror_source" {
  for_each = var.mirror_target == "" ? toset([]) : toset(var.mirror_sources)

  name                  = each.value
  mirror_ingress        = true
  mirror_ingress_target = var.mirror_target
}
