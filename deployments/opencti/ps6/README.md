# OpenCTI Deployment

## Models

The OpenCTI deployment requires two models: one Juju machine model for machine
charms (OpenSearch, RabbitMQ), and one Juju Kubernetes model for OpenCTI itself
and some other Kubernetes charms. GitOps needs to be enabled only on the 
Kubernetes model, as this Terraform plan is designed to manage both models 
simultaneously. 

A specific requirement for the OpenCTI Kubernetes model is adding 
`remote_cmr_models` and `additional_vault_token_policies` for the machine 
database model. See the example here: https://github.com/canonical/infrastructure-services/blob/main/services/definitions/compute/k8s-pfe-staging.yaml#L66

## Proxy Access

HTTP proxy access is required for OpenCTI connectors.

The following rules are used for this staging deployment. It only covers 
connectors deployed in the staging environment. If additional connectors are 
required in the future, the list will need to be updated.

https://git.launchpad.net/canonical-is-internal-proxy-configs/commit/?id=4f1d53e29d203ae2b8e392c267b40430a073bc11

## Firewall Rules

OpenCTI charms within the Kubernetes model require access to the OpenSearch, 
AMQP, and AMQP management endpoints within the machine database model.

Rules used for the staging deployment:

https://git.launchpad.net/canonical-is-firewalls/tree/rules/is-charms/prod-pfe-staging-opencti-db.yaml

## Vault Secrets

### S3 (RADOS) Credential

The Vault secret `secret/prodstack6/roles/k8s-pfe-staging-opencti/s3` is automatically 
created by infrastructure services and contains the S3 credentials required 
for deployment.

### httpreq (lego-certs.canonical.com) Credential

The Vault secret `secret/prodstack6/roles/k8s-pfe-staging-opencti/httpreq` stores the 
credential for lego-certs.canonical.com, which can be used to obtain HTTPS 
certificates for the OpenCTI services. The Vault secret contains two fields, 
`username` and `password`, which are the username and password for 
lego-certs.canonical.com, respectively.

Create an IS ticket to obtain this credential.

### API Keys

Some OpenCTI connectors require an API key to function. 

Contact the security team to obtain an API key.

The current staging environment uses the following vault secrets to store API 
keys for connectors.

- abuseipdb-ipblacklist
  - path: `secret/prodstack6/roles/k8s-pfe-staging-opencti/abuseipdb-ipblacklist`
  - fields: `api-key`
  - content: AbuseIPDB API key

- alienvault
  - path: `secret/prodstack6/roles/k8s-pfe-staging-opencti/alienvault`
  - fields: `api-key`
  - content: AlienVault API key

- crowdstrike
  - path: `secret/prodstack6/roles/k8s-pfe-staging-opencti/crowdstrike`
  - fields: `client-id`, `client-secret`
  - content: CrowdStrike client ID and secret

- ipinfo
  - path: `secret/prodstack6/roles/k8s-pfe-staging-opencti/ipinfo`
  - fields: `token`
  - content: IPinfo API token

- sekoia
  - path: `secret/prodstack6/roles/k8s-pfe-staging-opencti/sekoia`
  - fields: `api-key`
  - content: Sekoia API token

### DNS Entry  

The DNS entry for this environment is defined here:

https://git.launchpad.net/canonical-is-dns-configs/tree/public/canonical.com.domain#n2134

### High Availability

The OpenCTI charm can be scaled horizontally by adding more units. Currently, 
it has three units.

The OpenSearch charm can also be scaled horizontally by adding more units. 
Currently, it has three units.  

The OpenCTI charm does not yet support Redis-K8s in high availability mode but 
will in the future.  

The OpenCTI charm does not support the RabbitMQ-Server charm in high 
availability mode due to the limitations of the RabbitMQ-Server charm.

OpenCTI connectors don't support high availability mode.

Other charms in this deployment don't need high availability.

### Provider Configuration

The provider configuration ([`providers.tf`](./providers.tf)) differs slightly
from the template provider configuration. The key difference is that there are
two Juju providers, using [Terraform provider aliasing](https://developer.hashicorp.com/terraform/language/providers/configuration#alias-multiple-provider-configurations). 
This makes it possible to manage two different Juju models within the same
Terraform configuration.  

The default Juju provider is used for resources inside the Kubernetes model. 
The `opencti_db` Juju provider is used for all resources inside the machine 
database model. All Juju credential vault secrets are created by the 
infrastructure services. However, accessing the machine database model's 
credentials requires `additional_vault_token_policies`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.6 |
| <a name="requirement_juju"></a> [juju](#requirement\_juju) | >= 1.0, < 3.0 |
| <a name="requirement_openstack"></a> [openstack](#requirement\_openstack) | 3.4.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 5.6.0, < 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | >= 1.0, < 3.0 |
| <a name="provider_juju.opencti_db"></a> [juju.opencti\_db](#provider\_juju.opencti\_db) | >= 1.0, < 3.0 |
| <a name="provider_openstack"></a> [openstack](#provider\_openstack) | 3.4.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | >= 5.6.0, < 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_opencti"></a> [opencti](#module\_opencti) | git::https://github.com/canonical/opencti-operator//terraform/product | opencti-rev131&depth=1 |

## Resources

| Name | Type |
|------|------|
| [juju_access_offer.opencti_connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/access_offer) | resource |
| [juju_access_secret.lego_credentials_access](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/access_secret) | resource |
| [juju_access_secret.opencti-admin-access](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/access_secret) | resource |
| [juju_application.gateway-api-integrator](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.gateway-route-configurator](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.grafana-agent](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.landscape-client](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.lego](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-abuseipdb-ipblacklist-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-alienvault-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-cisa-kev-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-crowdstrike-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-cyber-campaign-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-export-file-csv-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-export-file-stix-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-export-file-txt-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-import-document-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-import-file-stix-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-ipinfo-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-malwarebazaar-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-misp-feed-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-mitre-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-sekoia-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-urlhaus-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-vxvault-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.opencti-woap-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_application.ubuntu_pro](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_integration.gateway-api-route](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.grafana-agent-cos](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.ingress](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.landscape_client](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.opencti-connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.opencti-connector-loki](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.opencti-grafana](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.opencti-loki](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.opencti-prometheus-scrape](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.tls-certificates](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.ubuntu_pro](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.woap_connector_indexer](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_offer.opencti_connector](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/offer) | resource |
| [juju_secret.lego_credentials](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/secret) | resource |
| [juju_secret.opencti-admin](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/secret) | resource |
| [openstack_identity_ec2_credential_v3.opencti_s3_creds](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/3.4.0/docs/resources/identity_ec2_credential_v3) | resource |
| [openstack_identity_ec2_credential_v3.opensearch_backup_s3_creds](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/3.4.0/docs/resources/identity_ec2_credential_v3) | resource |
| [openstack_objectstorage_container_v1.opencti](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/3.4.0/docs/resources/objectstorage_container_v1) | resource |
| [openstack_objectstorage_container_v1.opensearch_backup](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/3.4.0/docs/resources/objectstorage_container_v1) | resource |
| [vault_generic_secret.abuseipdb-ipblacklist](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.alienvault](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.crowdstrike](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.ipinfo](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.landscape_registration_key](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.lego_credentials](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.opencti-admin](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.s3](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.s3_opensearch](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.sekoia](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.ubuntu_pro_token](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_model_name"></a> [db\_model\_name](#input\_db\_model\_name) | Juju model for OpenCTI DB | `string` | n/a | yes |
| <a name="input_db_model_uuid"></a> [db\_model\_uuid](#input\_db\_model\_uuid) | Juju model UUID for OpenCTI DB | `string` | n/a | yes |
| <a name="input_grafana_offer_url"></a> [grafana\_offer\_url](#input\_grafana\_offer\_url) | Grafana offer URL | `string` | n/a | yes |
| <a name="input_indexer_offer_url"></a> [indexer\_offer\_url](#input\_indexer\_offer\_url) | Indexer offer URL | `string` | n/a | yes |
| <a name="input_loki_offer_url"></a> [loki\_offer\_url](#input\_loki\_offer\_url) | Loki offer URL | `string` | n/a | yes |
| <a name="input_model_name"></a> [model\_name](#input\_model\_name) | Juju model for OpenCTI | `string` | n/a | yes |
| <a name="input_model_uuid"></a> [model\_uuid](#input\_model\_uuid) | Juju model UUID for OpenCTI | `string` | n/a | yes |
| <a name="input_opencti_consumers"></a> [opencti\_consumers](#input\_opencti\_consumers) | List of models that consume the OpenCTI offer | `list(string)` | n/a | yes |
| <a name="input_opencti_external_hostname"></a> [opencti\_external\_hostname](#input\_opencti\_external\_hostname) | The external hostname for OpenCTI | `string` | n/a | yes |
| <a name="input_opensearch_config"></a> [opensearch\_config](#input\_opensearch\_config) | OpenSearch configuration | `map(string)` | `{}` | no |
| <a name="input_opensearch_constraints"></a> [opensearch\_constraints](#input\_opensearch\_constraints) | OpenSearch constraints | `string` | n/a | yes |
| <a name="input_prometheus_metrics_endpoint_offer_url"></a> [prometheus\_metrics\_endpoint\_offer\_url](#input\_prometheus\_metrics\_endpoint\_offer\_url) | Prometheus metrics offer URL | `string` | n/a | yes |
| <a name="input_prometheus_remote_write_offer_url"></a> [prometheus\_remote\_write\_offer\_url](#input\_prometheus\_remote\_write\_offer\_url) | Prometheus removete write offer URL | `string` | n/a | yes |
| <a name="input_rabbitmq_constraints"></a> [rabbitmq\_constraints](#input\_rabbitmq\_constraints) | RabbitMQ constraints | `string` | n/a | yes |
| <a name="input_redis_storage"></a> [redis\_storage](#input\_redis\_storage) | Redis storage | `string` | n/a | yes |
| <a name="input_self_signed_certificates_units"></a> [self\_signed\_certificates\_units](#input\_self\_signed\_certificates\_units) | Number of self-signed-certificates units | `number` | `3` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->