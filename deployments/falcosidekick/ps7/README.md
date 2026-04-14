# Falco sidekick deployment

## Models

This deployment is done on top a single Kubernetes model.

## Proxy Access

N/A

## Firewall Rules

N/A

## Vault Secrets

N/A

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