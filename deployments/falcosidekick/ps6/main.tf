module "falcosidekick" {
  source = "git::https://github.com/canonical/falco-operators//falcosidekick-k8s-operator/terraform-product?ref=rev62&depth=1"

  model_uuid = var.model_uuid

  falcosidekick = {
    channel  = "2/edge"
    revision = 37
  }

  traefik_k8s = {
    channel  = "latest/stable"
    revision = 236
    config = {
      external_hostname = var.external_hostname
    }
  }
}

resource "juju_integration" "falcosidekick_send_loki_logs" {
  provider   = juju
  model_uuid = var.model_uuid

  application {
    name     = module.falcosidekick.falcosidekick_name
    endpoint = module.falcosidekick.falcosidekick_requires.send_loki_logs
  }

  application {
    offer_url = var.send_loki_logs_offer_url
  }
}


resource "juju_integration" "falcosidekick_loki" {
  provider   = juju
  model_uuid = var.model_uuid

  application {
    name     = module.falcosidekick.falcosidekick_name
    endpoint = module.falcosidekick.falcosidekick_requires.logging
  }

  application {
    offer_url = var.loki_offer_url
  }
}

resource "juju_integration" "traefik_dashboard" {
  provider   = juju
  model_uuid = var.model_uuid

  application {
    name     = module.falcosidekick.traefik_name
    endpoint = module.falcosidekick.traefik_provides.grafana_dashboard
  }

  application {
    offer_url = var.grafana_offer_url
  }
}

resource "juju_integration" "traefik_loki" {
  provider   = juju
  model_uuid = var.model_uuid

  application {
    name     = module.falcosidekick.traefik_name
    endpoint = module.falcosidekick.traefik_requires.logging
  }

  application {
    offer_url = var.loki_offer_url
  }
}

resource "juju_integration" "traefik_prometheus" {
  provider   = juju
  model_uuid = var.model_uuid

  application {
    name     = module.falcosidekick.traefik_name
    endpoint = module.falcosidekick.traefik_provides.metrics_endpoint
  }

  application {
    offer_url = var.prometheus_metrics_endpoint_offer_url
  }
}

resource "juju_integration" "traefik_certificates" {
  provider   = juju
  model_uuid = var.model_uuid

  application {
    name     = module.falcosidekick.traefik_name
    endpoint = module.falcosidekick.traefik_requires.certificates
  }

  application {
    offer_url = var.certificates_offer_url
  }
}

resource "juju_offer" "falcosidekick_http_endpoint" {
  model_uuid = var.model_uuid

  name             = "falcosidekick-http-endpoint"
  application_name = module.falcosidekick.falcosidekick_name
  endpoints        = [module.falcosidekick.falcosidekick_provides.http_endpoint]
}

resource "juju_access_offer" "falcosidekick_http_endpoint" {
  admin     = [var.model_name]
  offer_url = juju_offer.falcosidekick_http_endpoint.url
  consume   = var.falcosidekick_http_endpoint_consumers
}

