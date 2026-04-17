# Copyright 2025 Canonical Ltd.
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
    model                      = run.setup_tests.model_name
    model_uuid                 = run.setup_tests.model_uuid
    external_hostname          = "test.local"
    grafana_consumers          = []
    loki_consumers             = []
    remote_write_consumers     = []
    metrics_endpoint_consumers = []
  }

  assert {
    condition     = output.components.alertmanager.app_name == "alertmanager"
    error_message = "alertmanager app_name did not match expected"
  }

  assert {
    condition     = output.components.grafana.app_name == "grafana"
    error_message = "grafana app_name did not match expected"
  }

  assert {
    condition     = output.components.prometheus.app_name == "prometheus"
    error_message = "prometheus app_name did not match expected"
  }

  assert {
    condition     = output.components.loki.app_name == "loki"
    error_message = "loki app_name did not match expected"
  }
}
