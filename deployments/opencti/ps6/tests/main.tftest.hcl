# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.

mock_provider "vault" {
  mock_data "vault_generic_secret" {
    defaults = {
      data = {
        endpoint_url      = "https://mock-s3.example.com"
        username          = "mock-username"
        password          = "mock-password"
        key               = "mock-key"
        token             = "mock-token"
        email             = "mock@example.com"
        "api-key"         = "mock-api-key"
        "client-id"       = "mock-client-id"
        "client-secret"   = "mock-client-secret"
      }
    }
  }
}
mock_provider "openstack" {}

provider "juju" {}
provider "juju" {
  alias = "opencti_db"
}

run "setup_tests" {
  module {
    source = "./tests/setup"
  }
}

run "basic_plan" {
  command = plan

  variables {
    model_name                            = run.setup_tests.model_name
    model_uuid                            = run.setup_tests.model_uuid
    db_model_name                         = run.setup_tests.db_model_name
    db_model_uuid                         = run.setup_tests.db_model_uuid
    grafana_offer_url                     = "admin/test-cos.grafana-dashboards"
    loki_offer_url                        = "admin/test-cos.loki-logging"
    indexer_offer_url                     = "admin/test-opensearch.opensearch"
    opencti_consumers                     = []
    opencti_external_hostname             = "opencti.test.local"
    opensearch_constraints                = "arch=amd64"
    prometheus_metrics_endpoint_offer_url = "admin/test-cos.prometheus-metrics-endpoint"
    prometheus_remote_write_offer_url     = "admin/test-cos.prometheus-receive-remote-write"
    rabbitmq_constraints                  = "arch=amd64"
    redis_storage                         = "1G"
  }
}
