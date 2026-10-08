# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.

provider "juju" {}

run "setup_tests" {
  module {
    source = "./tests/setup"
  }
}

run "basic_plan" {
  command = plan

  variables {
    model_uuid                          = run.setup_tests.model_uuid
    external_hostname                   = "gopkg.test.local"
    cos_aggregator_otlp_offer_url       = "admin/test-cos.otelcol-aggregator"
    cos_aggregator_dashboards_offer_url = "admin/test-cos.otelcol-aggregator"
    cos_aggregator_ca_cert_offer_url    = "admin/test-cos.self-signed-certificates-aggregator"
  }

  assert {
    condition     = output.components.gopkg.gopkg.app_name == "gopkg-k8s"
    error_message = "gopkg app_name did not match expected"
  }

  assert {
    condition     = output.components.ingress_configurator.application.name == "ingress-configurator"
    error_message = "ingress-configurator app_name did not match expected"
  }

  # The charm ships its own Grafana dashboard and alert rules; they only reach
  # COS over these endpoints, so a rename upstream must fail here loudly.
  assert {
    condition     = output.components.gopkg.gopkg.provides.metrics_endpoint == "metrics-endpoint"
    error_message = "gopkg metrics-endpoint provider endpoint did not match expected"
  }

  assert {
    condition     = output.components.gopkg.gopkg.provides.grafana_dashboard == "grafana-dashboard"
    error_message = "gopkg grafana-dashboard provider endpoint did not match expected"
  }

  assert {
    condition     = output.components.gopkg.gopkg.requires.logging == "logging"
    error_message = "gopkg logging requirer endpoint did not match expected"
  }
}
