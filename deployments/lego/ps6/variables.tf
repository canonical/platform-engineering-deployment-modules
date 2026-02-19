variable "model_uuid" {
  description = "Juju model for LEGO"
  type        = string
}

variable "username" {
  description = "LEGO username"
  type        = string
}

variable "password" {
  description = "LEGO password"
  type        = string
  sensitive   = true
}

variable "lego_certificates_consumers" {
  description = "List of models that consume the Lego certificates offer"
  type        = list(string)
}
