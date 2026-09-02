# gopkg deployment

Deploys [gopkg-charmed](https://github.com/canonical/gopkg-charmed) (the
gopkg.in versioned import-path service) on a PS7 Kubernetes model, fronted by
ingress-configurator and shipping logs to a Loki offer.

## Models

This deployment is done on top of a single Kubernetes model.

## Proxy Access

N/A — gopkg serves static import-path metadata and makes no outbound calls.

## Firewall Rules

Inbound HTTPS to `external_hostname` via the PS7 ingress. Rules are defined by
the consuming deployment.

## Vault Secrets

N/A — no secrets are read by this module. Everything sensitive arrives as an
input from the consuming deployment.

## Notes

- The gopkg product module bundles `nginx-ingress-integrator` for local and
  tutorial use. This deployment sets `deploy_ingress = false` and wires
  `ingress-configurator` instead, matching `falcosidekick/ps7`.
- `external_hostname` is threaded into both the ingress `hostname` config and
  gopkg's own `hostname` charm config, so the go-import metadata gopkg renders
  matches the host actually serving it.
- gopkg serves versioned import paths such as `/yaml.v2` and needs the original
  request path. ingress-configurator does not rewrite paths, so no extra
  configuration is required here.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.0 |
| <a name="requirement_juju"></a> [juju](#requirement\_juju) | >= 1.0, < 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | >= 1.0, < 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gopkg"></a> [gopkg](#module\_gopkg) | git::https://github.com/canonical/gopkg-charmed//terraform/product | rev1&depth=1 |
| <a name="module_ingress_configurator"></a> [ingress\_configurator](#module\_ingress\_configurator) | git::https://github.com/canonical/ingress-configurator-operator//terraform | ingress-configurator-rev103&depth=1 |

## Resources

| Name | Type |
|------|------|
| [juju_integration.gopkg_ingress](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_external_hostname"></a> [external\_hostname](#input\_external\_hostname) | Public hostname for gopkg. Configured on ingress-configurator and threaded into gopkg's hostname config. | `string` | n/a | yes |
| <a name="input_gopkg_config"></a> [gopkg\_config](#input\_gopkg\_config) | gopkg charm configuration. `hostname` is set from external\_hostname; other keys are passed through. | `map(string)` | `{}` | no |
| <a name="input_gopkg_units"></a> [gopkg\_units](#input\_gopkg\_units) | Number of gopkg units to deploy | `number` | `1` | no |
| <a name="input_grafana_dashboard_offer_url"></a> [grafana\_dashboard\_offer\_url](#input\_grafana\_dashboard\_offer\_url) | Grafana dashboard offer URL for gopkg's grafana-dashboard endpoint. Leave null to skip. | `string` | `null` | no |
| <a name="input_loki_offer_url"></a> [loki\_offer\_url](#input\_loki\_offer\_url) | Loki offer URL for gopkg to push logs to | `string` | n/a | yes |
| <a name="input_model_uuid"></a> [model\_uuid](#input\_model\_uuid) | Juju model UUID | `string` | n/a | yes |
| <a name="input_prometheus_offer_url"></a> [prometheus\_offer\_url](#input\_prometheus\_offer\_url) | Prometheus scrape offer URL for gopkg's metrics-endpoint. Leave null to skip. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_components"></a> [components](#output\_components) | All Terraform charm modules which make up this product module |
<!-- END_TF_DOCS -->
