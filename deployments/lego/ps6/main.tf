resource "juju_secret" "lego_credentials" {
  model_uuid = var.model_uuid
  name       = "lego-credentials"
  value = {
    httpreq-endpoint            = "https://lego-certs.canonical.com"
    httpreq-username            = var.username
    httpreq-password            = var.password
    httpreq-propagation-timeout = 600
  }
}

module "lego" {
  source   = "git::https://github.com/canonical/lego-operator//terraform?ref=rev197&depth=1"
  model    = var.model_uuid
  app_name = "lego"
  channel  = "4/candidate"
  revision = 128
  config = {
    "email" : "is-admin@canonical.com",
    "plugin" : "httpreq",
    "plugin-config-secret-id" : juju_secret.lego_credentials.secret_id
  }
}

resource "juju_access_secret" "lego_credentials_access" {
  model_uuid = var.model_uuid
  applications = [
    module.lego.app_name
  ]
  secret_id = juju_secret.lego_credentials.secret_id
}

resource "juju_offer" "lego_certificates" {
  model_uuid = var.model_uuid

  name             = "lego-certificates"
  application_name = module.lego.app_name
  endpoints        = [module.lego.provides.certificates]
}

resource "juju_access_offer" "lego_certificates" {
  admin     = [var.model_name]
  offer_url = juju_offer.lego_certificates.url
  consume   = var.lego_certificates_consumers
}

