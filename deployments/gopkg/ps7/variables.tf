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

variable "loki_offer_url" {
  description = "Loki offer URL for gopkg to push logs to"
  type        = string
}

variable "prometheus_offer_url" {
  description = "Prometheus offer URL for gopkg's metrics-endpoint. Required: on PS7 the COS model offers prometheus-metrics-endpoint (requirer, prometheus_scrape)."
  type        = string
}

variable "grafana_dashboard_offer_url" {
  description = "Grafana offer URL for gopkg's grafana-dashboard endpoint. Required: on PS7 the COS model offers grafana-dashboards (requirer, grafana_dashboard). The charm ships its own dashboard and alert rules, which reach Grafana only over this relation."
  type        = string
}
