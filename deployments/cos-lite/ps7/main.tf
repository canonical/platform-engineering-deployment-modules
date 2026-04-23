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
    base     = "ubuntu@22.04"
  }

  config      = {}
  constraints = "arch=amd64"
  units       = 1
}

resource "juju_application" "ingress_configurator_alertmanager" {
  name       = "alertmanager-ingress-configurator"
  model_uuid = var.model_uuid

  charm {
    name     = "ingress-configurator"
    channel  = "latest/edge"
    revision = 72
    base     = "ubuntu@24.04"
  }

  config = { hostname = var.external_hostname, paths = juju_application.alertmanager.name }
  units  = 1
  trust  = true
}

resource "juju_application" "ingress_configurator_catalogue" {
  name       = "catalogue-ingress-configurator"
  model_uuid = var.model_uuid

  charm {
    name     = "ingress-configurator"
    channel  = "latest/edge"
    revision = 72
    base     = "ubuntu@24.04"
  }

  config = { hostname = var.external_hostname, paths = juju_application.catalogue.name }
  units  = 1
  trust  = true
}

resource "juju_application" "ingress_configurator_grafana" {
  name       = "grafana-ingress-configurator"
  model_uuid = var.model_uuid

  charm {
    name     = "ingress-configurator"
    channel  = "latest/edge"
    revision = 72
    base     = "ubuntu@24.04"
  }

  config = { hostname = var.external_hostname, paths = juju_application.grafana.name }
  units  = 1
  trust  = true
}

resource "juju_application" "ingress_configurator_prometheus" {
  name       = "prometheus-ingress-configurator"
  model_uuid = var.model_uuid

  charm {
    name     = "ingress-configurator"
    channel  = "latest/edge"
    revision = 72
    base     = "ubuntu@24.04"
  }

  config = { hostname = var.external_hostname, paths = juju_application.prometheus.name }
  units  = 1
  trust  = true
}

resource "juju_application" "ingress_configurator_loki" {
  name       = "loki-ingress-configurator"
  model_uuid = var.model_uuid

  charm {
    name     = "ingress-configurator"
    channel  = "latest/edge"
    revision = 72
    base     = "ubuntu@24.04"
  }

  config = { hostname = var.external_hostname, paths = juju_application.loki.name }
  units  = 1
  trust  = true
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

resource "juju_integration" "alertmanager_grafana_dashboards" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.alertmanager.name
    endpoint = "grafana-dashboard"
  }

  application {
    name     = juju_application.grafana.name
    endpoint = "grafana-dashboard"
  }
}

resource "juju_integration" "alertmanager_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.prometheus.name
    endpoint = "alertmanager"
  }

  application {
    name     = juju_application.alertmanager.name
    endpoint = "alerting"
  }
}

resource "juju_integration" "alertmanager_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.prometheus.name
    endpoint = "metrics-endpoint"
  }

  application {
    name     = juju_application.alertmanager.name
    endpoint = "self-metrics-endpoint"
  }
}

resource "juju_integration" "alertmanager_loki" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.loki.name
    endpoint = "alertmanager"
  }

  application {
    name     = juju_application.alertmanager.name
    endpoint = "alerting"
  }
}

resource "juju_integration" "grafana_source_alertmanager" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.alertmanager.name
    endpoint = "grafana-source"
  }

  application {
    name     = juju_application.grafana.name
    endpoint = "grafana-source"
  }
}

resource "juju_integration" "grafana_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.prometheus.name
    endpoint = "metrics-endpoint"
  }

  application {
    name     = juju_application.grafana.name
    endpoint = "metrics-endpoint"
  }
}

resource "juju_integration" "prometheus_grafana_dashboards_provider" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.prometheus.name
    endpoint = "grafana-dashboard"
  }

  application {
    name     = juju_application.grafana.name
    endpoint = "grafana-dashboard"
  }
}

resource "juju_integration" "prometheus_grafana_source" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.prometheus.name
    endpoint = "grafana-source"
  }

  application {
    name     = juju_application.grafana.name
    endpoint = "grafana-source"
  }
}

resource "juju_integration" "loki_grafana_dashboards_provider" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.loki.name
    endpoint = "grafana-dashboard"
  }

  application {
    name     = juju_application.grafana.name
    endpoint = "grafana-dashboard"
  }
}

resource "juju_integration" "loki_grafana_source" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.loki.name
    endpoint = "grafana-source"
  }

  application {
    name     = juju_application.grafana.name
    endpoint = "grafana-source"
  }
}

resource "juju_integration" "loki_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.prometheus.name
    endpoint = "metrics-endpoint"
  }

  application {
    name     = juju_application.loki.name
    endpoint = "metrics-endpoint"
  }
}

resource "juju_integration" "catalogue_alertmanager" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.catalogue.name
    endpoint = "catalogue"
  }

  application {
    name     = juju_application.alertmanager.name
    endpoint = "catalogue"
  }
}

resource "juju_integration" "catalogue_grafana" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.catalogue.name
    endpoint = "catalogue"
  }

  application {
    name     = juju_application.grafana.name
    endpoint = "catalogue"
  }
}

resource "juju_integration" "catalogue_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.catalogue.name
    endpoint = "catalogue"
  }

  application {
    name     = juju_application.prometheus.name
    endpoint = "catalogue"
  }
}

resource "juju_integration" "alertmanager_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.ingress_configurator_alertmanager.name
    endpoint = "ingress"
  }

  application {
    name     = juju_application.alertmanager.name
    endpoint = "ingress"
  }
}

resource "juju_integration" "catalogue_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.ingress_configurator_catalogue.name
    endpoint = "ingress"
  }

  application {
    name     = juju_application.catalogue.name
    endpoint = "ingress"
  }
}

resource "juju_integration" "grafana_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.ingress_configurator_grafana.name
    endpoint = "ingress"
  }

  application {
    name     = juju_application.grafana.name
    endpoint = "ingress"
  }
}

resource "juju_integration" "prometheus_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.ingress_configurator_prometheus.name
    endpoint = "ingress"
  }

  application {
    name     = juju_application.prometheus.name
    endpoint = "ingress"
  }
}

resource "juju_integration" "loki_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.ingress_configurator_loki.name
    endpoint = "ingress"
  }

  application {
    name     = juju_application.loki.name
    endpoint = "ingress"
  }
}

resource "juju_integration" "alertmanager_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.ssc.name
    endpoint = local.ssc.provides.certificates
  }

  application {
    name     = juju_application.alertmanager.name
    endpoint = "certificates"
  }
}

resource "juju_integration" "catalogue_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.ssc.name
    endpoint = local.ssc.provides.certificates
  }

  application {
    name     = juju_application.catalogue.name
    endpoint = "certificates"
  }
}

resource "juju_integration" "grafana_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.ssc.name
    endpoint = local.ssc.provides.certificates
  }

  application {
    name     = juju_application.grafana.name
    endpoint = "certificates"
  }
}

resource "juju_integration" "loki_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.ssc.name
    endpoint = local.ssc.provides.certificates
  }

  application {
    name     = juju_application.loki.name
    endpoint = "certificates"
  }
}

resource "juju_integration" "prometheus_certificates" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.ssc.name
    endpoint = local.ssc.provides.certificates
  }

  application {
    name     = juju_application.prometheus.name
    endpoint = "certificates"
  }
}

resource "juju_offer" "alertmanager_karma_dashboard" {
  name             = "alertmanager-karma-dashboard"
  model_uuid       = var.model_uuid
  application_name = juju_application.alertmanager.name
  endpoints        = ["karma-dashboard"]
}

resource "juju_offer" "grafana_dashboards" {
  name             = "grafana-dashboards"
  model_uuid       = var.model_uuid
  application_name = juju_application.grafana.name
  endpoints        = ["grafana-dashboard"]
}

resource "juju_offer" "loki_logging" {
  name             = "loki-logging"
  model_uuid       = var.model_uuid
  application_name = juju_application.loki.name
  endpoints        = ["logging"]
}

resource "juju_offer" "prometheus_receive_remote_write" {
  name             = "prometheus-receive-remote-write"
  model_uuid       = var.model_uuid
  application_name = juju_application.prometheus.name
  endpoints        = ["receive-remote-write"]
}

resource "juju_offer" "prometheus_metrics_endpoint" {
  name             = "prometheus-metrics-endpoint"
  model_uuid       = var.model_uuid
  application_name = juju_application.prometheus.name
  endpoints        = ["metrics-endpoint"]
}
