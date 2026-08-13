#!/usr/bin/env bash
# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.
#
# Runs the same Terraform lint checks as .github/workflows/lint.yaml:
# formatting check followed by tflint.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
WORKING_DIR="${REPO_ROOT}/deployments"

cd "${WORKING_DIR}"

terraform fmt -check -recursive

tflint --version
tflint --init
tflint -f compact --recursive
