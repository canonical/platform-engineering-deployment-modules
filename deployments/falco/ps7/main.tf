module "falco" {
  source = "git::https://github.com/canonical/falco-operators//falco-operator/terraform?ref=falco-rev116&depth=1"

  model_uuid = var.model_uuid
  channel    = "0.42/edge"
  # renovate: charm="falco" track="0.42" risk="edge" base="24.04" arch="amd64"
  revision = 116
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
