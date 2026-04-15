module "ingress_configurator" {
  source     = "git::https://github.com/canonical/ingress-configurator-operator//terraform?ref=rev72&depth=1"
  app_name   = "ingress-configurator"
  model_uuid = var.model_uuid
  channel    = "latest/edge"
  revision   = 72
  config     = { hostname = var.external_hostname }
}

module "falcosidekick" {
  source = "git::https://github.com/canonical/falco-operators//falcosidekick-k8s-operator/terraform?ref=rev66&depth=1"

  model_uuid = var.model_uuid
  channel    = "2/edge"
  revision   = 56
}

resource "juju_integration" "falcosidekick_ingress" {
  provider   = juju
  model_uuid = var.model_uuid

  application {
    name     = module.falcosidekick.app_name
    endpoint = module.falcosidekick.requires.ingress
  }

  application {
    name     = module.ingress_configurator.app_name
    endpoint = module.ingress_configurator.endpoints.ingress
  }
}

resource "juju_integration" "falcosidekick_send_loki_logs" {
  provider   = juju
  model_uuid = var.model_uuid

  application {
    name     = module.falcosidekick.app_name
    endpoint = module.falcosidekick.requires.send_loki_logs
  }

  application {
    offer_url = var.send_loki_logs_offer_url
  }
}

resource "juju_integration" "falcosidekick_loki" {
  provider   = juju
  model_uuid = var.model_uuid

  application {
    name     = module.falcosidekick.app_name
    endpoint = module.falcosidekick.requires.logging
  }

  application {
    offer_url = var.loki_offer_url
  }
}

resource "juju_offer" "falcosidekick_http_endpoint" {
  model_uuid = var.model_uuid

  name             = "falcosidekick-http-endpoint"
  application_name = module.falcosidekick.app_name
  endpoints        = [module.falcosidekick.provides.http_endpoint]
}

resource "juju_access_offer" "falcosidekick_http_endpoint" {
  admin     = [var.model_name]
  offer_url = juju_offer.falcosidekick_http_endpoint.url
  consume   = var.falcosidekick_http_endpoint_consumers
}

