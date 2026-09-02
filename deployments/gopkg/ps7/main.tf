# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

# Ingress is deployment-specific, so it is wired here rather than inside the
# gopkg product module (deploy_ingress = false below). ingress-configurator is
# the ingress charm used on PS7 Kubernetes models; see falcosidekick/ps7.
module "ingress_configurator" {
  source     = "git::https://github.com/canonical/ingress-configurator-operator//terraform?ref=ingress-configurator-rev103&depth=1"
  app_name   = "ingress-configurator"
  model_uuid = var.model_uuid
  channel    = "latest/edge"
  # renovate: charm="ingress-configurator" track="latest" risk="edge" base="24.04" arch="amd64"
  revision = 103
  config   = { hostname = var.external_hostname }
  trust    = true
}

# The product module threads external_hostname into gopkg's `hostname` config
# so go-import metadata matches the host ingress-configurator serves.
module "gopkg" {
  source     = "git::https://github.com/canonical/gopkg-charmed//terraform/product?ref=rev1&depth=1"
  model_uuid = var.model_uuid

  deploy_ingress    = false
  external_hostname = var.external_hostname

  gopkg = {
    channel = "latest/edge"
    # renovate: charm="gopkg-charmed" track="latest" risk="edge" base="24.04" arch="amd64"
    revision = 1
    config   = var.gopkg_config
    units    = var.gopkg_units
  }

  logging_offer_url           = var.loki_offer_url
  metrics_offer_url           = var.prometheus_offer_url
  grafana_dashboard_offer_url = var.grafana_dashboard_offer_url
}

resource "juju_integration" "gopkg_ingress" {
  provider   = juju
  model_uuid = var.model_uuid

  application {
    name     = module.gopkg.gopkg.app_name
    endpoint = module.gopkg.gopkg.requires.ingress
  }

  application {
    name     = module.ingress_configurator.provides.ingress.name
    endpoint = module.ingress_configurator.provides.ingress.endpoint
  }
}
