# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

# Ingress is deployment-specific, so it is wired here rather than inside the
# gopkg product module (deploy_ingress = false below). ingress-configurator is
# the ingress charm used on PS7 Kubernetes models; see falcosidekick/ps7.
module "ingress_configurator" {
  source     = "git::https://github.com/canonical/ingress-configurator-operator//terraform?ref=ingress-configurator-rev103&depth=1"
  app_name   = "ingress-configurator"
  model_uuid = var.model_uuid
  channel    = "latest/stable"
  # renovate: charm="ingress-configurator" track="latest" risk="stable" base="24.04" arch="amd64"
  revision = 95
  config   = { hostname = var.external_hostname }
  trust    = true
}

# The product module threads external_hostname into gopkg's `hostname` config
# so go-import metadata matches the host ingress-configurator serves.
#
# Pinned to a `gopkg-k8s-rev<N>` tag, not the older bare `rev<N>` one: charm-ci
# tags each publish `<charm>-rev<revision>`, and the compatibility group in this
# file's versioning rule (renovate.json) keeps a ref inside the tag family it
# already uses. A bare `rev2` pin would sit in a family nothing publishes to any
# more, so Renovate would silently stop proposing updates for this line.
module "gopkg" {
  source     = "git::https://github.com/canonical/gopkg-charmed//terraform/product?ref=gopkg-k8s-rev2&depth=1"
  model_uuid = var.model_uuid

  deploy_ingress    = false
  external_hostname = var.external_hostname

  gopkg = {
    app_name = "gopkg-k8s"
    channel  = "latest/edge"
    # renovate: charm="gopkg-k8s" track="latest" risk="edge" base="24.04" arch="amd64"
    revision = 2
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
