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

## Inputs

| Name | Type | Required | Description |
|---|---|---|---|
| `model_uuid` | `string` | yes | Juju model UUID. |
| `external_hostname` | `string` | yes | Public hostname. Set on ingress-configurator and threaded into gopkg's `hostname` config so go-import metadata matches. Bare host only. |
| `loki_offer_url` | `string` | yes | Loki offer URL for gopkg's `logging` endpoint. |
| `gopkg_config` | `map(string)` | no | Extra gopkg charm config. `hostname` is set from `external_hostname`. |
| `gopkg_units` | `number` | no | Units to deploy (default `1`). |
| `prometheus_offer_url` | `string` | no | Prometheus scrape offer for `metrics-endpoint`. |
| `grafana_dashboard_offer_url` | `string` | no | Grafana dashboard offer for `grafana-dashboard`. |

## Outputs

| Name | Description |
|---|---|
| `components` | All Terraform charm modules which make up this product module: `gopkg` (`{ gopkg = { app_name, requires, provides }, ingress_app_name }`) and `ingress_configurator`. |

## Notes

- The gopkg product module bundles `nginx-ingress-integrator` for local and
  tutorial use. This deployment sets `deploy_ingress = false` and wires
  `ingress-configurator` instead, matching `falcosidekick/ps7`.
- gopkg serves versioned import paths such as `/yaml.v2` and needs the
  original request path. ingress-configurator does not rewrite paths, so no
  extra configuration is required here.
