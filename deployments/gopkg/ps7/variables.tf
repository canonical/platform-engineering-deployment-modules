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
  description = "COS aggregator offer for the collector's send-otlp endpoint (otlp:receive-otlp), e.g. <owner>/k8s-ps7-o11y-cos-aggregator.otelcol-aggregator. Metrics, logs and alert rules travel over it."
  type        = string
}

variable "cos_aggregator_dashboards_offer_url" {
  description = "COS aggregator offer for the collector's grafana-dashboards-provider endpoint (grafana_dashboard:grafana-dashboards-consumer). On PS7 it is the same otelcol-aggregator offer as the OTLP one. gopkg's dashboards reach Central COS Grafana only over this relation."
  type        = string
}

variable "cos_aggregator_ca_cert_offer_url" {
  description = "COS aggregator offer for the collector's receive-ca-cert endpoint (certificate_transfer:send-ca-cert), e.g. <owner>/k8s-ps7-o11y-cos-aggregator.self-signed-certificates-aggregator."
  type        = string
}

variable "opentelemetry_collector_config" {
  description = "opentelemetry-collector-k8s charm configuration. Central COS alerts need IS approval; once approved, set forward_alert_rules = \"true\" and extra_alert_labels = \"canonical_team=<team>\"."
  type        = map(string)
  default     = {}
}
