# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

output "bingo" {
  description = "bingo application name and relation endpoint names."
  value       = module.bingo.bingo
}

output "postgresql_app_name" {
  description = "Name of the bundled PostgreSQL application, if deployed."
  value       = module.bingo.postgresql_app_name
}

output "oauth_app_name" {
  description = "Name of the bundled oauth-external-idp-integrator application."
  value       = module.bingo.oauth_app_name
}
