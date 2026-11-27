# Falco deployment

## Models

This deployment is done on top a machine model.

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.0 |
| <a name="requirement_juju"></a> [juju](#requirement\_juju) | >= 1.0, < 3.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 5.6.0, < 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | >= 1.0, < 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_falco"></a> [falco](#module\_falco) | git::https://github.com/canonical/falco-operators//falco-operator/terraform | falco-rev143&depth=1 |

## Resources

| Name | Type |
|------|------|
| [juju_integration.falco_falcosidekick_http_endpoint](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_falcosidekick_http_endpoint_offer_url"></a> [falcosidekick\_http\_endpoint\_offer\_url](#input\_falcosidekick\_http\_endpoint\_offer\_url) | Falco HTTP endpoint offer | `string` | n/a | yes |
| <a name="input_model_uuid"></a> [model\_uuid](#input\_model\_uuid) | Juju model UUID | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->