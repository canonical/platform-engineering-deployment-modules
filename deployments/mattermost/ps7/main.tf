# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.

# This module inherits the mattermost-k8s-operator product module and pins the
# revisions/channels of every charm. It intentionally does NOT deploy ingress:
# ingress is deployment-specific and managed by the consuming deployment.
module "mattermost" {
  source     = "git::file:///home/dogay.kamar@canonical.com/Desktop/canonical-main/mattermost-k8s-operator//terraform/product"
  model_uuid = var.model_uuid

  deploy_postgresql = var.deploy_postgresql
  deploy_ingress    = false

  mattermost = {
    channel  = "latest/edge"
    revision = 34
    config   = var.mattermost_config
    units    = var.mattermost_units
  }

  postgresql = {
    channel  = "14/stable"
    revision = 774
    config   = var.postgresql_config
    units    = var.postgresql_units
  }

  s3_integrator = {
    channel    = "1/stable"
    revision   = 330
    config     = var.s3_config
    access_key = var.s3_access_key
    secret_key = var.s3_secret_key
  }

  smtp_integrator = {
    channel  = "latest/stable"
    revision = 121
    config   = var.smtp_config
  }

  self_signed_certificates = {
    channel  = "latest/stable"
    revision = 518
  }

  oauth = {
    channel  = "edge"
    revision = 6
    base     = "ubuntu@22.04"
    config   = var.oauth_config
  }
}
