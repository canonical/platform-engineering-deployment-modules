# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

# This module wraps the bingo product module and pins the revisions/channels
# of every bundled charm for the PS7 stack. It intentionally does NOT deploy
# ingress: ingress is deployment-specific and managed by the consuming
# deployment (see Layer 3).
module "bingo" {
  source     = "git::https://github.com/canonical/bingo//terraform/product?ref=tf-1.0.0&depth=1"
  model_uuid = var.model_uuid

  deploy_postgresql = var.deploy_postgresql
  deploy_oauth      = true
  deploy_ingress    = false

  bingo = {
    channel = "1/stable"
    # renovate: charm="bingo" track="1" risk="stable" base="24.04" arch="amd64"
    revision = 4
    config   = var.bingo_config
    units    = var.bingo_units
  }

  postgresql = {
    channel = "14/stable"
    # renovate: charm="postgresql-k8s" track="14" risk="stable" base="24.04" arch="amd64"
    revision = 774
    config   = var.postgresql_config
    units    = var.postgresql_units
  }

  oauth = {
    channel = "latest/edge"
    # renovate: charm="oauth-external-idp-integrator" track="latest" risk="edge" base="24.04" arch="amd64"
    revision = 6
    config   = var.oauth_config
  }
}
