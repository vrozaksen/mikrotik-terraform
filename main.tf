# =================================================================================================
# Provider Configuration
# =================================================================================================
terraform {
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.81.0"
    }
  }
}

# =================================================================================================
# Local/Static Configuration
# =================================================================================================
locals {
  timezone       = "Europe/Warsaw"
  cloudflare_ntp = "time.cloudflare.com"

  upstream_dns = ["1.1.1.1", "1.0.0.1"]
  adlists = {
    # Firebog https://firebog.net/
    # Suspicious Lists
    "PolishFiltersTeam_KADhosts" = { url = "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt" }
    "FadeMind_Spam"              = { url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts" }
    # Advertising Lists
    "AdAway"       = { url = "https://adaway.org/hosts.txt" }
    "Anudeep"      = { url = "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt" }
    "PeterLowe"    = { url = "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext" }
    "Fademind_ADs" = { url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts" }
    "hostsVN"      = { url = "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts" }
    # Tracking & Telemetry Lists
    "Fademind2o7"     = { url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts" }
    "CrazyMax"        = { url = "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt" }
    "GeoffreyFrogeye" = { url = "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt" }
    # Malicious Lists
    "DandelionSprout" = { url = "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt" }
    "FademindRisky"   = { url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts" }
    "URLhaus"         = { url = "https://urlhaus.abuse.ch/downloads/hostfile/" }
    # Other
    "DanPollock"        = { url = "https://someonewhocares.org/hosts/hosts" }
    "Steven_Black"      = { url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" }
    "POL_Cert"          = { url = "https://hole.cert.pl/domains/domains_hosts.txt" }
    "Lightswitch05_AT"  = { url = "https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt" }
    "Lightswitch05_AMP" = { url = "https://www.github.developerdan.com/hosts/lists/amp-hosts-extended.txt" }
  }
  static_dns = {
    "router.home.vzkn.eu"  = { address = "10.10.0.1", type = "A", comment = "RB5009" },
    "aincrad.home.vzkn.eu" = { address = "10.10.0.11", type = "A", comment = "Aincrad-NAS" },
    "caddy.home.vzkn.eu"   = { address = "10.10.0.11", type = "A", comment = "Aincrad-Caddy" },
    "s3.vzkn.eu"           = { address = "10.10.0.11", type = "A", comment = "Aincrad-Minio" },
    "s3c.vzkn.eu"          = { address = "10.10.0.11", type = "A", comment = "Aincrad-MinioA" },
    "slzb.home.vzkn.eu"    = { address = "10.10.0.65", type = "A", comment = "SLZB" },
    "stash.vzkn.eu"        = { address = "10.10.0.11", type = "A", comment = "Aincrad-Stash" },
  }

  all_vlans = [for vlan in local.vlans : vlan.name]
  vlans = {
    "Servers" = {
      name        = "Servers"
      vlan_id     = 10
      network     = "10.10.0.0"
      cidr_suffix = "24"
      gateway     = "10.10.0.1"
      dhcp_pool   = ["10.10.0.195-10.10.0.199"]
      dns_servers = ["10.10.0.1"]
      domain      = "srv.h.vzkn.eu"
      static_leases = {
        # "10.10.0.2"   = { name = "CRS317", mac = "" }
        # "10.10.0.3"   = { name = "CRS326", mac = "" }
        # "10.10.0.4"   = { name = "hex", mac = "" }
        # "10.10.0.5"   = { name = "cAP-AX", mac = "" }
        "10.10.0.8"  = { name = "HORRACO", mac = "1C:2A:A3:1E:5B:5A" }
        "10.10.0.9"  = { name = "EAP620", mac = "10:27:F5:33:9A:B2" }
        "10.10.0.11" = { name = "aincrad", mac = "E0:D5:5E:E2:3D:82" }
        "10.10.0.21" = { name = "alfheim", mac = "00:E0:4C:68:07:2C" }
        "10.10.0.22" = { name = "alne", mac = "00:E0:4C:68:07:B6" }
        "10.10.0.23" = { name = "ainias", mac = "00:E0:4C:68:0B:53" }
        "10.10.0.65" = { name = "slzb", mac = "F4:65:0B:44:F3:EB" }
      }
    },
    "IoT" = {
      name        = "IoT"
      vlan_id     = 20
      network     = "10.20.0.0"
      cidr_suffix = "24"
      gateway     = "10.20.0.1"
      dhcp_pool   = ["10.20.0.10-10.20.0.200"]
      dns_servers = ["10.20.0.1"]
      domain      = "iot.h.vzkn.eu"
      static_leases = {
        "10.20.0.250" = { name = "Chromecast", mac = "DC:E5:5B:8B:E4:EB" }
      }
    },
    # "Security" = {
    #   name          = "Security"
    #   vlan_id       = 30
    #   network       = "10.30.0.0"
    #   cidr_suffix   = "24"
    #   gateway       = "10.30.0.1"
    #   dhcp_pool     = ["10.30.0.100-10.20.0.199"]
    #   dns_servers   = ["10.30.0.1"]
    #   domain        = "sec.h.vzkn.eu"
    #   static_leases = {}
    # },
    "Guest" = {
      name          = "Guest"
      vlan_id       = 99
      network       = "10.99.0.0"
      cidr_suffix   = "24"
      gateway       = "10.99.0.1"
      dhcp_pool     = ["10.99.0.10-10.99.0.250"]
      dns_servers   = ["1.1.1.1", "1.0.0.1", "8.8.8.8"]
      domain        = "gst.h.vzkn.eu"
      static_leases = {}
    },
    "Trusted" = {
      name        = "Trusted"
      vlan_id     = 100
      network     = "10.100.0.0"
      cidr_suffix = "24"
      gateway     = "10.100.0.1"
      dhcp_pool   = ["10.100.0.100-10.100.0.199"]
      dns_servers = ["10.100.0.1"]
      domain      = "trst.h.vzkn.eu"
      static_leases = {
        "10.100.0.100" = { name = "vx-prime-cable", mac = "10:FF:E0:35:10:A4" }
        "10.100.0.101" = { name = "vx-prime-wlan", mac = "7E:F4:0F:27:F0:E8" }
        "10.100.0.102" = { name = "vx-t480-wlan", mac = "8E:80:A3:1F:3D:3B" }
      }
    }
  }
}
