# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.

output "indico" {
  description = "Indico application name and relation endpoints."
  value       = module.indico.applications.indico
}

output "model_uuid" {
  description = "UUID of the Juju model the applications are deployed into."
  value       = module.indico.model_uuid
}

output "ingress_configurator_app_name" {
  description = "Name of the ingress-configurator application."
  value       = juju_application.ingress_configurator.name
}
