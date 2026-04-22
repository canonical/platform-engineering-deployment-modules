resource "juju_application" "ingress_configurator" {
  name       = "ingress-configurator"
  model_uuid = var.model_uuid

  charm {
    name     = "ingress-configurator"
    channel  = "latest/edge"
    revision = 72
    base     = "ubuntu@24.04"
  }

  config      = { hostname = var.external_hostname }
  constraints = ""
  units       = 1
}

resource "juju_application" "alertmanager" {
  name               = "alertmanager"
  config             = {}
  constraints        = "arch=amd64"
  model_uuid         = var.model_uuid
  storage_directives = {}
  trust              = true
  units              = 1

  charm {
    name     = "alertmanager-k8s"
    channel  = "1/stable"
    revision = 162
  }
}

resource "juju_application" "catalogue" {
  name               = "catalogue"
  config             = {}
  constraints        = "arch=amd64"
  model_uuid         = var.model_uuid
  storage_directives = {}
  trust              = true
  units              = 1

  charm {
    name     = "catalogue-k8s"
    channel  = "1/stable"
    revision = 87
  }
}

resource "juju_application" "grafana" {
  name               = "grafana"
  config             = {}
  constraints        = "arch=amd64"
  model_uuid         = var.model_uuid
  storage_directives = {}
  trust              = true
  units              = 1

  charm {
    name     = "grafana-k8s"
    channel  = "1/stable"
    revision = 151
  }
}

resource "juju_application" "loki" {
  name               = "loki"
  config             = {}
  constraints        = "arch=amd64"
  model_uuid         = var.model_uuid
  storage_directives = {}
  trust              = true
  units              = 1

  charm {
    name     = "loki-k8s"
    channel  = "1/stable"
    revision = 199
  }
}

resource "juju_application" "prometheus" {
  name               = "prometheus"
  config             = {}
  constraints        = "arch=amd64"
  model_uuid         = var.model_uuid
  storage_directives = {}
  trust              = true
  units              = 1

  charm {
    name     = "prometheus-k8s"
    channel  = "1/stable"
    revision = 247
  }
}

resource "juju_application" "ssc" {
  name       = "ca"
  model_uuid = var.model_uuid

  charm {
    name     = "self-signed-certificates"
    channel  = "1/stable"
    revision = 588
    base     = "ubuntu@24.04"
  }

  config      = {}
  constraints = "arch=amd64"
  units       = 1
}

resource "juju_offer" "ssc_send_ca_cert" {
  name             = "send-ca-cert"
  model_uuid       = var.model_uuid
  application_name = juju_application.ssc.name
  endpoints        = ["send-ca-cert"]
}

resource "juju_offer" "ssc_certificates" {
  name             = "certificates"
  model_uuid       = var.model_uuid
  application_name = juju_application.ssc.name
  endpoints        = ["certificates"]
}

locals {
  ingress_configurator = {
    app_name = juju_application.ingress_configurator.name
    endpoints = {
      ingress           = "ingress"
      haproxy_route     = "haproxy-route"
      haproxy_route_tcp = "haproxy-route-tcp"
    }
  }

  alertmanager = {
    app_name = juju_application.alertmanager.name
    endpoints = {
      catalogue             = "catalogue"
      certificates          = "certificates"
      ingress               = "ingress"
      tracing               = "tracing"
      remote_configuration  = "remote-configuration"
      alerting              = "alerting"
      karma_dashboard       = "karma-dashboard"
      self_metrics_endpoint = "self-metrics-endpoint"
      grafana_dashboard     = "grafana-dashboard"
      grafana_source        = "grafana-source"
    }
  }

  catalogue = {
    app_name = juju_application.catalogue.name
    endpoints = {
      certificates = "certificates"
      ingress      = "ingress"
      tracing      = "tracing"
      catalogue    = "catalogue"
    }
  }

  grafana = {
    app_name = juju_application.grafana.name
    endpoints = {
      catalogue         = "catalogue"
      certificates      = "certificates"
      database          = "database"
      grafana_auth      = "grafana-auth"
      grafana_dashboard = "grafana-dashboard"
      grafana_source    = "grafana-source"
      ingress           = "ingress"
      oauth             = "oauth"
      receive_ca_cert   = "receive-ca-cert"
      charm_tracing     = "charm-tracing"
      metrics_endpoint  = "metrics-endpoint"
    }
  }

  loki = {
    app_name = juju_application.loki.name
    endpoints = {
      alertmanager         = "alertmanager"
      ingress              = "ingress"
      catalogue            = "catalogue"
      certificates         = "certificates"
      charm_tracing        = "charm-tracing"
      workload_tracing     = "workload-tracing"
      metrics_endpoint     = "metrics-endpoint"
      grafana_source       = "grafana-source"
      grafana_dashboard    = "grafana-dashboard"
      receive_remote_write = "receive-remote-write"
      send_datasource      = "send-datasource"
      logging              = "logging"
    }
  }

  prometheus = {
    app_name = juju_application.prometheus.name
    endpoints = {
      metrics_endpoint      = "metrics-endpoint"
      alertmanager          = "alertmanager"
      ingress               = "ingress"
      catalogue             = "catalogue"
      certificates          = "certificates"
      receive_ca_cert       = "receive-ca-cert"
      charm_tracing         = "charm-tracing"
      workload_tracing      = "workload-tracing"
      self_metrics_endpoint = "self-metrics-endpoint"
      grafana_source        = "grafana-source"
      grafana_dashboard     = "grafana-dashboard"
      receive_remote_write  = "receive-remote-write"
      send_datasource       = "send-datasource"
      prometheus_api        = "prometheus-api"
    }
  }

  ssc = {
    app_name = juju_application.ssc.name
    requires = {
      tracing = "tracing"
    }
    provides = {
      certificates   = "certificates"
      "send-ca-cert" = "send-ca-cert"
    }
    offers = {
      "send-ca-cert" = juju_offer.ssc_send_ca_cert
      certificates   = juju_offer.ssc_certificates
    }
  }
}

moved {
  from = module.ingress_configurator.juju_application.ingress-configurator
  to   = juju_application.ingress_configurator
}

moved {
  from = module.alertmanager.juju_application.alertmanager
  to   = juju_application.alertmanager
}

moved {
  from = module.catalogue.juju_application.catalogue
  to   = juju_application.catalogue
}

moved {
  from = module.grafana.juju_application.grafana
  to   = juju_application.grafana
}

moved {
  from = module.loki.juju_application.loki
  to   = juju_application.loki
}

moved {
  from = module.prometheus.juju_application.prometheus
  to   = juju_application.prometheus
}

moved {
  from = module.ssc.juju_application.self-signed-certificates
  to   = juju_application.ssc
}

moved {
  from = module.ssc.juju_offer.send_ca_cert
  to   = juju_offer.ssc_send_ca_cert
}

moved {
  from = module.ssc.juju_offer.certificates
  to   = juju_offer.ssc_certificates
}

resource "juju_integration" "alertmanager_grafana_dashboards" {
  model_uuid = var.model_uuid

  application {
    name     = local.alertmanager.app_name
    endpoint = local.alertmanager.endpoints.grafana_dashboard
  }

  application {
    name     = local.grafana.app_name
    endpoint = local.grafana.endpoints.grafana_dashboard
  }
}

resource "juju_integration" "alertmanager_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = local.prometheus.app_name
    endpoint = local.prometheus.endpoints.alertmanager
  }

  application {
    name     = local.alertmanager.app_name
    endpoint = local.alertmanager.endpoints.alerting
  }
}

resource "juju_integration" "alertmanager_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = local.prometheus.app_name
    endpoint = local.prometheus.endpoints.metrics_endpoint
  }

  application {
    name     = local.alertmanager.app_name
    endpoint = local.alertmanager.endpoints.self_metrics_endpoint
  }
}

resource "juju_integration" "alertmanager_loki" {
  model_uuid = var.model_uuid

  application {
    name     = local.loki.app_name
    endpoint = local.loki.endpoints.alertmanager
  }

  application {
    name     = local.alertmanager.app_name
    endpoint = local.alertmanager.endpoints.alerting
  }
}

resource "juju_integration" "grafana_source_alertmanager" {
  model_uuid = var.model_uuid

  application {
    name     = local.alertmanager.app_name
    endpoint = local.alertmanager.endpoints.grafana_source
  }

  application {
    name     = local.grafana.app_name
    endpoint = local.grafana.endpoints.grafana_source
  }
}

resource "juju_integration" "grafana_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = local.prometheus.app_name
    endpoint = local.prometheus.endpoints.metrics_endpoint
  }

  application {
    name     = local.grafana.app_name
    endpoint = local.grafana.endpoints.metrics_endpoint
  }
}

resource "juju_integration" "prometheus_grafana_dashboards_provider" {
  model_uuid = var.model_uuid

  application {
    name     = local.prometheus.app_name
    endpoint = local.prometheus.endpoints.grafana_dashboard
  }

  application {
    name     = local.grafana.app_name
    endpoint = local.grafana.endpoints.grafana_dashboard
  }
}

resource "juju_integration" "prometheus_grafana_source" {
  model_uuid = var.model_uuid

  application {
    name     = local.prometheus.app_name
    endpoint = local.prometheus.endpoints.grafana_source
  }

  application {
    name     = local.grafana.app_name
    endpoint = local.grafana.endpoints.grafana_source
  }
}

resource "juju_integration" "loki_grafana_dashboards_provider" {
  model_uuid = var.model_uuid

  application {
    name     = local.loki.app_name
    endpoint = local.loki.endpoints.grafana_dashboard
  }

  application {
    name     = local.grafana.app_name
    endpoint = local.grafana.endpoints.grafana_dashboard
  }
}

resource "juju_integration" "loki_grafana_source" {
  model_uuid = var.model_uuid

  application {
    name     = local.loki.app_name
    endpoint = local.loki.endpoints.grafana_source
  }

  application {
    name     = local.grafana.app_name
    endpoint = local.grafana.endpoints.grafana_source
  }
}

resource "juju_integration" "loki_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = local.prometheus.app_name
    endpoint = local.prometheus.endpoints.metrics_endpoint
  }

  application {
    name     = local.loki.app_name
    endpoint = local.loki.endpoints.metrics_endpoint
  }
}

resource "juju_integration" "catalogue_alertmanager" {
  model_uuid = var.model_uuid

  application {
    name     = local.catalogue.app_name
    endpoint = local.catalogue.endpoints.catalogue
  }

  application {
    name     = local.alertmanager.app_name
    endpoint = local.alertmanager.endpoints.catalogue
  }
}

resource "juju_integration" "catalogue_grafana" {
  model_uuid = var.model_uuid

  application {
    name     = local.catalogue.app_name
    endpoint = local.catalogue.endpoints.catalogue
  }

  application {
    name     = local.grafana.app_name
    endpoint = local.grafana.endpoints.catalogue
  }
}

resource "juju_integration" "catalogue_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = local.catalogue.app_name
    endpoint = local.catalogue.endpoints.catalogue
  }

  application {
    name     = local.prometheus.app_name
    endpoint = local.prometheus.endpoints.catalogue
  }
}

resource "juju_integration" "alertmanager_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = local.ingress_configurator.app_name
    endpoint = local.ingress_configurator.endpoints.ingress
  }

  application {
    name     = local.alertmanager.app_name
    endpoint = local.alertmanager.endpoints.ingress
  }
}

resource "juju_integration" "catalogue_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = local.ingress_configurator.app_name
    endpoint = local.ingress_configurator.endpoints.ingress
  }

  application {
    name     = local.catalogue.app_name
    endpoint = local.catalogue.endpoints.ingress
  }
}

resource "juju_integration" "grafana_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = local.ingress_configurator.app_name
    endpoint = local.ingress_configurator.endpoints.ingress
  }

  application {
    name     = local.grafana.app_name
    endpoint = local.grafana.endpoints.ingress
  }
}

resource "juju_integration" "prometheus_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = local.ingress_configurator.app_name
    endpoint = local.ingress_configurator.endpoints.ingress
  }

  application {
    name     = local.prometheus.app_name
    endpoint = local.prometheus.endpoints.ingress
  }
}

resource "juju_integration" "loki_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = local.ingress_configurator.app_name
    endpoint = local.ingress_configurator.endpoints.ingress
  }

  application {
    name     = local.loki.app_name
    endpoint = local.loki.endpoints.ingress
  }
}

resource "juju_integration" "alertmanager_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = local.ssc.app_name
    endpoint = local.ssc.provides.certificates
  }

  application {
    name     = local.alertmanager.app_name
    endpoint = local.alertmanager.endpoints.certificates
  }
}

resource "juju_integration" "catalogue_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = local.ssc.app_name
    endpoint = local.ssc.provides.certificates
  }

  application {
    name     = local.catalogue.app_name
    endpoint = local.catalogue.endpoints.certificates
  }
}

resource "juju_integration" "grafana_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = local.ssc.app_name
    endpoint = local.ssc.provides.certificates
  }

  application {
    name     = local.grafana.app_name
    endpoint = local.grafana.endpoints.certificates
  }
}

resource "juju_integration" "loki_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = local.ssc.app_name
    endpoint = local.ssc.provides.certificates
  }

  application {
    name     = local.loki.app_name
    endpoint = local.loki.endpoints.certificates
  }
}

resource "juju_integration" "prometheus_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = local.ssc.app_name
    endpoint = local.ssc.provides.certificates
  }

  application {
    name     = local.prometheus.app_name
    endpoint = local.prometheus.endpoints.certificates
  }
}

resource "juju_offer" "alertmanager_karma_dashboard" {
  name             = "alertmanager-karma-dashboard"
  model_uuid       = var.model_uuid
  application_name = local.alertmanager.app_name
  endpoints        = ["karma-dashboard"]
}

resource "juju_offer" "grafana_dashboards" {
  name             = "grafana-dashboards"
  model_uuid       = var.model_uuid
  application_name = local.grafana.app_name
  endpoints        = ["grafana-dashboard"]
}

resource "juju_offer" "loki_logging" {
  name             = "loki-logging"
  model_uuid       = var.model_uuid
  application_name = local.loki.app_name
  endpoints        = ["logging"]
}

resource "juju_offer" "prometheus_receive_remote_write" {
  name             = "prometheus-receive-remote-write"
  model_uuid       = var.model_uuid
  application_name = local.prometheus.app_name
  endpoints        = ["receive-remote-write"]
}

resource "juju_offer" "prometheus_metrics_endpoint" {
  name             = "prometheus-metrics-endpoint"
  model_uuid       = var.model_uuid
  application_name = local.prometheus.app_name
  endpoints        = ["metrics-endpoint"]
}

resource "juju_jaas_access_offer" "grafana_dashboard" {
  offer_url = juju_offer.grafana_dashboards.url
  access    = "consumer"
  groups    = var.grafana_consumers
}

resource "juju_jaas_access_offer" "loki_logging" {
  offer_url = juju_offer.loki_logging.url
  access    = "consumer"
  groups    = var.loki_consumers
}

resource "juju_jaas_access_offer" "remote_write" {
  offer_url = juju_offer.prometheus_receive_remote_write.url
  access    = "consumer"
  groups    = var.remote_write_consumers
}

resource "juju_jaas_access_offer" "metrics_endpoint" {
  offer_url = juju_offer.prometheus_metrics_endpoint.url
  access    = "consumer"
  groups    = var.metrics_endpoint_consumers
}

