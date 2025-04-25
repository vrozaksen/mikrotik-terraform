# =================================================================================================
# CAPsMAN Settings
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_capsman
# =================================================================================================
resource "routeros_wifi_capsman" "settings" {
  provider                 = routeros.rb5009
  enabled                  = true
  interfaces               = ["all"]
  upgrade_policy           = "none"
  require_peer_certificate = false
}

# =================================================================================================
# WiFi Channels
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_channel
# =================================================================================================
resource "routeros_wifi_channel" "slow" {
  provider = routeros.rb5009
  name     = "2.4ghz"
  band     = "2ghz-ax"
}
resource "routeros_wifi_channel" "fast" {
  provider = routeros.rb5009
  name     = "5ghz"
  band     = "5ghz-ax"
}

# =================================================================================================
# WiFi Security
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_security
# =================================================================================================
resource "routeros_wifi_security" "trusted_wifi_password" {
  provider             = routeros.rb5009
  name                 = "trusted-wifi-password"
  authentication_types = ["wpa2-psk", "wpa3-psk"]
  passphrase           = var.trusted_wifi_password
}
resource "routeros_wifi_security" "guest_wifi_password" {
  provider             = routeros.rb5009
  name                 = "guest-wifi-password"
  authentication_types = ["wpa2-psk", "wpa3-psk"]
  passphrase           = var.guest_wifi_password
}
resource "routeros_wifi_security" "iot_wifi_password" {
  provider             = routeros.rb5009
  name                 = "iot-wifi-password"
  authentication_types = ["wpa2-psk", "wpa3-psk"]
  passphrase           = var.iot_wifi_password
}

# =================================================================================================
# WiFi Datapath
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_datapath
# =================================================================================================
resource "routeros_wifi_datapath" "trusted_tagging" {
  provider = routeros.rb5009
  name     = "trusted-tagging"
  comment  = "WiFi -> Trusted VLAN"
  vlan_id  = local.vlans.Trusted.vlan_id
}
resource "routeros_wifi_datapath" "guest_tagging" {
  provider         = routeros.rb5009
  name             = "guest-tagging"
  comment          = "WiFi -> Guest VLAN"
  vlan_id          = local.vlans.Guest.vlan_id
  client_isolation = true
}
resource "routeros_wifi_datapath" "iot_tagging" {
  provider = routeros.rb5009
  name     = "iot-tagging"
  comment  = "WiFi -> IoT VLAN"
  vlan_id  = local.vlans.IoT.vlan_id
}

# =================================================================================================
# WiFi Configurations
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_configuration
# =================================================================================================
resource "routeros_wifi_configuration" "guest" {
  provider = routeros.rb5009
  country  = "Poland"
  name     = "VZKN_GUEST"
  ssid     = "VZKN_GUEST"
  comment  = ""

  channel = {
    config = routeros_wifi_channel.slow.name
  }
  datapath = {
    config = routeros_wifi_datapath.guest_tagging.name
  }
  security = {
    config = routeros_wifi_security.guest_wifi_password.name
  }
}
resource "routeros_wifi_configuration" "iot" {
  provider = routeros.rb5009
  country  = "Poland"
  name     = "VZKN_IOT"
  ssid     = "VZKN_IOT"
  comment  = ""

  channel = {
    config = routeros_wifi_channel.slow.name
  }
  datapath = {
    config = routeros_wifi_datapath.iot_tagging.name
  }
  security = {
    config = routeros_wifi_security.iot_wifi_password.name
  }
}
resource "routeros_wifi_configuration" "trusted_slow" {
  provider = routeros.rb5009
  country  = "Poland"
  name     = "VZKN_END_2.4G"
  ssid     = "VZKN_END_2.4G"
  comment  = ""

  channel = {
    config = routeros_wifi_channel.slow.name
  }
  datapath = {
    config = routeros_wifi_datapath.trusted_tagging.name
  }
  security = {
    config = routeros_wifi_security.trusted_wifi_password.name
  }
}
resource "routeros_wifi_configuration" "trusted_fast" {
  provider = routeros.rb5009
  country  = "Poland"
  name     = "VZKN_END_5G"
  ssid     = "VZKN_END_5G"
  comment  = ""


  channel = {
    config = routeros_wifi_channel.fast.name
  }
  datapath = {
    config = routeros_wifi_datapath.trusted_tagging.name
  }
  security = {
    config = routeros_wifi_security.trusted_wifi_password.name
  }
}

# =================================================================================================
# WiFi Provisioning
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_provisioning
# =================================================================================================
resource "routeros_wifi_provisioning" "slow" {
  provider             = routeros.rb5009
  action               = "create-dynamic-enabled"
  comment              = routeros_wifi_configuration.trusted_slow.name
  supported_bands      = [routeros_wifi_channel.slow.band]
  master_configuration = routeros_wifi_configuration.trusted_slow.name
  slave_configurations = [
    routeros_wifi_configuration.guest.name,
    routeros_wifi_configuration.iot.name
  ]
}
resource "routeros_wifi_provisioning" "fast" {
  provider             = routeros.rb5009
  action               = "create-dynamic-enabled"
  comment              = routeros_wifi_configuration.trusted_fast.name
  supported_bands      = [routeros_wifi_channel.fast.band]
  master_configuration = routeros_wifi_configuration.trusted_fast.name
  slave_configurations = []
}
