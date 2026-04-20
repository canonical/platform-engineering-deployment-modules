module "ingress_configurator" {
  source     = "git::https://github.com/canonical/ingress-configurator-operator//terraform?ref=rev72&depth=1"
  app_name   = "ingress-configurator"
  model_uuid = var.model_uuid
  channel    = "latest/edge"
  revision   = 72
  config     = { hostname = var.external_hostname }
}

module "alertmanager" {
  source             = "git::https://github.com/canonical/alertmanager-k8s-operator//terraform?ref=rev201&depth=1"
  app_name           = "alertmanager"
  channel            = "1/stable"
  config             = {}
  constraints        = "arch=amd64"
  model_uuid         = var.model_uuid
  revision           = 162
  storage_directives = {}
  units              = 1
}

module "catalogue" {
  source             = "git::https://github.com/canonical/catalogue-k8s-operator//terraform?ref=rev120&depth=1"
  app_name           = "catalogue"
  channel            = "1/stable"
  config             = {}
  constraints        = "arch=amd64"
  model_uuid         = var.model_uuid
  revision           = 87
  storage_directives = {}
  units              = 1
}

module "grafana" {
  source             = "git::https://github.com/canonical/grafana-k8s-operator//terraform?ref=rev185&depth=1"
  app_name           = "grafana"
  channel            = "1/stable"
  config             = {}
  constraints        = "arch=amd64"
  model_uuid         = var.model_uuid
  revision           = 151
  storage_directives = {}
  units              = 1
}

module "loki" {
  source             = "git::https://github.com/canonical/loki-k8s-operator//terraform?ref=rev220&depth=1"
  app_name           = "loki"
  channel            = "1/stable"
  config             = {}
  constraints        = "arch=amd64"
  model_uuid         = var.model_uuid
  storage_directives = {}
  revision           = 199
  units              = 1
}

module "prometheus" {
  source             = "git::https://github.com/canonical/prometheus-k8s-operator//terraform?ref=rev291&depth=1"
  app_name           = "prometheus"
  channel            = "1/stable"
  config             = {}
  constraints        = "arch=amd64"
  model_uuid         = var.model_uuid
  storage_directives = {}
  revision           = 247
  units              = 1
}

module "ssc" {
  source      = "git::https://github.com/canonical/self-signed-certificates-operator//terraform?ref=rev628&depth=1"
  app_name    = "ca"
  channel     = "1/stable"
  config      = {}
  constraints = "arch=amd64"
  model_uuid  = var.model_uuid
  revision    = 588
  units       = 1
}

resource "juju_integration" "alertmanager_grafana_dashboards" {
  model_uuid = var.model_uuid

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.grafana_dashboard
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_dashboard
  }
}

resource "juju_integration" "alertmanager_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.alertmanager
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.alerting
  }
}

resource "juju_integration" "alertmanager_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.metrics_endpoint
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.self_metrics_endpoint
  }
}

resource "juju_integration" "alertmanager_loki" {
  model_uuid = var.model_uuid

  application {
    name     = module.loki.app_name
    endpoint = module.loki.endpoints.alertmanager
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.alerting
  }
}

resource "juju_integration" "grafana_source_alertmanager" {
  model_uuid = var.model_uuid

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.grafana_source
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_source
  }
}

resource "juju_integration" "grafana_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.metrics_endpoint
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.metrics_endpoint
  }
}

resource "juju_integration" "prometheus_grafana_dashboards_provider" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.grafana_dashboard
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_dashboard
  }
}

resource "juju_integration" "prometheus_grafana_source" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.grafana_source
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_source
  }
}

resource "juju_integration" "loki_grafana_dashboards_provider" {
  model_uuid = var.model_uuid

  application {
    name     = module.loki.app_name
    endpoint = module.loki.endpoints.grafana_dashboard
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_dashboard
  }
}

resource "juju_integration" "loki_grafana_source" {
  model_uuid = var.model_uuid

  application {
    name     = module.loki.app_name
    endpoint = module.loki.endpoints.grafana_source
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_source
  }
}

resource "juju_integration" "loki_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.metrics_endpoint
  }

  application {
    name     = module.loki.app_name
    endpoint = module.loki.endpoints.metrics_endpoint
  }
}

resource "juju_integration" "catalogue_alertmanager" {
  model_uuid = var.model_uuid

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.catalogue
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.catalogue
  }
}

resource "juju_integration" "catalogue_grafana" {
  model_uuid = var.model_uuid

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.catalogue
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.catalogue
  }
}

resource "juju_integration" "catalogue_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.catalogue
  }

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.catalogue
  }
}

resource "juju_integration" "alertmanager_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = module.ingress_configurator.app_name
    endpoint = module.ingress_configurator.endpoints.ingress
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.ingress
  }
}

resource "juju_integration" "catalogue_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = module.ingress_configurator.app_name
    endpoint = module.ingress_configurator.endpoints.ingress
  }

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.ingress
  }
}

resource "juju_integration" "grafana_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = module.ingress_configurator.app_name
    endpoint = module.ingress_configurator.endpoints.ingress
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.ingress
  }
}

resource "juju_integration" "prometheus_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = module.ingress_configurator.app_name
    endpoint = module.ingress_configurator.endpoints.ingress
  }

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.ingress
  }
}

resource "juju_integration" "loki_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = module.ingress_configurator.app_name
    endpoint = module.ingress_configurator.endpoints.ingress
  }

  application {
    name     = module.loki.app_name
    endpoint = module.loki.endpoints.ingress
  }
}

resource "juju_integration" "alertmanager_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = module.ssc.app_name
    endpoint = module.ssc.provides.certificates
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.certificates
  }
}

resource "juju_integration" "catalogue_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = module.ssc.app_name
    endpoint = module.ssc.provides.certificates
  }

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.certificates
  }
}

resource "juju_integration" "grafana_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = module.ssc.app_name
    endpoint = module.ssc.provides.certificates
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.certificates
  }
}

resource "juju_integration" "loki_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = module.ssc.app_name
    endpoint = module.ssc.provides.certificates
  }

  application {
    name     = module.loki.app_name
    endpoint = module.loki.endpoints.certificates
  }
}

resource "juju_integration" "prometheus_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = module.ssc.app_name
    endpoint = module.ssc.provides.certificates
  }

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.certificates
  }
}

resource "juju_offer" "alertmanager_karma_dashboard" {
  name             = "alertmanager-karma-dashboard"
  model_uuid       = var.model_uuid
  application_name = module.alertmanager.app_name
  endpoints        = ["karma-dashboard"]
}

resource "juju_offer" "grafana_dashboards" {
  name             = "grafana-dashboards"
  model_uuid       = var.model_uuid
  application_name = module.grafana.app_name
  endpoints        = ["grafana-dashboard"]
}

resource "juju_offer" "loki_logging" {
  name             = "loki-logging"
  model_uuid       = var.model_uuid
  application_name = module.loki.app_name
  endpoints        = ["logging"]
}

resource "juju_offer" "prometheus_receive_remote_write" {
  name             = "prometheus-receive-remote-write"
  model_uuid       = var.model_uuid
  application_name = module.prometheus.app_name
  endpoints        = ["receive-remote-write"]
}

resource "juju_offer" "prometheus_metrics_endpoint" {
  name             = "prometheus-metrics-endpoint"
  model_uuid       = var.model_uuid
  application_name = module.prometheus.app_name
  endpoints        = ["metrics-endpoint"]
}

resource "juju_access_offer" "grafana_dashboard" {
  offer_url = juju_offer.grafana_dashboards.url
  admin     = [var.model]
  consume   = var.grafana_consumers
}

resource "juju_access_offer" "loki_logging" {
  offer_url = juju_offer.loki_logging.url
  admin     = [var.model]
  consume   = var.loki_consumers
}

resource "juju_access_offer" "remote_write" {
  offer_url = juju_offer.prometheus_receive_remote_write.url
  admin     = [var.model]
  consume   = var.remote_write_consumers
}

resource "juju_access_offer" "metrics_endpoint" {
  offer_url = juju_offer.prometheus_metrics_endpoint.url
  admin     = [var.model]
  consume   = var.metrics_endpoint_consumers
}

