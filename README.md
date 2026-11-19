# Platform Engineering deployment modules

This repository contains the terraform modules to deploy environments.

## Structure

All deployments are stored in [deployments](/deployments) in a 2-level hierarchy: `<product>/<cloud>`:

- The first `<product>` level privileges the discoverability of the deployments assuming team members will look for deployments related to a specific product.
- The second `<cloud>` level (which is mandatory) anticipates the fact that we will most likely have multiple deployments of the product at some point in time due to different cloud requirements.

## Usage

Reuse the module definitions where applicable.

## Versioning

Every module (`deployments/<product>/<cloud>`) is versioned independently. When a merge to `main` changes files of a module, the [tag workflow](.github/workflows/tag_on_merge.yaml) creates the tag `<product>-<cloud>/<YYYY.MM.DD>.<n>` (for example `wazuh-ps6/2026.11.19.292`), where `<n>` is the previous build number of that module plus one. Modules that were not touched by the merge are not tagged, so consumers only see a new version when the module they use changed.

The global `main.<YYYY.MM.DD>.<n>` tag is still created during the transition to per-module tags and will be removed later. `scripts/backfill_module_tags.sh` creates the per-module tags matching the existing global tags.
