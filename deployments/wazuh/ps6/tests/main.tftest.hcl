# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.

mock_provider "vault" {
  mock_data "vault_generic_secret" {
    defaults = {
      data = {
        endpoint_url = "https://mock-s3.example.com"
        username     = "mock-username"
        password     = "mock-password"
        private_key  = "mock-private-key"
        key          = "mock-key"
        token        = "mock-token"
      }
    }
  }
}
mock_provider "openstack" {}

provider "juju" {}
provider "juju" {
  alias = "wazuh_indexer"
}
provider "juju" {
  alias = "wazuh_dashboard"
}

run "setup_tests" {
  module {
    source = "./tests/setup"
  }
}

run "basic_plan" {
  command = plan

  variables {
    server_model_name                     = run.setup_tests.server_model_name
    server_model_uuid                     = run.setup_tests.server_model_uuid
    indexer_model_name                    = run.setup_tests.indexer_model_name
    indexer_model_uuid                    = run.setup_tests.indexer_model_uuid
    dashboard_model_name                  = run.setup_tests.dashboard_model_name
    dashboard_model_uuid                  = run.setup_tests.dashboard_model_uuid
    grafana_offer_url                     = "admin/test-cos.grafana-dashboards"
    logs_ca_certificate                   = "placeholder-ca-cert"
    loki_offer_url                        = "admin/test-cos.loki-logging"
    opencti_offer_url                     = "admin/test-opencti.opencti"
    prometheus_metrics_endpoint_offer_url = "admin/test-cos.prometheus-metrics-endpoint"
    prometheus_remote_write_offer_url     = "admin/test-cos.prometheus-receive-remote-write"
    wazuh_custom_config_repository        = "git@github.com:example/wazuh-config.git"
    wazuh_dashboard_constraints           = "arch=amd64"
    wazuh_external_hostname               = "wazuh.test.local"
    wazuh_indexer_constraints             = "arch=amd64"
    wazuh_server_storage                  = {}
  }

  assert {
    condition     = output.lego_app_name == "lego"
    error_message = "lego app_name did not match expected"
  }
}
