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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.6 |
| <a name="requirement_juju"></a> [juju](#requirement\_juju) | >= 1.0, < 3.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 5.6, < 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | >= 1.0, < 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lego"></a> [lego](#module\_lego) | git::https://github.com/canonical/lego-operator//terraform | rev563&depth=1 |

## Resources

| Name | Type |
|------|------|
| [juju_access_offer.lego_certificates](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/access_offer) | resource |
| [juju_access_secret.lego_credentials_access](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/access_secret) | resource |
| [juju_offer.lego_certificates](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/offer) | resource |
| [juju_secret.lego_credentials](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_lego_certificates_consumers"></a> [lego\_certificates\_consumers](#input\_lego\_certificates\_consumers) | List of models that consume the Lego certificates offer | `list(string)` | n/a | yes |
| <a name="input_model_uuid"></a> [model\_uuid](#input\_model\_uuid) | Juju model for LEGO | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | LEGO password | `string` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | LEGO username | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lego_certificates_offer_url"></a> [lego\_certificates\_offer\_url](#output\_lego\_certificates\_offer\_url) | n/a |
<!-- END_TF_DOCS -->
