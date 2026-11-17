# gopkg deployment

Deploys [gopkg-k8s](https://github.com/canonical/gopkg-charmed) (the
gopkg.in versioned import-path service) on a PS7 Kubernetes model, fronted by
ingress-configurator and observed by the IS Central COS through an
OpenTelemetry Collector in the same model.

## Models

This deployment is done on top of a single Kubernetes model.

## Proxy Access

**Required.** gopkg makes outbound HTTPS calls while serving requests:

| Destination | Why | Impact if blocked |
|---|---|---|
| `github.com` | `fetchRefs()` fetches `/info/refs?service=git-upload-pack` to resolve which git tag satisfies a requested major version | **Core function fails** — no version can be resolved |
| `godoc.org`, `api.godoc.org` | package page rendering and search | HTML page degrades; `go get` still works |

`go get` only needs the `go-import` meta tag, which is served from the resolved
refs — so GitHub egress is not optional.

## Firewall Rules

- **Inbound:** HTTPS to `external_hostname` via the PS7 ingress.
- **Outbound:** HTTPS to `github.com` (required) and `godoc.org` /
  `api.godoc.org` (page rendering only). See Proxy Access above.

Rules are defined by the consuming deployment.

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
- Observability follows the IS guide "How to relate a deployment to COS": an
  `opentelemetry-collector-k8s` (`0.130/stable`, trusted) in this model takes
  gopkg's metrics (scraped in-model on `metrics-port`), logs and dashboards, and
  forwards them to the PS7 COS aggregator through three cross-model relations.
  The consuming deployment supplies the aggregator offer URLs, and its Juju
  identity must be allowed to consume them (`juju find-offers`).
- Central COS Grafana is at https://cos.ps7.admin.canonical.com/ (Canonical SSO,
  Viewer access). It shows only charm-exported dashboards: gopkg Overview and
  Go Operator.
- Central COS does not page anyone by default. Alerts need IS approval; then
  set `forward_alert_rules` and `extra_alert_labels` through
  `opentelemetry_collector_config`.

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
| <a name="module_gopkg"></a> [gopkg](#module\_gopkg) | git::https://github.com/canonical/gopkg-charmed//terraform/product | rev2&depth=1 |
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
