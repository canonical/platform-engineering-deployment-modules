variable "model_name" {
  description = "Juju model name"
  type        = string
}

variable "model_uuid" {
  description = "Juju model UUID"
  type        = string
}

variable "loki_offer_url" {
  description = "Loki offer URL"
  type        = string
}

variable "send_loki_logs_offer_url" {
  description = "Loki offer URL for Faclo sidekick to export the logs"
  type        = string
}

variable "falcosidekick_http_endpoint_consumers" {
  description = "List of models that consume the Falco sidekick offer"
  type        = list(string)
}

variable "external_hostname" {
  description = "Hostname to configure on the ingress configurator charm"
  type        = string
}
