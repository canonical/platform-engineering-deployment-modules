# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

variable "model_uuid" {
  description = "Juju model UUID"
  type        = string
}

variable "external_hostname" {
  description = "Public hostname for gopkg. Configured on ingress-configurator and threaded into gopkg's hostname config."
  type        = string

  validation {
    condition     = !can(regex("https?://|/", var.external_hostname))
    error_message = "external_hostname must be a bare host or host:port (no scheme or path)."
  }
}

variable "gopkg_config" {
  description = "gopkg charm configuration. `hostname` is set from external_hostname; other keys are passed through."
  type        = map(string)
  default     = {}
}

variable "gopkg_units" {
  description = "Number of gopkg units to deploy"
  type        = number
  default     = 1
}

variable "cos_aggregator_otlp_offer_url" {
  description = "COS aggregator offer URL for otlp:receive-otlp (otelcol-aggregator)."
  type        = string
}

variable "cos_aggregator_dashboards_offer_url" {
  description = "COS aggregator offer URL for grafana_dashboard:grafana-dashboards-consumer (otelcol-aggregator)."
  type        = string
}

variable "cos_aggregator_ca_cert_offer_url" {
  description = "COS aggregator offer URL for certificate_transfer:send-ca-cert (self-signed-certificates-aggregator)."
  type        = string
}

variable "opentelemetry_collector_config" {
  description = "opentelemetry-collector-k8s charm configuration, e.g. forward_alert_rules and extra_alert_labels."
  type        = map(string)
  default     = {}
}
