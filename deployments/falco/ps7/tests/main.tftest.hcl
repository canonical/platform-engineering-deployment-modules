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
    model_uuid                            = run.setup_tests.model_uuid
    falcosidekick_http_endpoint_offer_url = "admin/test-falcosidekick.falcosidekick-http-endpoint"
  }
}
