# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.

# Layer 2 (deployment module) for the 12-factor Indico charm on PS7.
#
# It inherits the indico-operator product module (Layer 1) and pins the
# revisions/channels of every charm. Unlike the Mattermost module, this module
# ALSO owns the ingress: it deploys `ingress-configurator` and wires it to both
# the Indico `ingress` relation and the shared PS7 HAProxy offer. All
# deployment-specific values (hostname, HAProxy offer URL, header rewrites,
# secrets, DBaaS offer) are provided by the consuming Layer 3 deployment as
# inputs.
module "indico" {
  # NOTE: switch ref to `main` once the Layer 1 branch is merged.
  # TRIAL: local source (branch not pushed). Revert to the git ref below.
  source = "../../../../../indico-operator/terraform/product"
  # source = "git::https://github.com/canonical/indico-operator//terraform/product?ref=feat/indico-ps7-staging-12f&depth=1"

  # The Juju model is provisioned externally (platform-team environment
  # request); this module only deploys applications into it.
  create_model = false
  model_uuid   = var.model_uuid

  app_names = {
    indico = var.indico_app_name
  }

  channels = {
    indico                        = var.indico_channel
    redis                         = "latest/edge"
    s3_integrator_media           = "latest/edge"
    smtp_integrator               = "latest/edge"
    oauth_external_idp_integrator = "latest/edge"
    local_postgresql              = "14/stable"
  }

  revisions = {
    # renovate: depName="indico"
    indico = var.indico_revision
    # renovate: depName="redis-k8s"
    redis = 36
    # renovate: depName="s3-integrator"
    s3_integrator_media = 18
    # renovate: depName="smtp-integrator"
    smtp_integrator = 10
    # renovate: depName="oauth-external-idp-integrator"
    oauth_external_idp_integrator = 6
    # renovate: depName="postgresql-k8s"
    local_postgresql = 774
  }

  # Feature toggles. OIDC (oauth) replaces the SAML flow used by the legacy
  # PS6 staging deployment; nginx-ingress/lego are unused because ingress is
  # handled by ingress-configurator below.
  enable = {
    redis                         = true
    s3_integrator_media           = true
    smtp_integrator               = true
    oauth_external_idp_integrator = true
    # Bundled postgresql-k8s when not using an external DBaaS offer.
    local_postgresql         = var.deploy_postgresql
    nginx_ingress_integrator = false
    lego                     = false
    local_saml_integrator    = false
  }

  # Database: bundled postgresql-k8s (deploy_postgresql = true) OR an external
  # managed PostgreSQL consumed through a cross-model offer (deploy_postgresql
  # = false + postgresql_offer_url).
  integrate_offers = {
    postgresql      = !var.deploy_postgresql
    prometheus      = var.prometheus_offer_url != ""
    grafana         = var.grafana_offer_url != ""
    saml_integrator = false
  }

  offer_urls = merge(
    var.deploy_postgresql ? {} : { postgresql = var.postgresql_offer_url },
    var.prometheus_offer_url != "" ? { prometheus = var.prometheus_offer_url } : {},
    var.grafana_offer_url != "" ? { grafana = var.grafana_offer_url } : {},
  )

  credentials = {
    s3_access_key         = var.s3_access_key
    s3_secret_key         = var.s3_secret_key
    lego_httpreq_username = ""
    lego_httpreq_password = ""
  }

  config_indico                        = var.indico_config
  config_s3_integrator_media           = var.s3_config
  config_smtp_integrator               = var.smtp_config
  config_oauth_external_idp_integrator = var.oauth_config
  config_local_postgresql              = var.postgresql_config

  constraints = {
    indico = var.indico_constraints
  }

  units = {
    indico = var.indico_units
  }
}

# --- Ingress (owned by Layer 2) ---------------------------------------------
# HAProxy (shared PS7 offer) terminates TLS and forwards to ingress-configurator
# which forwards to the Indico pod. Deployment-specific values come from L3.
resource "juju_application" "ingress_configurator" {
  name       = var.ingress_configurator_app_name
  model_uuid = var.model_uuid

  charm {
    name     = "ingress-configurator"
    channel  = var.ingress_configurator_channel
    revision = var.ingress_configurator_revision
    base     = "ubuntu@24.04"
  }

  config = merge(
    { hostname = var.external_hostname },
    var.ingress_configurator_config,
  )
  trust = true
  units = 1
}

resource "juju_integration" "indico_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = module.indico.applications.indico.app_name
    endpoint = module.indico.applications.indico.endpoints.ingress
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
