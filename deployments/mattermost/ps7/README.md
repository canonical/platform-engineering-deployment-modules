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
<!-- END_TF_DOCS -->
