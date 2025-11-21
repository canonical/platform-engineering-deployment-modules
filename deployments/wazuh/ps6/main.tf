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
  name = "${var.juju_indexer_model_name}-wazuh-indexer-backup"
  lifecycle {
    prevent_destroy = true
  }
}

module "wazuh" {
  source          = "git::https://github.com/canonical/wazuh-server-operator//terraform/product?ref=rev201&depth=1"
  server_model    = var.juju_server_model_name
  indexer_model   = var.juju_indexer_model_name
  dashboard_model = var.juju_dashboard_model_name

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
    revision = 212
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
      external_hostname = "wazuh-dev-ps6.platform-engineering.staging.canonical.com"
    }
  }

  self_signed_certificates = {
    app_name = "self-signed-certificates"
    channel  = "latest/stable"
    revision = 264
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
  model = var.juju_server_model_name
  name  = "lego-credentials"
  value = {
    httpreq-endpoint            = "https://lego-certs.canonical.com"
    httpreq-username            = data.vault_generic_secret.lego_credentials.data["username"]
    httpreq-password            = data.vault_generic_secret.lego_credentials.data["password"]
    httpreq-propagation-timeout = 600
  }
}

resource "juju_application" "lego" {
  name  = "lego"
  model = var.juju_server_model_name

  charm {
    name     = "lego"
    channel  = "4/stable"
    revision = 61
  }

  config = {
    "email" : "is-admin@canonical.com",
    "plugin" : "httpreq",
    "plugin-config-secret-id" : juju_secret.lego_credentials.secret_id
  }
  units = 1
}

resource "juju_access_secret" "lego_credentials_access" {
  model = var.juju_server_model_name
  applications = [
    juju_application.lego.name
  ]
  secret_id = juju_secret.lego_credentials.secret_id
}

resource "juju_integration" "wazuh_server_certificates" {
  provider = juju
  model    = var.juju_server_model_name

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
  provider = juju
  model    = var.juju_server_model_name

  application {
    name     = module.wazuh.wazuh_server_name
    endpoint = module.wazuh.wazuh_server_provides.grafana_dashboard
  }

  application {
    offer_url = var.grafana_offer_url
  }
}

resource "juju_integration" "wazuh_server_loki" {
  provider = juju
  model    = var.juju_server_model_name

  application {
    name     = module.wazuh.wazuh_server_name
    endpoint = module.wazuh.wazuh_server_requires.logging
  }

  application {
    offer_url = var.loki_offer_url
  }
}

resource "juju_integration" "wazuh_server_prometheus" {
  provider = juju
  model    = var.juju_server_model_name

  application {
    name     = module.wazuh.wazuh_server_name
    endpoint = module.wazuh.wazuh_server_provides.metrics_endpoint
  }

  application {
    offer_url = var.prometheus_metrics_endpoint_offer_url
  }
}

resource "juju_integration" "traefik_dashboard" {
  provider = juju
  model    = var.juju_server_model_name

  application {
    name     = module.wazuh.traefik_name
    endpoint = module.wazuh.traefik_provides.grafana_dashboard
  }

  application {
    offer_url = var.grafana_offer_url
  }
}

resource "juju_integration" "traefik_loki" {
  provider = juju
  model    = var.juju_server_model_name

  application {
    name     = module.wazuh.traefik_name
    endpoint = module.wazuh.traefik_requires.logging
  }

  application {
    offer_url = var.loki_offer_url
  }
}

resource "juju_integration" "traefik_prometheus" {
  provider = juju
  model    = var.juju_server_model_name

  application {
    name     = module.wazuh.traefik_name
    endpoint = module.wazuh.traefik_provides.metrics_endpoint
  }

  application {
    offer_url = var.prometheus_metrics_endpoint_offer_url
  }
}

resource "juju_integration" "wazuh_opencti" {
  provider = juju
  model    = var.juju_server_model_name

  application {
    name     = module.wazuh.wazuh_server_name
    endpoint = module.wazuh.wazuh_server_provides.opencti_connector
  }

  application {
    offer_url = var.opencti_offer_url
  }
}

resource "juju_integration" "grafana_agent_dashboard_grafana" {
  provider = juju.wazuh_dashboard
  model    = var.juju_dashboard_model_name

  application {
    name     = module.wazuh.wazuh_dashboard_grafana_agent_name
    endpoint = module.wazuh.wazuh_dashboard_grafana_agent_provides.grafana_dashboards_provider
  }

  application {
    offer_url = var.grafana_offer_url
  }
}

resource "juju_integration" "grafana_agent_dashboard_loki" {
  provider = juju.wazuh_dashboard
  model    = var.juju_dashboard_model_name

  application {
    name     = module.wazuh.wazuh_dashboard_grafana_agent_name
    endpoint = module.wazuh.wazuh_dashboard_grafana_agent_requires.logging_consumer
  }

  application {
    offer_url = var.loki_offer_url
  }
}

resource "juju_integration" "grafana_agent_dashboard_prometheus" {
  provider = juju.wazuh_dashboard
  model    = var.juju_dashboard_model_name

  application {
    name     = module.wazuh.wazuh_dashboard_grafana_agent_name
    endpoint = module.wazuh.wazuh_dashboard_grafana_agent_requires.send_remote_write
  }

  application {
    offer_url = var.prometheus_remote_write_offer_url
  }
}

resource "juju_integration" "grafana_agent_indexer_grafana" {
  provider = juju.wazuh_indexer
  model    = var.juju_indexer_model_name

  application {
    name     = module.wazuh.wazuh_indexer_grafana_agent_name
    endpoint = module.wazuh.wazuh_indexer_grafana_agent_provides.grafana_dashboards_provider
  }

  application {
    offer_url = var.grafana_offer_url
  }
}

resource "juju_integration" "grafana_agent_indexer_loki" {
  provider = juju.wazuh_indexer
  model    = var.juju_indexer_model_name

  application {
    name     = module.wazuh.wazuh_indexer_grafana_agent_name
    endpoint = module.wazuh.wazuh_indexer_grafana_agent_requires.logging_consumer
  }

  application {
    offer_url = var.loki_offer_url
  }
}

resource "juju_integration" "grafana_agent_indexer_prometheus" {
  provider = juju.wazuh_indexer
  model    = var.juju_indexer_model_name

  application {
    name     = module.wazuh.wazuh_indexer_grafana_agent_name
    endpoint = module.wazuh.wazuh_indexer_grafana_agent_requires.send_remote_write
  }

  application {
    offer_url = var.prometheus_remote_write_offer_url
  }
}

resource "juju_secret" "git_ssh_key" {
  model = var.juju_server_model_name
  name  = "git_ssh_key"
  value = {
    value = data.vault_generic_secret.git_ssh_key.data["private_key"]
  }
  info = "Private key for the repository"
}

resource "juju_access_secret" "git_ssh_key_access" {
  model = var.juju_server_model_name
  applications = [
    module.wazuh.wazuh_server_name
  ]
  secret_id = resource.juju_secret.git_ssh_key.secret_id
}

resource "juju_application" "landscape_client" {
  name  = "landscape-client"
  model = var.juju_indexer_model_name

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
  name  = "landscape-client"
  model = var.juju_dashboard_model_name

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
  for_each = local.machine_indexer_charms
  model    = var.juju_indexer_model_name

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
  for_each = local.machine_dashboard_charms
  model    = var.juju_dashboard_model_name

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
  name  = "ubuntu-pro"
  model = var.juju_indexer_model_name

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
  name  = "ubuntu-pro"
  model = var.juju_dashboard_model_name

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
  for_each = local.machine_indexer_charms
  model    = var.juju_indexer_model_name

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
  for_each = local.machine_dashboard_charms
  model    = var.juju_dashboard_model_name

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
