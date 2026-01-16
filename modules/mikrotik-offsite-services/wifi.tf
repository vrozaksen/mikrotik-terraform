# =================================================================================================
# WiFi Security
# =================================================================================================
resource "routeros_wifi_security" "trusted" {
  name                 = "trusted-security"
  authentication_types = ["wpa2-psk", "wpa3-psk"]
  passphrase           = var.trusted_wifi_password
}

resource "routeros_wifi_security" "guest" {
  name                 = "guest-security"
  authentication_types = ["wpa2-psk", "wpa3-psk"]
  passphrase           = var.guest_wifi_password
}

# =================================================================================================
# WiFi Datapath (VLAN tagging)
# =================================================================================================
resource "routeros_wifi_datapath" "trusted" {
  count = lookup(var.vlans, "Trusted", null) != null ? 1 : 0

  name    = "trusted-datapath"
  bridge  = "bridge"
  vlan_id = var.vlans["Trusted"].vlan_id
}

resource "routeros_wifi_datapath" "guest" {
  count = lookup(var.vlans, "Guest", null) != null ? 1 : 0

  name             = "guest-datapath"
  bridge           = "bridge"
  vlan_id          = var.vlans["Guest"].vlan_id
  client_isolation = true
}

# =================================================================================================
# WiFi Channels
# =================================================================================================
resource "routeros_wifi_channel" "ch_2ghz" {
  name = "2ghz-ax"
  band = "2ghz-ax"
}

# =================================================================================================
# WiFi Configurations (2.4GHz only - hAP ax lite has single radio)
# =================================================================================================
resource "routeros_wifi_configuration" "trusted" {
  count = lookup(var.vlans, "Trusted", null) != null ? 1 : 0

  name    = var.trusted_wifi_ssid
  ssid    = var.trusted_wifi_ssid
  country = "Poland"

  channel  = { config = routeros_wifi_channel.ch_2ghz.name }
  datapath = { config = routeros_wifi_datapath.trusted[0].name }
  security = { config = routeros_wifi_security.trusted.name }
}

resource "routeros_wifi_configuration" "guest" {
  count = lookup(var.vlans, "Guest", null) != null ? 1 : 0

  name    = var.guest_wifi_ssid
  ssid    = var.guest_wifi_ssid
  country = "Poland"

  channel  = { config = routeros_wifi_channel.ch_2ghz.name }
  datapath = { config = routeros_wifi_datapath.guest[0].name }
  security = { config = routeros_wifi_security.guest.name }
}

# =================================================================================================
# WiFi Interfaces
# hAP ax lite: wifi1 = 2.4GHz only (no 5GHz radio)
# =================================================================================================
resource "routeros_wifi" "wifi1" {
  count = lookup(var.vlans, "Trusted", null) != null ? 1 : 0

  name    = "wifi1"
  comment = "2.4GHz Radio"
  configuration = {
    config = routeros_wifi_configuration.trusted[0].name
  }
  disabled = false
}

# Virtual AP for Guest
resource "routeros_wifi" "wifi1_guest" {
  count = lookup(var.vlans, "Guest", null) != null ? 1 : 0

  name             = "wifi1-guest"
  comment          = "2.4GHz Guest"
  master_interface = routeros_wifi.wifi1[0].name
  configuration = {
    config = routeros_wifi_configuration.guest[0].name
  }
  disabled = false
}

