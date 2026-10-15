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
    model_uuid    = run.setup_tests.model_uuid
    s3_access_key = "test-access-key"
    s3_secret_key = "test-secret-key"
    s3_config = {
      bucket   = "test-bucket"
      endpoint = "https://s3.example.com"
    }
    smtp_config = {
      host = "smtp.example.com"
      port = "587"
    }
    external_hostname = "chat.example.com"
    haproxy_offer_url = "test-uuid@serviceaccount/test-offer.haproxy"
  }

  assert {
    condition     = output.mattermost.app_name == "mattermost-k8s"
    error_message = "mattermost app_name did not match expected"
  }
}

run "cos_lite_offers" {
  command = plan

  variables {
    model_uuid    = run.setup_tests.model_uuid
    s3_access_key = "test-access-key"
    s3_secret_key = "test-secret-key"
    s3_config = {
      bucket   = "test-bucket"
      endpoint = "https://s3.example.com"
    }
    smtp_config = {
      host = "smtp.example.com"
      port = "587"
    }
    external_hostname = "chat.example.com"
    haproxy_offer_url = "test-uuid@serviceaccount/test-offer.haproxy"

    metrics_offer_url           = "test-uuid@serviceaccount/test.prometheus-metrics-endpoint"
    logging_offer_url           = "test-uuid@serviceaccount/test.loki-logging"
    grafana_dashboard_offer_url = "test-uuid@serviceaccount/test.grafana-dashboards"
  }

  assert {
    condition     = output.mattermost.provides.metrics_endpoint == "metrics-endpoint"
    error_message = "metrics_endpoint provides endpoint did not match expected"
  }
}
