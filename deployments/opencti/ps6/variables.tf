variable "juju_model_name" {
  description = "Juju model for OpenCTI"
  type        = string
}

variable "juju_model_uuid" {
  description = "Juju model UUID for OpenCTI"
  type        = string
}

variable "juju_db_model_name" {
  description = "Juju model for OpenCTI DB"
  type        = string
}

variable "juju_db_model_uuid" {
  description = "Juju model UUID for OpenCTI DB"
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

variable "opencti_consumers" {
  description = "List of models that consume the OpenCTI offer"
  type        = list(string)
}

variable "opencti_external_hostname" {
  description = "The external hostname for OpenCTI"
  type        = string
}

variable "opensearch_config" {
  description = "OpenSearch configuration"
  type        = map(string)
  default     = {}
}

variable "opensearch_constraints" {
  description = "OpenSearch constraints"
  type        = string
}

variable "prometheus_metrics_endpoint_offer_url" {
  description = "Prometheus metrics offer URL"
  type        = string
}

variable "prometheus_remote_write_offer_url" {
  description = "Prometheus removete write offer URL"
  type        = string
}

variable "rabbitmq_constraints" {
  description = "RabbitMQ constraints"
  type        = string
}

variable "redis_storage" {
  description = "Redis storage"
  type        = string
}
