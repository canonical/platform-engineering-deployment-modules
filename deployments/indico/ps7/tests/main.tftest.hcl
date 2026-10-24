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
    model_uuid        = run.setup_tests.model_uuid
    indico_revision   = 338
    external_hostname = "events-ps7.pfe.staging.canonical.com"
    haproxy_offer_url = "example-controller:admin/ingress.haproxy-route"

    s3_access_key = "test-access-key"
    s3_secret_key = "test-secret-key"
    s3_config = {
      bucket   = "test-bucket"
      endpoint = "https://s3.example.com"
    }
    smtp_config = {
      host = "smtp.example.com"
      port = "25"
    }
    oauth_config = {
      client_id     = "test-client-id"
      client_secret = "test-client-secret"
    }
  }

  assert {
    condition     = juju_application.ingress_configurator.name == "ingress-configurator"
    error_message = "ingress-configurator app name did not match expected"
  }
}
