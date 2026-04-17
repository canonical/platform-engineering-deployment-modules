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
    model_name                            = run.setup_tests.model_name
    model_uuid                            = run.setup_tests.model_uuid
    external_hostname                     = "test.local"
    loki_offer_url                        = "admin/test-cos.loki-logging"
    send_loki_logs_offer_url              = "admin/test-cos.loki-logging"
    falcosidekick_http_endpoint_consumers = []
  }

  assert {
    condition     = output.components.falcosidekick.app_name == "falcosidekick"
    error_message = "falcosidekick app_name did not match expected"
  }
}
