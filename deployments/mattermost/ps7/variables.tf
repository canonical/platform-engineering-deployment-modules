# Copyright 2025 Canonical Ltd.
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

variable "mattermost_config" {
  description = "Mattermost charm configuration"
  type        = map(string)
  default     = {}
}

variable "mattermost_units" {
  description = "Number of Mattermost units to deploy"
  type        = number
  default     = 1
}

variable "postgresql_config" {
  description = "PostgreSQL charm configuration"
  type        = map(string)
  default     = {}
}

variable "postgresql_units" {
  description = "Number of PostgreSQL units to deploy"
  type        = number
  default     = 1
}

variable "s3_config" {
  description = "Environment-specific S3 integrator config (typically just `bucket`). The RadosGW `endpoint` and `region` default in the module."
  type        = map(string)
}

variable "s3_access_key" {
  description = "S3 access key for sync-s3-credentials action"
  type        = string
  sensitive   = true
}

variable "s3_secret_key" {
  description = "S3 secret key for sync-s3-credentials action"
  type        = string
  sensitive   = true
}

variable "smtp_config" {
  description = "Environment-specific SMTP integrator config (typically just `user`). The relay `host`/`port`/`auth_type`/`transport_security`/`smtp_sender` default in the module."
  type        = map(string)
}

variable "smtp_password" {
  description = "SMTP AUTH password. Stored as a Juju secret and referenced by smtp-integrator via password_secret."
  type        = string
  sensitive   = true
  default     = ""
}

variable "oauth_config" {
  description = "Environment-specific OAuth integrator config (client_id, client_secret, issuer_url and the IdP endpoints). The `scope` defaults in the module."
  type        = map(string)
  default     = {}
}

variable "external_hostname" {
  description = "External hostname to expose Mattermost on via the ingress (e.g. chat-ps7.pfe.staging.canonical.com)."
  type        = string
}

variable "haproxy_offer_url" {
  description = "Juju offer URL of the HAProxy ingress that the ingress-configurator integrates with over the haproxy-route relation."
  type        = string
}
