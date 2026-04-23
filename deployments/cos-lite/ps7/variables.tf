variable "model_uuid" {
  description = "UUID of the Juju model where the application will be deployed"
  type        = string
}

variable "external_hostname" {
  description = "Hostname to configure on the ingress configurator charm"
  type        = string
}
