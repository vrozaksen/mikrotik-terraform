# =================================================================================================
# Script 
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_script
# =================================================================================================
resource "routeros_system_script" "healthcheck_script" {
  name                     = "healthcheck_ping"
  source                   = "/tool fetch duration=10 output=none http-method=post url=\"https://hc-ping.com/${var.hc_uuid}\";"
  dont_require_permissions = false
  policy                   = ["read", "write", "test"]
}

# =================================================================================================
# Scheduler
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_scheduler
# =================================================================================================
resource "routeros_system_scheduler" "healthcheck_scheduler" {
  name     = "healthcheck_scheduler"
  interval = "1m"
  on_event = routeros_system_script.healthcheck_script.name
  policy   = ["read", "write", "test"]
}
