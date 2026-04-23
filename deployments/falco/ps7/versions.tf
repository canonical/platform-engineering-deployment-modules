terraform {
  required_version = ">= 1.12.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.9.0"
    }
    juju = {
      source  = "juju/juju"
      version = "~> 1.1.1"
    }
  }
}
