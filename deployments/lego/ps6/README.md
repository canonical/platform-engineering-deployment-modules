# LEGO deployment

Deploys the [lego](https://github.com/canonical/lego-operator) charm on PS6 to
issue TLS certificates through the `httpreq` DNS plugin backed by
`lego-certs.canonical.com`. The `certificates` endpoint is shared through the
`lego-certificates` offer with the models listed in
`lego_certificates_consumers`.

## Models

This deployment is done on top of a single machine model.

## Proxy Access

**Required.** lego makes outbound HTTPS calls to:

| Destination | Why |
|---|---|
| `lego-certs.canonical.com` | `httpreq` plugin endpoint used to publish the DNS-01 challenge records |
| The ACME server configured in the charm | certificate orders and challenge validation |

## Firewall Rules

N/A

## Vault Secrets

The `httpreq` credentials are passed through the `username` and `password`
variables and stored as the `lego-credentials` Juju secret.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
