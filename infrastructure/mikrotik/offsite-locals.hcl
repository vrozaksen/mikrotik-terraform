locals {
  timezone       = "Europe/Warsaw"
  cloudflare_ntp = "time.cloudflare.com"

  upstream_dns = ["1.1.1.1", "1.0.0.1"]
  # Firebog https://firebog.net/
  adlists = {
    "PolishFiltersTeam_KADhosts" = { url = "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt" }
    "FadeMind_Spam"              = { url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts" }
    "AdAway"                     = { url = "https://adaway.org/hosts.txt" }
    "Anudeep"                    = { url = "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt" }
    "PeterLowe"                  = { url = "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext" }
    "Fademind_ADs"               = { url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts" }
    "hostsVN"                    = { url = "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts" }
    "Fademind2o7"                = { url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts" }
    "CrazyMax"                   = { url = "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt" }
    "GeoffreyFrogeye"            = { url = "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt" }
    "DandelionSprout"            = { url = "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt" }
    "FademindRisky"              = { url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts" }
    "URLhaus"                    = { url = "https://urlhaus.abuse.ch/downloads/hostfile" }
    "DanPollock"                 = { url = "https://someonewhocares.org/hosts/hosts" }
    "Steven_Black"               = { url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" }
    "POL_Cert"                   = { url = "https://hole.cert.pl/domains/domains_hosts.txt" }
    "Lightswitch05_AT"           = { url = "https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt" }
    "Lightswitch05_AMP"          = { url = "https://www.github.developerdan.com/hosts/lists/amp-hosts-extended.txt" }
  }

  all_vlans = [for vlan in local.vlans : vlan.name]
  vlans = {
    "Servers" = {
      name          = "Servers"
      vlan_id       = 10
      network       = "10.11.10.0"
      cidr_suffix   = "24"
      gateway       = "10.11.10.1"
      dhcp_pool     = ["10.11.10.100-10.11.10.200"]
      dns_servers   = ["10.11.10.1"]
      domain        = "srv.offsite.h.vzkn.eu"
      static_leases = {}
    }
    "Guest" = {
      name          = "Guest"
      vlan_id       = 99
      network       = "10.11.99.0"
      cidr_suffix   = "24"
      gateway       = "10.11.99.1"
      dhcp_pool     = ["10.11.99.100-10.11.99.200"]
      dns_servers   = ["1.1.1.1", "1.0.0.1"]
      domain        = "guest.offsite.h.vzkn.eu"
      static_leases = {}
    }
    "Trusted" = {
      name          = "Trusted"
      vlan_id       = 100
      network       = "10.11.100.0"
      cidr_suffix   = "24"
      gateway       = "10.11.100.1"
      dhcp_pool     = ["10.11.100.100-10.11.100.200"]
      dns_servers   = ["10.11.100.1"]
      domain        = "trusted.offsite.h.vzkn.eu"
      static_leases = {}
    }
  }
}
