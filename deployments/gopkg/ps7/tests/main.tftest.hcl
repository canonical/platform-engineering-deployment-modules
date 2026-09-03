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
    model_uuid        = run.setup_tests.model_uuid
    external_hostname = "gopkg.test.local"
    loki_offer_url    = "admin/test-cos.loki-logging"
  }

  assert {
    condition     = output.components.gopkg.gopkg.app_name == "gopkg-charned"
    error_message = "gopkg app_name did not match expected"
  }

  assert {
    condition     = output.components.ingress_configurator.application.name == "ingress-configurator"
    error_message = "ingress-configurator app_name did not match expected"
  }
}
