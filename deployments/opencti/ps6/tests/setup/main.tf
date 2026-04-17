# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.

terraform {
  required_version = "~> 1.12"
  required_providers {
    juju = {
      version = "~> 1.1"
      source  = "juju/juju"
    }
  }
}

provider "juju" {}

resource "juju_model" "opencti" {
  name       = "tf-opencti-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  credential = "tfk8s"

  cloud {
    name = "tfk8s"
  }
}

resource "juju_model" "opencti_db" {
  name = "tf-opencti-db-${formatdate("YYYYMMDDhhmmss", timestamp())}"
}

output "model_uuid" {
  value = juju_model.opencti.uuid
}

output "model_name" {
  value = juju_model.opencti.name
}

output "db_model_uuid" {
  value = juju_model.opencti_db.uuid
}

output "db_model_name" {
  value = juju_model.opencti_db.name
}
