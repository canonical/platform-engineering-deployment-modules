locals {
  machine_dashboard_charms = toset([
    "wazuh-dashboard-v5"
  ])
  machine_indexer_charms = toset([
    "data-integrator",
    "wazuh-indexer-v5",
    "wazuh-indexer-v5-backup",
    "self-signed-certificates"
  ])
}
resource "openstack_identity_ec2_credential_v3" "wazuh_indexer_s3_creds" {}

resource "openstack_objectstorage_container_v1" "wazuh_indexer_backup" {
  name = "${var.indexer_model_name}-wazuh-indexer-backup"
  lifecycle {
    prevent_destroy = true
  }
}

module "wazuh" {
  source               = "git::https://github.com/canonical/wazuh-server-operator//terraform/product?ref=rev210&depth=1"
  server_model_name    = var.server_model_name
  server_model_uuid    = var.server_model_uuid
  indexer_model_name   = var.indexer_model_name
  indexer_model_uuid   = var.indexer_model_uuid
  dashboard_model_name = var.dashboard_model_name
  dashboard_model_uuid = var.dashboard_model_uuid

  wazuh_indexer = {
    app_name    = "wazuh-indexer-v5"
    channel     = "4.11/edge"
    revision    = 9
    config      = var.wazuh_indexer_config
    constraints = var.wazuh_indexer_constraints
  }

  sysconfig = {
    channel  = "latest/stable"
    revision = 33
  }

  wazuh_dashboard = {
    app_name    = "wazuh-dashboard-v5"
    channel     = "4.11/edge"
    revision    = 19
    constraints = var.wazuh_dashboard_constraints
  }

  wazuh_server = {
    app_name = "wazuh-server"
    channel  = "4.11/edge"
    revision = 217
    config = {
      logs-ca-cert             = var.logs_ca_certificate
      custom-config-ssh-key    = "secret:${juju_secret.git_ssh_key.secret_id}"
      custom-config-repository = var.wazuh_custom_config_repository

    }
  }

  traefik_k8s = {
    channel  = "latest/stable"
    revision = 236
    config = {
      external_hostname = var.wazuh_external_hostname
    }
  }

  self_signed_certificates = {
    app_name = "self-signed-certificates"
    channel  = "1/edge"
    revision = 518
    base     = "ubuntu@22.04"

    config = {
      ca-common-name   = "Wazuh dev CA"
      root-ca-validity = 3650
    }
  }

  wazuh_indexer_backup = {
    channel  = "latest/stable"
    revision = 145
    config = {
      bucket         = openstack_objectstorage_container_v1.wazuh_indexer_backup.name
      endpoint       = data.vault_generic_secret.s3.data["endpoint_url"]
      path           = "/opensearch"
      region         = openstack_objectstorage_container_v1.wazuh_indexer_backup.region
      s3-api-version = ""
      s3-uri-style   = "path"
    }
  }

  wazuh_indexer_grafana_agent = {
    channel  = "1/stable"
    revision = 456
  }

  wazuh_dashboard_grafana_agent = {
    channel  = "1/stable"
    revision = 456
  }

  providers = {
    juju                 = juju
    juju.wazuh_indexer   = juju.wazuh_indexer
    juju.wazuh_dashboard = juju.wazuh_dashboard
  }
}

resource "juju_secret" "lego_credentials" {
  model_uuid = var.server_model_uuid
  name       = "lego-credentials"
  value = {
    httpreq-endpoint            = "https://lego-certs.canonical.com"
    httpreq-username            = data.vault_generic_secret.lego_credentials.data["username"]
    httpreq-password            = data.vault_generic_secret.lego_credentials.data["password"]
    httpreq-propagation-timeout = 600
  }
}

resource "juju_application" "lego" {
  name       = "lego"
  model_uuid = var.server_model_uuid

  charm {
    name     = "lego"
    channel  = "4/candidate"
    revision = 128
  }

  config = {
    "email" : "is-admin@canonical.com",
    "plugin" : "httpreq",
    "plugin-config-secret-id" : juju_secret.lego_credentials.secret_id
  }
  units = 1
}

resource "juju_access_secret" "lego_credentials_access" {
  model_uuid = var.server_model_uuid
  applications = [
    juju_application.lego.name
  ]
  secret_id = juju_secret.lego_credentials.secret_id
}

resource "juju_offer" "lego" {
  model_uuid = var.server_model_uuid

  name             = "lego"
  application_name = juju_application.lego.name
  endpoints        = ["certificates"]
}

resource "juju_access_offer" "lego" {
  offer_url = juju_offer.lego.url
  admin     = [var.server_model_name]
  consume   = [var.dashboard_model_name]
}

resource "juju_integration" "wazuh_server_certificates" {
  provider   = juju
  model_uuid = var.server_model_uuid

  application {
    name     = module.wazuh.wazuh_server_name
    endpoint = module.wazuh.wazuh_server_requires.certificates
  }

  application {
    name     = juju_application.lego.name
    endpoint = "certificates"
  }
}

resource "juju_integration" "wazuh_server_dashboard" {
  provider   = juju
  model_uuid = var.server_model_uuid

  application {
    name     = module.wazuh.wazuh_server_name
    endpoint = module.wazuh.wazuh_server_provides.grafana_dashboard
  }

  application {
    offer_url = var.grafana_offer_url
  }
}

resource "juju_integration" "wazuh_server_loki" {
  provider   = juju
  model_uuid = var.server_model_uuid

  application {
    name     = module.wazuh.wazuh_server_name
    endpoint = module.wazuh.wazuh_server_requires.logging
  }

  application {
    offer_url = var.loki_offer_url
  }
}

resource "juju_integration" "wazuh_server_prometheus" {
  provider   = juju
  model_uuid = var.server_model_uuid

  application {
    name     = module.wazuh.wazuh_server_name
    endpoint = module.wazuh.wazuh_server_provides.metrics_endpoint
  }

  application {
    offer_url = var.prometheus_metrics_endpoint_offer_url
  }
}

resource "juju_integration" "traefik_dashboard" {
  provider   = juju
  model_uuid = var.server_model_uuid

  application {
    name     = module.wazuh.traefik_name
    endpoint = module.wazuh.traefik_provides.grafana_dashboard
  }

  application {
    offer_url = var.grafana_offer_url
  }
}

resource "juju_integration" "traefik_loki" {
  provider   = juju
  model_uuid = var.server_model_uuid

  application {
    name     = module.wazuh.traefik_name
    endpoint = module.wazuh.traefik_requires.logging
  }

  application {
    offer_url = var.loki_offer_url
  }
}

resource "juju_integration" "traefik_prometheus" {
  provider   = juju
  model_uuid = var.server_model_uuid

  application {
    name     = module.wazuh.traefik_name
    endpoint = module.wazuh.traefik_provides.metrics_endpoint
  }

  application {
    offer_url = var.prometheus_metrics_endpoint_offer_url
  }
}

resource "juju_integration" "wazuh_opencti" {
  provider   = juju
  model_uuid = var.server_model_uuid

  application {
    name     = module.wazuh.wazuh_server_name
    endpoint = module.wazuh.wazuh_server_provides.opencti_connector
  }

  application {
    offer_url = var.opencti_offer_url
  }
}

resource "juju_integration" "grafana_agent_dashboard_grafana" {
  provider   = juju.wazuh_dashboard
  model_uuid = var.dashboard_model_uuid

  application {
    name     = module.wazuh.wazuh_dashboard_grafana_agent_name
    endpoint = module.wazuh.wazuh_dashboard_grafana_agent_provides.grafana_dashboards_provider
  }

  application {
    offer_url = var.grafana_offer_url
  }
}

resource "juju_integration" "grafana_agent_dashboard_loki" {
  provider   = juju.wazuh_dashboard
  model_uuid = var.dashboard_model_uuid

  application {
    name     = module.wazuh.wazuh_dashboard_grafana_agent_name
    endpoint = module.wazuh.wazuh_dashboard_grafana_agent_requires.logging_consumer
  }

  application {
    offer_url = var.loki_offer_url
  }
}

resource "juju_integration" "grafana_agent_dashboard_prometheus" {
  provider   = juju.wazuh_dashboard
  model_uuid = var.dashboard_model_uuid

  application {
    name     = module.wazuh.wazuh_dashboard_grafana_agent_name
    endpoint = module.wazuh.wazuh_dashboard_grafana_agent_requires.send_remote_write
  }

  application {
    offer_url = var.prometheus_remote_write_offer_url
  }
}

resource "juju_integration" "grafana_agent_indexer_grafana" {
  provider   = juju.wazuh_indexer
  model_uuid = var.indexer_model_uuid

  application {
    name     = module.wazuh.wazuh_indexer_grafana_agent_name
    endpoint = module.wazuh.wazuh_indexer_grafana_agent_provides.grafana_dashboards_provider
  }

  application {
    offer_url = var.grafana_offer_url
  }
}

resource "juju_integration" "grafana_agent_indexer_loki" {
  provider   = juju.wazuh_indexer
  model_uuid = var.indexer_model_uuid

  application {
    name     = module.wazuh.wazuh_indexer_grafana_agent_name
    endpoint = module.wazuh.wazuh_indexer_grafana_agent_requires.logging_consumer
  }

  application {
    offer_url = var.loki_offer_url
  }
}

resource "juju_integration" "grafana_agent_indexer_prometheus" {
  provider   = juju.wazuh_indexer
  model_uuid = var.indexer_model_uuid

  application {
    name     = module.wazuh.wazuh_indexer_grafana_agent_name
    endpoint = module.wazuh.wazuh_indexer_grafana_agent_requires.send_remote_write
  }

  application {
    offer_url = var.prometheus_remote_write_offer_url
  }
}

resource "juju_secret" "git_ssh_key" {
  model_uuid = var.server_model_uuid
  name       = "git_ssh_key"
  value = {
    value = data.vault_generic_secret.git_ssh_key.data["private_key"]
  }
  info = "Private key for the repository"
}

resource "juju_access_secret" "git_ssh_key_access" {
  model_uuid = var.server_model_uuid
  applications = [
    module.wazuh.wazuh_server_name
  ]
  secret_id = resource.juju_secret.git_ssh_key.secret_id
}

resource "juju_application" "landscape_client" {
  name       = "landscape-client"
  model_uuid = var.indexer_model_uuid

  charm {
    name     = "landscape-client"
    revision = 72
    channel  = "latest/stable"
    base     = "ubuntu@24.04"
  }

  config = {
    registration-key = data.vault_generic_secret.landscape_registration_key.data["key"]
    url              = "https://landscape.is.canonical.com/message-system"
    ping-url         = "http://landscape.is.canonical.com/ping"
    account-name     = "standalone"
  }

  provider = juju.wazuh_indexer
}

resource "juju_application" "landscape_client_dashboard" {
  name       = "landscape-client"
  model_uuid = var.dashboard_model_uuid

  charm {
    name     = "landscape-client"
    revision = 72
    channel  = "latest/stable"
    base     = "ubuntu@24.04"
  }

  config = {
    registration-key = data.vault_generic_secret.landscape_registration_key.data["key"]
    url              = "https://landscape.is.canonical.com/message-system"
    ping-url         = "http://landscape.is.canonical.com/ping"
    account-name     = "standalone"
  }

  provider = juju.wazuh_dashboard
}

resource "juju_integration" "landscape_client" {
  for_each   = local.machine_indexer_charms
  model_uuid = var.indexer_model_uuid

  application {
    name     = each.key
    endpoint = "juju-info"
  }
  application {
    name     = juju_application.landscape_client.name
    endpoint = "container"
  }

  provider = juju.wazuh_indexer
}

resource "juju_integration" "landscape_client_dashboard" {
  for_each   = local.machine_dashboard_charms
  model_uuid = var.dashboard_model_uuid

  application {
    name     = each.key
    endpoint = "juju-info"
  }
  application {
    name     = juju_application.landscape_client_dashboard.name
    endpoint = "container"
  }

  provider = juju.wazuh_dashboard
}

resource "juju_application" "ubuntu_pro" {
  name       = "ubuntu-pro"
  model_uuid = var.indexer_model_uuid

  charm {
    name     = "ubuntu-pro"
    revision = 29
    channel  = "latest/stable"
    base     = "ubuntu@22.04"
  }

  config = {
    ppa   = "ppa:ua-client/stable"
    token = data.vault_generic_secret.ubuntu_pro_token.data["token"]
  }

  provider = juju.wazuh_indexer
}

resource "juju_application" "ubuntu_pro_dashboard" {
  name       = "ubuntu-pro"
  model_uuid = var.dashboard_model_uuid

  charm {
    name     = "ubuntu-pro"
    revision = 29
    channel  = "latest/stable"
    base     = "ubuntu@22.04"
  }

  config = {
    ppa   = "ppa:ua-client/stable"
    token = data.vault_generic_secret.ubuntu_pro_token.data["token"]
  }

  provider = juju.wazuh_dashboard
}

resource "juju_integration" "ubuntu_pro" {
  for_each   = local.machine_indexer_charms
  model_uuid = var.indexer_model_uuid

  application {
    name     = each.key
    endpoint = "juju-info"
  }
  application {
    name     = juju_application.ubuntu_pro.name
    endpoint = "juju-info"
  }

  provider = juju.wazuh_indexer
}

resource "juju_integration" "ubuntu_pro_dashboard" {
  for_each   = local.machine_dashboard_charms
  model_uuid = var.dashboard_model_uuid

  application {
    name     = each.key
    endpoint = "juju-info"
  }
  application {
    name     = juju_application.ubuntu_pro_dashboard.name
    endpoint = "juju-info"
  }

  provider = juju.wazuh_dashboard
}
