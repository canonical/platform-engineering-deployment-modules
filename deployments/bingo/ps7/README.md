# Bingo deployment module (PS7)

## Models

This deployment is done on top of a single Kubernetes model. It wraps the
bingo [Layer 1 product module][bingo-product-module] and pins the
channel/revision of every bundled charm (`bingo`, `postgresql-k8s`,
`oauth-external-idp-integrator`) for the PS7 stack. Ingress is intentionally
**not** deployed here — it is managed by the consuming Layer 3 deployment.

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
| <a name="requirement_juju"></a> [juju](#requirement\_juju) | >= 2.2.0, < 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | >= 2.2.0, < 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bingo"></a> [bingo](#module\_bingo) | git::https://github.com/canonical/bingo//terraform/product | tf-1.0.0&depth=1 |

## Resources

| Name | Type |
|------|------|
| [juju_application.ingress_configurator](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_integration.bingo_ingress](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.bingo_postgresql_offer](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.haproxy_ingress_configurator](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bingo_config"></a> [bingo\_config](#input\_bingo\_config) | bingo charm configuration (base-url, max-paste-size-bytes, log-level, web-dir, oauth-redirect-path, oauth-scopes, oauth-user-name-attribute). | `map(string)` | `{}` | no |
| <a name="input_bingo_units"></a> [bingo\_units](#input\_bingo\_units) | Number of bingo units to deploy. | `number` | `1` | no |
| <a name="input_external_hostname"></a> [external\_hostname](#input\_external\_hostname) | External hostname to expose bingo on via the ingress (e.g. paste-ps7.pfe.staging.canonical.com). | `string` | n/a | yes |
| <a name="input_haproxy_offer_url"></a> [haproxy\_offer\_url](#input\_haproxy\_offer\_url) | Juju offer URL of the HAProxy ingress that the ingress-configurator integrates with over the haproxy-route relation. | `string` | n/a | yes |
| <a name="input_model_uuid"></a> [model\_uuid](#input\_model\_uuid) | Juju model UUID | `string` | n/a | yes |
| <a name="input_oauth_config"></a> [oauth\_config](#input\_oauth\_config) | oauth-external-idp-integrator charm configuration (issuer\_url, client\_id, client\_secret, scope, etc.). Marked sensitive because it carries the IdP client secret. | `map(string)` | `{}` | no |
| <a name="input_postgresql_config"></a> [postgresql\_config](#input\_postgresql\_config) | PostgreSQL K8s charm configuration. | `map(string)` | `{}` | no |
| <a name="input_postgresql_offer_url"></a> [postgresql\_offer\_url](#input\_postgresql\_offer\_url) | Juju offer URL of an external PostgreSQL (e.g. a DBaaS offer) to integrate bingo with. If set, the bundled postgresql-k8s charm is not deployed and bingo integrates with this offer instead. If unset (null), the bundled postgresql-k8s charm is deployed. | `string` | `null` | no |
| <a name="input_postgresql_units"></a> [postgresql\_units](#input\_postgresql\_units) | Number of PostgreSQL units to deploy. | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bingo"></a> [bingo](#output\_bingo) | bingo application name and relation endpoint names. |
| <a name="output_oauth_app_name"></a> [oauth\_app\_name](#output\_oauth\_app\_name) | Name of the bundled oauth-external-idp-integrator application. |
| <a name="output_postgresql_app_name"></a> [postgresql\_app\_name](#output\_postgresql\_app\_name) | Name of the bundled PostgreSQL application, if deployed. |
<!-- END_TF_DOCS -->

[bingo-product-module]: https://github.com/canonical/bingo/tree/main/terraform/product
