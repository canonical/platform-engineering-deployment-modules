# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

output "components" {
  value = {
    gopkg                   = module.gopkg
    ingress_configurator    = module.ingress_configurator
    opentelemetry_collector = juju_application.opentelemetry_collector
  }
  description = "All Terraform charm modules which make up this product module"
}
