# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.

# This module inherits the mattermost-k8s-operator product module, pins the
# revisions/channels of every charm, and deploys the ingress-configurator
# fronted by HAProxy. It is intentionally opinionated: shared/PS7 defaults live
# here, and only environment- and model-specific values are taken as inputs.
locals {
  # S3: the bucket is environment-specific; the RadosGW endpoint and region are
  # PS7 constants set here so consumers only need to pass the bucket.
  s3_config = merge({
    endpoint = "https://radosgw.ps7.canonical.com"
    region   = "prodstack7"
  }, var.s3_config)

  # SMTP: the relay host, port, auth type, transport security and sender are
  # shared Canonical defaults; only the AUTH user (and password) are
  # environment-specific.
  smtp_config = merge({
    host               = "mattermost.smtp.canonical.com"
    port               = "25"
    auth_type          = "plain"
    transport_security = "starttls"
    smtp_sender        = "noreply+chat@canonical.com"
  }, var.smtp_config)

  # OAuth: the requested scope is an opinionated default; client credentials and
  # IdP endpoints are environment-specific.
  oauth_config = merge({
    scope = "openid profile email"
  }, var.oauth_config)
}

module "mattermost" {
  source     = "git::https://github.com/canonical/mattermost-k8s-operator//terraform/product?ref=rev50&depth=1"
  model_uuid = var.model_uuid

  deploy_postgresql = var.deploy_postgresql
  deploy_ingress    = false

  mattermost = {
    channel = "latest/edge"
    # renovate: charm="mattermost-k8s" track="latest" risk="edge" base="24.04" arch="amd64"
    revision = 49
    config   = var.mattermost_config
    units    = var.mattermost_units
  }

  postgresql = {
    channel = "14/stable"
    # renovate: charm="postgresql-k8s" track="14" risk="stable" base="22.04" arch="amd64"
    revision = 774
    config   = var.postgresql_config
    units    = var.postgresql_units
  }

  s3_integrator = {
    channel = "1/stable"
    # renovate: charm="s3-integrator" track="1" risk="stable" base="22.04" arch="amd64"
    revision   = 330
    config     = local.s3_config
    access_key = var.s3_access_key
    secret_key = var.s3_secret_key
  }

  smtp_integrator = {
    channel = "latest/stable"
    # renovate: charm="smtp-integrator" track="latest" risk="stable" base="22.04" arch="amd64"
    revision = 121
    config   = local.smtp_config
  }

  smtp_password = var.smtp_password

  self_signed_certificates = {
    channel = "latest/stable"
    # renovate: charm="self-signed-certificates" track="latest" risk="stable" base="22.04" arch="amd64"
    revision = 518
  }

  oauth = {
    channel = "latest/edge"
    # renovate: charm="oauth-external-idp-integrator" track="latest" risk="edge" base="22.04" arch="amd64"
    revision = 6
    base     = "ubuntu@22.04"
    config   = local.oauth_config
  }
}

# Ingress: the ingress-configurator charm (pinned here) fronted by the HAProxy
# offer. Only the external hostname and the HAProxy offer URL are environment-
# specific; the charm revision and the X-Forwarded-Proto rewrite are opinionated.
resource "juju_application" "ingress_configurator" {
  name       = "ingress-configurator"
  model_uuid = var.model_uuid

  charm {
    name    = "ingress-configurator"
    channel = "latest/edge"
    # renovate: charm="ingress-configurator" track="latest" risk="edge" base="24.04" arch="amd64"
    revision = 105
    base     = "ubuntu@24.04"
  }

  config = {
    hostname = var.external_hostname

    # HAProxy terminates TLS and forwards plain HTTP to the workload without any
    # X-Forwarded-* headers. Mattermost derives the OAuth token-exchange
    # redirect_uri from the request scheme (GetProtocol(r) -> X-Forwarded-Proto),
    # so without this it sends http:// while the authorize step uses the https://
    # SiteURL, causing the IdP to reject the exchange with redirect_uri mismatch.
    # Inject the scheme so both redirect_uris match.
    "header-rewrite-expressions" = "X-Forwarded-Proto:https"
  }
  trust = true
  units = 1
}

resource "juju_integration" "mattermost_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = module.mattermost.mattermost.app_name
    endpoint = module.mattermost.mattermost.requires.ingress
  }

  application {
    name     = juju_application.ingress_configurator.name
    endpoint = "ingress"
  }
}

resource "juju_integration" "haproxy_ingress_configurator" {
  model_uuid = var.model_uuid

  application {
    offer_url = var.haproxy_offer_url
  }

  application {
    name     = juju_application.ingress_configurator.name
    endpoint = "haproxy-route"
  }
}
