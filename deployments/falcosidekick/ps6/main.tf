module "falcosidekick" {
  source = "git::https://github.com/canonical/falco-operators//falcosidekick-k8s-operator/terraform?ref=rev62&depth=1"

  model_uuid = var.model_uuid
  channel    = "2/edge"
  revision   = 37
}

resource "juju_application" "gateway_api_integrator" {
  name       = "gateway-api"
  model_uuid = var.model_uuid

  charm {
    name     = "gateway-api-integrator"
    revision = 127
    channel  = "latest/stable"
  }

  config = {
    gateway-class = "cilium"
  }

  trust = true
}

resource "juju_application" "gateway_route_configurator" {
  name       = "gateway-route-configurator"
  model_uuid = var.model_uuid

  charm {
    name     = "gateway-route-configurator"
    revision = 8
    channel  = "latest/edge"
  }

  config = {
    hostname = var.external_hostname
  }
}

resource "juju_integration" "gateway_api_route" {
  model_uuid = var.model_uuid

  application {
    name     = juju_application.gateway_route_configurator.name
    endpoint = "gateway-route"
  }

  application {
    name     = juju_application.gateway_api_integrator.name
    endpoint = "gateway-route"
  }
}

resource "juju_integration" "ingress" {
  model_uuid = var.model_uuid

  application {
    name     = module.falcosidekick.app_name
    endpoint = module.falcosidekick.requires.ingress
  }

  application {
    name     = juju_application.gateway_route_configurator.name
    endpoint = "ingress"
  }
}

resource "juju_integration" "certificates" {
  provider   = juju
  model_uuid = var.model_uuid

  application {
    name     = juju_application.gateway_api_integrator.name
    endpoint = "certificates"
  }

  application {
    offer_url = var.certificates_offer_url
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

