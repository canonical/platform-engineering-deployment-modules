module "falco" {
  source = "git::https://github.com/canonical/falco-operators//falco-operator/terraform?ref=rev63&depth=1"

  model_uuid = var.model_uuid
  channel    = "0.42/edge"
  revision   = 62
}

resource "juju_integration" "falco_falcosidekick_http_endpoint" {
  provider   = juju
  model_uuid = var.model_uuid

  application {
    name     = module.falco.app_name
    endpoint = module.falco.requires.http_endpoint
  }

  application {
    offer_url = var.falcosidekick_http_endpoint_offer_url
  }
}
