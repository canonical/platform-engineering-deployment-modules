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
    model_name                  = run.setup_tests.model_name
    model_uuid                  = run.setup_tests.model_uuid
    username                    = "test-user"
    password                    = "test-password"
    lego_certificates_consumers = []
  }
}
