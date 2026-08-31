# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

# This module wraps the bingo product module and pins the revisions/channels
# of every bundled charm for the PS7 stack. It intentionally does NOT deploy
# ingress: ingress is deployment-specific and managed by the consuming
# deployment (see Layer 3).
#
# TODO: once canonical/bingo cuts a `tf-X.Y.Z` tag for the terraform module
# (see CC008 "Module Lifecycle" — in-repo modules should tag as tf-X.Y.Z),
# replace the `ref` below with that tag instead of a raw commit hash.
module "bingo" {
  source     = "git::https://github.com/canonical/bingo//terraform/product?ref=c4ce57a27308cbe6c17b6856b2da7e201cc7b678&depth=1"
  model_uuid = var.model_uuid

  deploy_postgresql = var.deploy_postgresql
  deploy_oauth      = true
  deploy_ingress    = false

  bingo = {
    channel = "latest/edge"
    # renovate: depName="bingo"
    revision = null # TODO: pin to a tested revision once bingo publishes one
    config   = var.bingo_config
    units    = var.bingo_units
  }

  postgresql = {
    channel = "14/stable"
    # renovate: depName="postgresql-k8s"
    revision = 774
    config   = var.postgresql_config
    units    = var.postgresql_units
  }

  oauth = {
    channel = "latest/edge"
    # renovate: depName="oauth-external-idp-integrator"
    revision = 6
    config   = var.oauth_config
  }
}
