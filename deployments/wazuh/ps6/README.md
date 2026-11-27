# Wazuh Deployment
Template for IS Application Environments

## Dashboard Ingress

Every deployment of this module provisions haproxy and an `ingress-configurator`
application in the Wazuh Dashboard model, fronting the Wazuh Dashboard. The
public hostname and dashboard backend unit addresses are per-environment and
must be supplied via the `dashboard_ingress_hostname` and
`dashboard_ingress_backend_addresses` variables.

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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.6 |
| <a name="requirement_juju"></a> [juju](#requirement\_juju) | < 2.5 |
| <a name="requirement_openstack"></a> [openstack](#requirement\_openstack) | >= 1.54 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 5.6, < 6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | < 2.5 |
| <a name="provider_juju.wazuh_dashboard"></a> [juju.wazuh\_dashboard](#provider\_juju.wazuh\_dashboard) | < 2.5 |
| <a name="provider_juju.wazuh_indexer"></a> [juju.wazuh\_indexer](#provider\_juju.wazuh\_indexer) | < 2.5 |
| <a name="provider_openstack"></a> [openstack](#provider\_openstack) | >= 1.54 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | >= 5.6, < 6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_haproxy"></a> [haproxy](#module\_haproxy) | git::https://github.com/canonical/haproxy-operator//terraform/product | tf-manual&depth=1 |
| <a name="module_wazuh"></a> [wazuh](#module\_wazuh) | git::https://github.com/canonical/wazuh-server-operator//terraform/product | wazuh-server-rev304&depth=1 |

## Resources

| Name | Type |
|------|------|
| [juju_access_offer.lego](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/access_offer) | resource |
| [juju_access_secret.git_ssh_key_access](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/access_secret) | resource |
| [juju_access_secret.lego_credentials_access](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/access_secret) | resource |
| [juju_access_secret.wazuh_indexer_backup_credentials_access](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/access_secret) | resource |
| [juju_application.ingress_configurator](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.landscape_client](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.landscape_client_dashboard](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.landscape_client_noble](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.lego](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.ubuntu_pro](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.ubuntu_pro_dashboard](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.ubuntu_pro_noble](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_integration.grafana_agent_dashboard_grafana](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.grafana_agent_dashboard_loki](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.grafana_agent_dashboard_prometheus](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.grafana_agent_indexer_grafana](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.grafana_agent_indexer_loki](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.grafana_agent_indexer_prometheus](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.haproxy_ca_certs](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.haproxy_ingress](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.haproxy_lego](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.landscape_client](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.landscape_client_dashboard](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.landscape_client_noble](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.traefik_dashboard](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.traefik_loki](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.traefik_prometheus](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.ubuntu_pro](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.ubuntu_pro_dashboard](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.ubuntu_pro_noble](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.wazuh_opencti](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.wazuh_server_certificates](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.wazuh_server_dashboard](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.wazuh_server_loki](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.wazuh_server_prometheus](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_offer.lego](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/offer) | resource |
| [juju_secret.git_ssh_key](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/secret) | resource |
| [juju_secret.lego_credentials](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/secret) | resource |
| [juju_secret.wazuh_indexer_backup_credentials](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/secret) | resource |
| [openstack_identity_ec2_credential_v3.wazuh_indexer_s3_creds](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/identity_ec2_credential_v3) | resource |
| [openstack_objectstorage_container_v1.wazuh_indexer_backup](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/objectstorage_container_v1) | resource |
| [vault_generic_secret.git_ssh_key](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.landscape_registration_key](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.lego_credentials](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.s3](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.ubuntu_pro_token](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dashboard_ingress_backend_addresses"></a> [dashboard\_ingress\_backend\_addresses](#input\_dashboard\_ingress\_backend\_addresses) | Comma-separated Wazuh Dashboard unit IP addresses used as ingress-configurator backend-addresses | `string` | n/a | yes |
| <a name="input_dashboard_ingress_backend_ports"></a> [dashboard\_ingress\_backend\_ports](#input\_dashboard\_ingress\_backend\_ports) | Backend port used by the ingress-configurator to reach the Wazuh Dashboard | `number` | `5601` | no |
| <a name="input_dashboard_ingress_backend_protocol"></a> [dashboard\_ingress\_backend\_protocol](#input\_dashboard\_ingress\_backend\_protocol) | Backend protocol used by the ingress-configurator to reach the Wazuh Dashboard | `string` | `"https"` | no |
| <a name="input_dashboard_ingress_hostname"></a> [dashboard\_ingress\_hostname](#input\_dashboard\_ingress\_hostname) | Hostname exposed for the Wazuh Dashboard via the haproxy ingress-configurator | `string` | n/a | yes |
| <a name="input_dashboard_model_name"></a> [dashboard\_model\_name](#input\_dashboard\_model\_name) | Juju model for Wazuh Dashboard | `string` | n/a | yes |
| <a name="input_dashboard_model_uuid"></a> [dashboard\_model\_uuid](#input\_dashboard\_model\_uuid) | Juju model UUID for Wazuh Dashboard | `string` | n/a | yes |
| <a name="input_grafana_offer_url"></a> [grafana\_offer\_url](#input\_grafana\_offer\_url) | Grafana offer URL | `string` | n/a | yes |
| <a name="input_indexer_consumers"></a> [indexer\_consumers](#input\_indexer\_consumers) | Additional model names that need consume access to the indexer offer | `list(string)` | `[]` | no |
| <a name="input_indexer_model_name"></a> [indexer\_model\_name](#input\_indexer\_model\_name) | Juju model for Wazuh Indexer | `string` | n/a | yes |
| <a name="input_indexer_model_uuid"></a> [indexer\_model\_uuid](#input\_indexer\_model\_uuid) | Juju model UUID for Wazuh Indexer | `string` | n/a | yes |
| <a name="input_logs_ca_certificate"></a> [logs\_ca\_certificate](#input\_logs\_ca\_certificate) | CA certificate used for authenticating the log producers | `string` | n/a | yes |
| <a name="input_loki_offer_url"></a> [loki\_offer\_url](#input\_loki\_offer\_url) | Loki offer URL | `string` | n/a | yes |
| <a name="input_opencti_offer_url"></a> [opencti\_offer\_url](#input\_opencti\_offer\_url) | OpenCTI offer URL | `string` | n/a | yes |
| <a name="input_prometheus_metrics_endpoint_offer_url"></a> [prometheus\_metrics\_endpoint\_offer\_url](#input\_prometheus\_metrics\_endpoint\_offer\_url) | Prometheus metrics offer URL | `string` | n/a | yes |
| <a name="input_prometheus_remote_write_offer_url"></a> [prometheus\_remote\_write\_offer\_url](#input\_prometheus\_remote\_write\_offer\_url) | Prometheus removete write offer URL | `string` | n/a | yes |
| <a name="input_server_model_name"></a> [server\_model\_name](#input\_server\_model\_name) | Juju model for Wazuh Server | `string` | n/a | yes |
| <a name="input_server_model_uuid"></a> [server\_model\_uuid](#input\_server\_model\_uuid) | Juju model UUID for Wazuh Server | `string` | n/a | yes |
| <a name="input_wazuh_custom_config_repository"></a> [wazuh\_custom\_config\_repository](#input\_wazuh\_custom\_config\_repository) | Repository URL for Wazuh confioguration | `string` | n/a | yes |
| <a name="input_wazuh_dashboard_constraints"></a> [wazuh\_dashboard\_constraints](#input\_wazuh\_dashboard\_constraints) | Constraints for the Wazuh Dashboard | `string` | n/a | yes |
| <a name="input_wazuh_external_hostname"></a> [wazuh\_external\_hostname](#input\_wazuh\_external\_hostname) | The external hostname for Wazuh | `string` | n/a | yes |
| <a name="input_wazuh_indexer_config"></a> [wazuh\_indexer\_config](#input\_wazuh\_indexer\_config) | PromConfig for the Wazuh Indexer | `map(string)` | `{}` | no |
| <a name="input_wazuh_indexer_constraints"></a> [wazuh\_indexer\_constraints](#input\_wazuh\_indexer\_constraints) | Constraints for the Wazuh Indexer | `string` | n/a | yes |
| <a name="input_wazuh_indexer_units"></a> [wazuh\_indexer\_units](#input\_wazuh\_indexer\_units) | Number of units for the Wazuh Indexer | `number` | `3` | no |
| <a name="input_wazuh_server_storage"></a> [wazuh\_server\_storage](#input\_wazuh\_server\_storage) | Storage constraints for the Wazuh Server | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_haproxy_app_name"></a> [haproxy\_app\_name](#output\_haproxy\_app\_name) | Name of the deployed haproxy application. |
| <a name="output_ingress_configurator_app_name"></a> [ingress\_configurator\_app\_name](#output\_ingress\_configurator\_app\_name) | Name of the deployed ingress-configurator application. |
| <a name="output_lego_app_name"></a> [lego\_app\_name](#output\_lego\_app\_name) | Name of the deployed Lego application. |
| <a name="output_lego_offer_url"></a> [lego\_offer\_url](#output\_lego\_offer\_url) | n/a |
| <a name="output_lego_provides"></a> [lego\_provides](#output\_lego\_provides) | n/a |
| <a name="output_s3_creds"></a> [s3\_creds](#output\_s3\_creds) | n/a |
| <a name="output_self_signed_certificates_app_name"></a> [self\_signed\_certificates\_app\_name](#output\_self\_signed\_certificates\_app\_name) | Name of the deployed self-signed-certificates application. |
| <a name="output_self_signed_certificates_offer_url"></a> [self\_signed\_certificates\_offer\_url](#output\_self\_signed\_certificates\_offer\_url) | n/a |
<!-- END_TF_DOCS -->
