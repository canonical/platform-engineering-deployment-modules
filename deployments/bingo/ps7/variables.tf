# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

variable "model_uuid" {
  description = "Juju model UUID"
  type        = string
}

variable "deploy_postgresql" {
  description = "Whether to deploy the bundled postgresql-k8s charm. Set to false to integrate an external PostgreSQL (e.g. a DBaaS offer) in the consuming deployment."
  type        = bool
  default     = true
}

variable "bingo_config" {
  description = "bingo charm configuration (base-url, max-paste-size-bytes, log-level, web-dir, oauth-redirect-path, oauth-scopes, oauth-user-name-attribute)."
  type        = map(string)
  default     = {}
}

variable "bingo_units" {
  description = "Number of bingo units to deploy."
  type        = number
  default     = 1
}

variable "postgresql_config" {
  description = "PostgreSQL K8s charm configuration."
  type        = map(string)
  default     = {}
}

variable "postgresql_units" {
  description = "Number of PostgreSQL units to deploy."
  type        = number
  default     = 1
}

variable "oauth_config" {
  description = "oauth-external-idp-integrator charm configuration (issuer_url, client_id, client_secret, scope, etc.). Marked sensitive because it carries the IdP client secret."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "external_hostname" {
  description = "External hostname to expose bingo on via the ingress (e.g. paste-ps7.pfe.staging.canonical.com)."
  type        = string
}

variable "haproxy_offer_url" {
  description = "Juju offer URL of the HAProxy ingress that the ingress-configurator integrates with over the haproxy-route relation."
  type        = string
}
