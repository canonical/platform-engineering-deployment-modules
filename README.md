# Platform Engineering deployment modules

This repository contains the terraform modules to deploy environments.

## Structure

All deployments are stored in [deployments](/deployments) in a 2-level hierarchy: `<product>/<cloud>`:

- The first `<product>` level privileges the discoverability of the deployments assuming team members will look for deployments related to a specific product.
- The second `<cloud>` level (which is mandatory) anticipates the fact that we will most likely have multiple deployments of the product at some point in time due to different cloud requirements.

## Usage

Reuse the module definitions in [`platform-engineering-deployments`](https://github.com/canonical/platform-engineering-deployments) or anywhere else applicable.