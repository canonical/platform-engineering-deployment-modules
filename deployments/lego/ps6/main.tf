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
    juju_application.lego.name
  ]
  secret_id = juju_secret.lego_credentials.secret_id
}
