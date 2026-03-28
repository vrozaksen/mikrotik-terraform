include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "dependency_router" {
  path = find_in_parent_folders("ovh/dependency.hcl")
}

terraform {
  source = find_in_parent_folders("modules/ovh-cname")
}

inputs = {
  zone      = "vzkn.eu"
  subdomain = "ipv4"
  target    = dependency.router.outputs.ddns_hostname
}
