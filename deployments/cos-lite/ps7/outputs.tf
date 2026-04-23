output "offers" {
  value = {
    alertmanager_karma_dashboard    = juju_offer.alertmanager_karma_dashboard
    grafana_dashboards              = juju_offer.grafana_dashboards
    loki_logging                    = juju_offer.loki_logging
    prometheus_receive_remote_write = juju_offer.prometheus_receive_remote_write
    prometheus_metrics_endpoint     = juju_offer.prometheus_metrics_endpoint
  }
  description = "All Juju offers which are exposed by this product module"
}

output "components" {
  value = {
    alertmanager                      = local.alertmanager
    catalogue                         = local.catalogue
    grafana                           = local.grafana
    loki                              = local.loki
    prometheus                        = local.prometheus
    ssc                               = local.ssc
    ingress_configurator_alertmanager = juju_application.ingress_configurator_alertmanager.name
    ingress_configurator_catalogue    = juju_application.ingress_configurator_catalogue.name
    ingress_configurator_grafana      = juju_application.ingress_configurator_grafana.name
    ingress_configurator_loki         = juju_application.ingress_configurator_loki.name
    ingress_configurator_prometheus   = juju_application.ingress_configurator_prometheus.name
  }
  description = "All Terraform charm modules which make up this product module"
}
