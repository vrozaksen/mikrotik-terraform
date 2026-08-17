# =================================================================================================
# Remote syslog
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_logging_action
# =================================================================================================
resource "routeros_system_logging_action" "remote" {
  count = var.syslog_remote == "" ? 0 : 1

  name            = "siem"
  target          = "remote"
  remote          = var.syslog_remote
  remote_port     = var.syslog_remote_port
  remote_protocol = "udp"
  syslog_facility = "local0"
  # BSD format carries no hostname, so both devices arrive indistinguishable.
  remote_log_format = "syslog"
}

# =================================================================================================
# Which topics get shipped. Deliberately narrow: `account` carries login/logout,
# the rest are faults. `info` is intentionally excluded — it is mostly chatter.
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_logging
# =================================================================================================
resource "routeros_system_logging" "remote" {
  for_each = var.syslog_remote == "" ? toset([]) : toset(var.syslog_topics)

  action = routeros_system_logging_action.remote[0].name
  topics = [each.value]
}
