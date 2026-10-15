# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.

output "mattermost" {
  description = "Mattermost application name and required endpoints."
  value       = module.mattermost.mattermost
}

output "postgresql_app_name" {
  description = "Name of the bundled PostgreSQL application, if deployed."
  value       = module.mattermost.postgresql_app_name
}

output "oauth_app_name" {
  description = "Name of the OAuth external IdP integrator application."
  value       = module.mattermost.oauth_app_name
}
