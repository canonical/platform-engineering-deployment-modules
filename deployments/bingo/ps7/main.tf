# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

# This module wraps the bingo product module, pins the revisions/channels of
# every bundled charm, and deploys the ingress-configurator fronted by
# HAProxy. It is intentionally opinionated: the ingress-configurator charm
# revision is pinned here, and only environment- and model-specific values
# (external_hostname, haproxy_offer_url) are taken as inputs.
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

# Ingress: the ingress-configurator charm (pinned here) fronted by the HAProxy
# offer. Only the external hostname and the HAProxy offer URL are
# environment-specific; the charm revision is opinionated.
resource "juju_application" "ingress_configurator" {
  name       = "ingress-configurator"
  model_uuid = var.model_uuid

  charm {
    name    = "ingress-configurator"
    channel = "latest/edge"
    # renovate: charm="ingress-configurator" track="latest" risk="edge" base="24.04" arch="amd64"
    revision = 98
    base     = "ubuntu@24.04"
  }

  config = {
    hostname = var.external_hostname
  }
  trust = true
  units = 1
}

resource "juju_integration" "bingo_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = module.bingo.bingo.app_name
    endpoint = module.bingo.bingo.requires.ingress
  }

  application {
    name     = juju_application.ingress_configurator.name
    endpoint = "ingress"
  }
}

resource "juju_integration" "haproxy_ingress_configurator" {
  model_uuid = var.model_uuid

  application {
    offer_url = var.haproxy_offer_url
  }

  application {
    name     = juju_application.ingress_configurator.name
    endpoint = "haproxy-route"
  }
}
