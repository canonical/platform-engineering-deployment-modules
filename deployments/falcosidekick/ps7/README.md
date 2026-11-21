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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.0 |
| <a name="requirement_juju"></a> [juju](#requirement\_juju) | >= 1.0, < 3.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | > 5.6.0, < 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | >= 1.0, < 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_falcosidekick"></a> [falcosidekick](#module\_falcosidekick) | git::https://github.com/canonical/falco-operators//falcosidekick-k8s-operator/terraform | falco-rev143&depth=1 |
| <a name="module_ingress_configurator"></a> [ingress\_configurator](#module\_ingress\_configurator) | git::https://github.com/canonical/ingress-configurator-operator//terraform | rev95&depth=1 |

## Resources

| Name | Type |
|------|------|
| [juju_integration.falcosidekick_ingress](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.falcosidekick_loki](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.falcosidekick_send_loki_logs](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_offer.falcosidekick_http_endpoint](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/offer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_external_hostname"></a> [external\_hostname](#input\_external\_hostname) | Hostname to configure on the ingress configurator charm | `string` | n/a | yes |
| <a name="input_loki_offer_url"></a> [loki\_offer\_url](#input\_loki\_offer\_url) | Loki offer URL | `string` | n/a | yes |
| <a name="input_model_uuid"></a> [model\_uuid](#input\_model\_uuid) | Juju model UUID | `string` | n/a | yes |
| <a name="input_send_loki_logs_offer_url"></a> [send\_loki\_logs\_offer\_url](#input\_send\_loki\_logs\_offer\_url) | Loki offer URL for Faclo sidekick to export the logs | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_components"></a> [components](#output\_components) | All Terraform charm modules which make up this product module |
| <a name="output_falcosidekick_http_endpoint_offer_url"></a> [falcosidekick\_http\_endpoint\_offer\_url](#output\_falcosidekick\_http\_endpoint\_offer\_url) | n/a |
<!-- END_TF_DOCS -->