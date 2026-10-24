# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.

variable "model_uuid" {
  description = "UUID of the externally provisioned Juju model."
  type        = string
}

# --- Indico -----------------------------------------------------------------
variable "indico_app_name" {
  description = "Name of the Indico application in the Juju model."
  type        = string
  default     = "indico"
}

variable "indico_channel" {
  description = "Charm channel for the indico charm."
  type        = string
  default     = "latest/edge"
}

variable "indico_revision" {
  description = "Charm revision for the indico charm."
  type        = number
}

variable "indico_units" {
  description = "Number of Indico units to deploy."
  type        = number
  default     = 2
}

variable "indico_constraints" {
  description = "Juju constraints for the Indico application. Includes a memory limit so a runaway workload pod is contained (OOM-killed) instead of exhausting the K8s node."
  type        = string
  default     = "arch=amd64 mem=2048M"
}

variable "indico_config" {
  description = "Configuration for the indico charm (site_url, external_plugins, indico_*_email, enabled-plugins, local-identities, ...)."
  type        = map(string)
  default     = {}
}

# --- Database ---------------------------------------------------------------
variable "deploy_postgresql" {
  description = "Whether to deploy the bundled postgresql-k8s charm. Set to false to integrate an external managed PostgreSQL (DBaaS) via postgresql_offer_url."
  type        = bool
  default     = true
}

variable "postgresql_offer_url" {
  description = "Cross-model offer URL of an external managed PostgreSQL (used only when deploy_postgresql = false)."
  type        = string
  default     = ""
}

variable "postgresql_config" {
  description = "Configuration for the bundled postgresql-k8s charm. Indico requires the pg_trgm and unaccent extensions."
  type        = map(string)
  default = {
    plugin_pg_trgm_enable  = "true"
    plugin_unaccent_enable = "true"
  }
}

# --- S3 (media storage) -----------------------------------------------------
variable "s3_config" {
  description = "S3 integrator charm configuration (bucket, endpoint, region, s3-uri-style, ...)."
  type        = map(string)
}

variable "s3_access_key" {
  description = "S3 access key, synced to s3-integrator via the sync-s3-credentials action."
  type        = string
  sensitive   = true
}

variable "s3_secret_key" {
  description = "S3 secret key, synced to s3-integrator via the sync-s3-credentials action."
  type        = string
  sensitive   = true
}

# --- SMTP -------------------------------------------------------------------
variable "smtp_config" {
  description = "SMTP integrator charm configuration (host, port, user, auth_type, transport_security, password, ...)."
  type        = map(string)
  sensitive   = true
}

# --- OIDC / OAuth -----------------------------------------------------------
variable "oauth_config" {
  description = "oauth-external-idp-integrator charm configuration (client_id, client_secret, issuer_url, and OIDC endpoints)."
  type        = map(string)
  default     = {}
  sensitive   = true
}

# --- Observability (optional COS offers) ------------------------------------
variable "prometheus_offer_url" {
  description = "Cross-model offer URL for Prometheus (metrics-endpoint). Empty disables the integration."
  type        = string
  default     = ""
}

variable "grafana_offer_url" {
  description = "Cross-model offer URL for Grafana (grafana-dashboard). Empty disables the integration."
  type        = string
  default     = ""
}

# --- Ingress (owned by this layer) ------------------------------------------
variable "external_hostname" {
  description = "External hostname served by the ingress (e.g. events-ps7.pfe.staging.canonical.com)."
  type        = string
}

variable "haproxy_offer_url" {
  description = "Cross-model offer URL of the shared PS7 HAProxy ingress (haproxy-route)."
  type        = string
}

variable "ingress_configurator_app_name" {
  description = "Name of the ingress-configurator application."
  type        = string
  default     = "ingress-configurator"
}

variable "ingress_configurator_channel" {
  description = "Charm channel for ingress-configurator."
  type        = string
  default     = "latest/edge"
}

variable "ingress_configurator_revision" {
  description = "Charm revision for ingress-configurator."
  type        = number
  default     = 72
}

variable "ingress_configurator_config" {
  description = "Extra ingress-configurator config merged on top of {hostname}. Deployment-specific (e.g. header-rewrite-expressions, path-routes)."
  type        = map(string)
  default     = {}
}
