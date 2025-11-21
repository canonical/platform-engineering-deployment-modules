# Wazuh Staging Deployment
Template for IS Application Environments

## Models

The Wazuh deployment requires three models: two Juju machine models for machine charms, mainly
Wazuh indexer and Wazuh dashboards, and one Juju Kubernetes model for the Wazuh manager itself
alongside some other charms. GitOps needs to be enabled only on the Kubernetes model, as all
models are managed from this environment.

## Proxy Access

HTTP proxy access is required for the Wazuh server.

The following rules are used for this staging deployment.

https://git.launchpad.net/canonical-is-internal-proxy-configs/commit/?id=53380b26db7e8941e4a9be1d667eae796531f7e7

## Firewall Rules

The firewall rules for the machine environments are defined [here](https://git.launchpad.net/canonical-is-firewalls/tree/rules/is-charms/prod-pfe-staging-wazuh-dev.yaml) and [here](https://git.launchpad.net/canonical-is-firewalls/tree/rules/is-charms/prod-pfe-staging-wazuh-dev-dashboard.yaml).
The rules for the kubernetes cluster can be found [here](https://git.launchpad.net/canonical-is-firewalls/tree/rules/is-charms/k8s-pfe-staging.yaml).

### Provider Configuration

This repository configuresthree Juju providers, using [Terraform provider aliasing](https://developer.hashicorp.com/terraform/language/providers/configuration#alias-multiple-provider-configurations). 
This makes it possible to manage different Juju models within the same
Terraform configuration.  

The default Juju provider is used for resources inside the Kubernetes model. 
The `wazuh_indexer` Juju provider is used for all resources inside the Wazuh indexer model, the `wazuh_dashboard`provider, for all resources inside the Wazuh dashboard model`.
