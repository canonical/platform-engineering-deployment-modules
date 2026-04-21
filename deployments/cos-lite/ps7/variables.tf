variable "model_uuid" {
  description = "UUID of the Juju model where the application will be deployed"
  type        = string
}

variable "external_hostname" {
  description = "Hostname to configure on the ingress configurator charm"
  type        = string
}

variable "grafana_consumers" {
  description = "List of models that consume the grafana offer"
  type        = list(string)
}

variable "loki_consumers" {
  description = "List of models that consume the loki offer"
  type        = list(string)
}

variable "remote_write_consumers" {
  description = "List of models that consume the prometheus remote_write offer"
  type        = list(string)
}

variable "metrics_endpoint_consumers" {
  description = "List of models that consume the prometheus metrics_endpoint offer"
  type        = list(string)
}
