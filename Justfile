[private]
default:
    @just --list --unsorted

[group('lint')]
renovate-lint:
    npx --yes --package renovate -- renovate-config-validator renovate.json

[group('lint')]
terraform-format:
    terraform fmt -recursive
