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
    model_uuid = run.setup_tests.model_uuid
    oauth_config = {
      issuer_url    = "https://example-idp.test"
      client_id     = "test-client"
      client_secret = "test-secret"
    }
    external_hostname = "paste.example.com"
    haproxy_offer_url = "test-uuid@serviceaccount/test-offer.haproxy"
  }

  assert {
    condition     = output.bingo.app_name == "bingo"
    error_message = "bingo app_name did not match expected"
  }
}

run "external_postgresql_plan" {
  command = plan

  variables {
    model_uuid = run.setup_tests.model_uuid
    oauth_config = {
      issuer_url    = "https://example-idp.test"
      client_id     = "test-client"
      client_secret = "test-secret"
    }
    external_hostname    = "paste.example.com"
    haproxy_offer_url    = "test-uuid@serviceaccount/test-offer.haproxy"
    deploy_postgresql    = false
    postgresql_offer_url = "test-uuid@serviceaccount/test-offer.postgresql"
  }

  assert {
    condition     = output.postgresql_app_name == null
    error_message = "postgresql_app_name should be null when deploy_postgresql = false"
  }
}
