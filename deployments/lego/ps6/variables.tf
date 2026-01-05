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
