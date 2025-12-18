variable "dashboard_model_uuid" {
  description = "Juju model for Wazuh Dashboard"
  type        = string
}

variable "indexer_model_uuid" {
  description = "Juju model for Wazuh Indexer"
  type        = string
}

variable "server_model_uuid" {
  description = "Juju model for Wazuh Server"
  type        = string
}

variable "grafana_offer_url" {
  description = "Grafana offer URL"
  type        = string
}

variable "logs_ca_certificate" {
  description = "CA certificate used for authenticating the log producers"
  type        = string
}

variable "loki_offer_url" {
  description = "Loki offer URL"
  type        = string
}

variable "opencti_offer_url" {
  description = "OpenCTI offer URL"
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

variable "wazuh_custom_config_repository" {
  description = "Repository URL for Wazuh confioguration"
  type        = string
}

variable "wazuh_dashboard_constraints" {
  description = "Constraints for the Wazuh Dashboard"
  type        = string
}

variable "wazuh_external_hostname" {
  description = "The external hostname for Wazuh"
  type        = string
}

variable "wazuh_indexer_config" {
  description = "PromConfig for the Wazuh Indexer"
  type        = map(string)
  default     = {}
}

variable "wazuh_indexer_constraints" {
  description = "Constraints for the Wazuh Indexer"
  type        = string
}
