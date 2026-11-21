# Mattermost deployment

Deploys [Mattermost](https://github.com/canonical/mattermost-k8s-operator) on
a PS7 Kubernetes model using the charm's product module. Mattermost is exposed
through an `ingress-configurator` application integrated with an existing
HAProxy offer (`haproxy_offer_url`), and can optionally be wired to existing
COS offers for metrics, logs and dashboards.

The module bundles `postgresql-k8s` by default. Set `deploy_postgresql = false`
to integrate an external PostgreSQL in the consuming deployment instead.

## Models

This deployment is done on top of a single Kubernetes model.

## Proxy Access

**Required.** Mattermost makes outbound calls to:

| Destination | Why |
|---|---|
| `radosgw.ps7.canonical.com` | S3 storage for file uploads |
| `mattermost.smtp.canonical.com:25` | outgoing email |
| The OAuth identity provider in `oauth_config` | user login |

## Firewall Rules

N/A

## Vault Secrets

The S3 keys (`s3_access_key`, `s3_secret_key`), the SMTP password
(`smtp_password`) and the OAuth client credentials (`oauth_config`) are
environment-specific and must be supplied by the consuming deployment.

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
| <a name="module_mattermost"></a> [mattermost](#module\_mattermost) | git::https://github.com/canonical/mattermost-k8s-operator//terraform/product | rev55&depth=1 |

## Resources

| Name | Type |
|------|------|
| [juju_application.ingress_configurator](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_integration.haproxy_ingress_configurator](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.mattermost_ingress](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deploy_postgresql"></a> [deploy\_postgresql](#input\_deploy\_postgresql) | Whether to deploy the bundled postgresql-k8s charm. Set to false to integrate an external PostgreSQL (e.g. a DBaaS offer) in the consuming deployment. | `bool` | `true` | no |
| <a name="input_external_hostname"></a> [external\_hostname](#input\_external\_hostname) | External hostname to expose Mattermost on via the ingress (e.g. chat-ps7.pfe.staging.canonical.com). | `string` | n/a | yes |
| <a name="input_grafana_dashboard_offer_url"></a> [grafana\_dashboard\_offer\_url](#input\_grafana\_dashboard\_offer\_url) | Juju offer URL for an existing Grafana dashboard provider (e.g. the PS7 COS Lite 'grafana-dashboards' offer). When set, mattermost's grafana-dashboard endpoint is integrated to this offer. Leave null to skip. | `string` | `null` | no |
| <a name="input_haproxy_offer_url"></a> [haproxy\_offer\_url](#input\_haproxy\_offer\_url) | Juju offer URL of the HAProxy ingress that the ingress-configurator integrates with over the haproxy-route relation. | `string` | n/a | yes |
| <a name="input_logging_offer_url"></a> [logging\_offer\_url](#input\_logging\_offer\_url) | Juju offer URL for an existing Loki logging provider (e.g. the PS7 COS Lite 'loki-logging' offer). When set, mattermost's logging endpoint is integrated to this offer. Leave null to skip. | `string` | `null` | no |
| <a name="input_mattermost_config"></a> [mattermost\_config](#input\_mattermost\_config) | Mattermost charm configuration | `map(string)` | `{}` | no |
| <a name="input_mattermost_units"></a> [mattermost\_units](#input\_mattermost\_units) | Number of Mattermost units to deploy | `number` | `1` | no |
| <a name="input_metrics_offer_url"></a> [metrics\_offer\_url](#input\_metrics\_offer\_url) | Juju offer URL for an existing Prometheus metrics scraper (e.g. the PS7 COS Lite 'prometheus-metrics-endpoint' offer). When set, mattermost's metrics-endpoint is integrated to this offer. Leave null to skip. | `string` | `null` | no |
| <a name="input_model_uuid"></a> [model\_uuid](#input\_model\_uuid) | Juju model UUID | `string` | n/a | yes |
| <a name="input_oauth_config"></a> [oauth\_config](#input\_oauth\_config) | Environment-specific OAuth integrator config (client\_id, client\_secret, issuer\_url and the IdP endpoints). The `scope` defaults in the module. | `map(string)` | `{}` | no |
| <a name="input_postgresql_config"></a> [postgresql\_config](#input\_postgresql\_config) | PostgreSQL charm configuration | `map(string)` | `{}` | no |
| <a name="input_postgresql_units"></a> [postgresql\_units](#input\_postgresql\_units) | Number of PostgreSQL units to deploy | `number` | `1` | no |
| <a name="input_s3_access_key"></a> [s3\_access\_key](#input\_s3\_access\_key) | S3 access key for sync-s3-credentials action | `string` | n/a | yes |
| <a name="input_s3_config"></a> [s3\_config](#input\_s3\_config) | Environment-specific S3 integrator config (typically just `bucket`). The RadosGW `endpoint` and `region` default in the module. | `map(string)` | n/a | yes |
| <a name="input_s3_secret_key"></a> [s3\_secret\_key](#input\_s3\_secret\_key) | S3 secret key for sync-s3-credentials action | `string` | n/a | yes |
| <a name="input_smtp_config"></a> [smtp\_config](#input\_smtp\_config) | Environment-specific SMTP integrator config (typically just `user`). The relay `host`/`port`/`auth_type`/`transport_security`/`smtp_sender` default in the module. | `map(string)` | n/a | yes |
| <a name="input_smtp_password"></a> [smtp\_password](#input\_smtp\_password) | SMTP AUTH password. Stored as a Juju secret and referenced by smtp-integrator via password\_secret. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mattermost"></a> [mattermost](#output\_mattermost) | Mattermost application name and required endpoints. |
| <a name="output_oauth_app_name"></a> [oauth\_app\_name](#output\_oauth\_app\_name) | Name of the OAuth external IdP integrator application. |
| <a name="output_postgresql_app_name"></a> [postgresql\_app\_name](#output\_postgresql\_app\_name) | Name of the bundled PostgreSQL application, if deployed. |
<!-- END_TF_DOCS -->
