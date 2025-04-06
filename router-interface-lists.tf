import {
  to = routeros_interface_list.wan
  id = "*2000010"
}
import {
  to = routeros_interface_list.lan
  id = "*2000011"
}

import {
  to = routeros_interface_list_member.wan
  id = "*2"
}
import {
  to = routeros_interface_list_member.bridge_lan
  id = "*1"
}

# ================================================================================================
# Interface Lists
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_list
# ================================================================================================
resource "routeros_interface_list" "wan" {
  provider = routeros.rb5009
  name     = "WAN"
  comment  = "All Public-Facing Interfaces"
}
resource "routeros_interface_list" "lan" {
  provider = routeros.rb5009
  name     = "LAN"
  comment  = "All Local Interfaces"
}

# ================================================================================================
# Interface List Members
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_list_member
# ================================================================================================
resource "routeros_interface_list_member" "wan" {
  provider  = routeros.rb5009
  interface = "ether1"
  list      = routeros_interface_list.wan.name
}
resource "routeros_interface_list_member" "vlan_lan" {
  provider  = routeros.rb5009
  for_each  = local.vlans
  interface = each.value.name
  list      = routeros_interface_list.lan.name
}
resource "routeros_interface_list_member" "bridge_lan" {
  provider  = routeros.rb5009
  interface = "bridge" #?FIXME: should this be a base module output?
  list      = routeros_interface_list.lan.name
}
