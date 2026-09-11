# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

output "components" {
  value = {
    gopkg                = module.gopkg
    ingress_configurator = module.ingress_configurator
  }
  description = "All Terraform charm modules which make up this product module"
}
