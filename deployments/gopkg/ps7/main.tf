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
module "gopkg" {
  source     = "git::https://github.com/canonical/gopkg-charmed//terraform/product?ref=gopkg-k8s-rev9&depth=1"
  model_uuid = var.model_uuid

  deploy_ingress    = false
  external_hostname = var.external_hostname

  gopkg = {
    app_name = "gopkg-k8s"
    channel  = "latest/edge"
    # renovate: charm="gopkg-k8s" track="latest" risk="edge" base="24.04" arch="amd64"
    revision = 9
    config   = var.gopkg_config
    units    = var.gopkg_units
  }
}

# The collector runs in the gopkg model and forwards to the shared IS COS
# aggregator, so gopkg's three COS endpoints relate to it in-model.
resource "juju_application" "opentelemetry_collector" {
  model_uuid = var.model_uuid
  name       = "opentelemetry-collector"

  charm {
    name     = "opentelemetry-collector-k8s"
    channel  = "0.130/stable"
    revision = 272
    base     = "ubuntu@26.04"
  }

  config = var.opentelemetry_collector_config
  # The charm patches its own StatefulSet and is blocked without trust.
  trust = true
  units = 1
}

resource "juju_integration" "gopkg_metrics" {
  model_uuid = var.model_uuid

  application {
    name     = module.gopkg.gopkg.app_name
    endpoint = module.gopkg.gopkg.provides.metrics_endpoint
  }

  application {
    name     = juju_application.opentelemetry_collector.name
    endpoint = "metrics-endpoint"
  }
}

resource "juju_integration" "gopkg_logging" {
  model_uuid = var.model_uuid

  application {
    name     = module.gopkg.gopkg.app_name
    endpoint = module.gopkg.gopkg.requires.logging
  }

  application {
    name     = juju_application.opentelemetry_collector.name
    endpoint = "receive-loki-logs"
  }
}

resource "juju_integration" "gopkg_dashboards" {
  model_uuid = var.model_uuid

  application {
    name     = module.gopkg.gopkg.app_name
    endpoint = module.gopkg.gopkg.provides.grafana_dashboard
  }

  application {
    name     = juju_application.opentelemetry_collector.name
    endpoint = "grafana-dashboards-consumer"
  }
}

# Cross-model relations to the COS aggregator offers.
resource "juju_integration" "otelcol_otlp" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.opentelemetry_collector.name
    endpoint = "send-otlp"
  }

  application {
    offer_url = var.cos_aggregator_otlp_offer_url
  }
}

resource "juju_integration" "otelcol_dashboards" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.opentelemetry_collector.name
    endpoint = "grafana-dashboards-provider"
  }

  application {
    offer_url = var.cos_aggregator_dashboards_offer_url
  }
}

resource "juju_integration" "otelcol_ca_cert" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.opentelemetry_collector.name
    endpoint = "receive-ca-cert"
  }

  application {
    offer_url = var.cos_aggregator_ca_cert_offer_url
  }
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
