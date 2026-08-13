[private]
default:
    @just --list --unsorted

[group('lint')]
renovate-lint:
    npx --yes --package renovate -- renovate-config-validator renovate.json

[group('lint')]
terraform-format:
    terraform fmt -recursive

[group('lint')]
terraform-lint:
    scripts/terraform-lint.sh

[group('lint')]
renovate-comments-check:
    scripts/check-renovate-comments.py
