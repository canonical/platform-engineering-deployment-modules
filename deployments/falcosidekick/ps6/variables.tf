variable "model_name" {
  description = "Juju model name"
  type        = string
}

variable "model_uuid" {
  description = "Juju model UUID"
  type        = string
}

variable "external_hostname" {
  description = "The external hostname for Falco sidekick"
  type        = string
}

variable "certificates_offer_url" {
  description = "Certificates offer URL"
  type        = string
}

variable "grafana_offer_url" {
  description = "Grafana offer URL"
  type        = string
}

variable "loki_offer_url" {
  description = "Loki offer URL"
  type        = string
}

variable "prometheus_metrics_endpoint_offer_url" {
  description = "Prometheus metrics offer URL"
  type        = string
}

variable "falcosidekick_http_endpoint_consumers" {
  description = "List of models that consume the Falco sidekick offer"
  type        = list(string)
}
