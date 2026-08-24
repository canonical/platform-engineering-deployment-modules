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
| <a name="requirement_juju"></a> [juju](#requirement\_juju) | ~> 0.12.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | ~> 4.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | ~> 0.12.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | ~> 4.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [juju_model.service_model](https://registry.terraform.io/providers/juju/juju/latest/docs/data-sources/model) | data source |
| [vault_generic_secret.juju_controller_certificate](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.juju_credentials](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_approle_role_id"></a> [approle\_role\_id](#input\_approle\_role\_id) | Approle Role ID | `string` | n/a | yes |
| <a name="input_approle_secret_id"></a> [approle\_secret\_id](#input\_approle\_secret\_id) | Approle Secret ID | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->