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
  description = "S3 integrator charm configuration (bucket, endpoint, region, etc.)"
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
  description = "SMTP integrator charm configuration (host, port, etc.)"
  type        = map(string)
}

variable "smtp_password" {
  description = "SMTP AUTH password. Stored as a Juju secret and referenced by smtp-integrator via password_secret."
  type        = string
  sensitive   = true
  default     = ""
}

variable "oauth_config" {
  description = "OAuth external IdP integrator charm configuration (client_id, client_secret, issuer_url, etc.)"
  type        = map(string)
  default     = {}
}
