# =================================================================================================
# Threat intelligence — AbuseIPDB blacklist pulled from intel-hub in the cluster
# =================================================================================================
# intel-hub renders the list into a RouterOS script so the router never talks to
# AbuseIPDB directly: the blacklist quota is five calls per day per account, and
# an API key stored here would sit in clear text in every config export.
#
# The imported entries carry timeout=2d, so the list drains by itself if the
# distributor stops answering. That is deliberate — a block list nobody can
# explain, outliving the service that produced it, is worse than no list.

locals {
  # Addresses that must never be dropped even if a feed lists them. Getting this
  # wrong is not a nuisance: blacklisting the tunnel endpoint would cut every
  # externally reachable service, including the way back in to fix it.
  threat_intel_allowlist = {
    "bifrost" = { address = "145.239.84.25", comment = "VPS: towonel tunnel endpoint — losing this cuts all external access" }
    "quad9-a" = { address = "9.9.9.9", comment = "Resolver" }
    "quad9-b" = { address = "149.112.112.112", comment = "Resolver" }
  }
}

resource "routeros_ip_firewall_addr_list" "threat_intel_allowlist" {
  for_each = local.threat_intel_allowlist

  list    = "st_ti_allowlist"
  address = each.value.address
  comment = "Static: TI allowlist — ${each.value.comment}"
}

# =================================================================================================
# Fetch + import
# =================================================================================================
# The rendered script clears the list before repopulating it, so a truncated or
# empty download would strip protection rather than refresh it. intel-hub answers
# 503 until it holds a snapshot precisely so this fetch fails loudly instead.
resource "routeros_system_script" "threat_intel_fetch" {
  name                     = "threat_intel_fetch"
  dont_require_permissions = false
  policy                   = ["read", "write", "test", "policy"]

  source = <<-EOT
    :do {
      /tool fetch url="${var.threat_intel_url}" mode=http dst-path=threat-intel.rsc;
      :delay 2s;
      /import file-name=threat-intel.rsc;
      :log info "threat-intel: imported $[:len [/ip/firewall/address-list find list=abuseipdb]] addresses";
    } on-error={
      :log warning "threat-intel: fetch or import failed, existing entries keep expiring on their own";
    }
  EOT
}

resource "routeros_system_scheduler" "threat_intel_scheduler" {
  name     = "threat_intel_scheduler"
  interval = var.threat_intel_interval
  on_event = routeros_system_script.threat_intel_fetch.name
  policy   = ["read", "write", "test", "policy"]
}
