resource "juju_secret" "lego_credentials" {
  model = var.juju_model_name
  name  = "lego-credentials"
  value = {
    httpreq-endpoint            = "https://lego-certs.canonical.com"
    httpreq-username            = data.vault_generic_secret.lego_credentials.data["username"]
    httpreq-password            = data.vault_generic_secret.lego_credentials.data["password"]
    httpreq-propagation-timeout = 600
  }
}

module "lego" {
  source   = "git::https://github.com/canonical/lego-operator//terraform/product?ref=rev191&depth=1"
  model    = var.juju_model
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
  model = var.juju_model_name
  applications = [
    juju_application.lego.name
  ]
  secret_id = juju_secret.lego_credentials.secret_id
}
