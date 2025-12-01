locals {
  connector_charms = toset([
    "opencti-abuseipdb-ipblacklist-connector",
    "opencti-alienvault-connector",
    "opencti-cisa-kev-connector",
    "opencti-crowdstrike-connector",
    "opencti-cyber-campaign-connector",
    "opencti-export-file-csv-connector",
    "opencti-export-file-stix-connector",
    "opencti-export-file-txt-connector",
    "opencti-import-document-connector",
    "opencti-import-file-stix-connector",
    "opencti-ipinfo-connector",
    "opencti-malwarebazaar-connector",
    "opencti-misp-feed-connector",
    "opencti-mitre-connector",
    "opencti-sekoia-connector",
    "opencti-urlhaus-connector",
    "opencti-vxvault-connector"
  ])
  machine_charms = toset([
    "data-integrator",
    "opensearch",
    "opensearch-dashboards",
    "rabbitmq-server",
    "s3-integrator",
    "self-signed-certificates"
  ])
}
resource "openstack_identity_ec2_credential_v3" "opencti_s3_creds" {}

resource "openstack_objectstorage_container_v1" "opencti" {
  name = "opencti-bucket"
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_identity_ec2_credential_v3" "opensearch_backup_s3_creds" {}

resource "openstack_objectstorage_container_v1" "opensearch_backup" {
  name = var.juju_db_model_name
  lifecycle {
    prevent_destroy = true
  }
}

module "opencti" {
  source        = "git::https://github.com/canonical/opencti-operator//terraform/product?ref=opencti-rev60&depth=1"
  model         = var.juju_model_name
  db_model      = var.juju_db_model_name
  model_user    = var.juju_model_name
  db_model_user = var.juju_db_model_name

  opencti = {
    channel     = "latest/stable"
    revision    = 54
    base        = "ubuntu@24.04"
    constraints = "arch=amd64"
    units       = 1
    config = {
      admin-user = juju_secret.opencti-admin.secret_id
    }
  }

  opensearch = {
    channel     = "2/edge"
    revision    = 273
    base        = "ubuntu@22.04"
    constraints = var.opensearch_constraints
    config      = var.opensearch_config
  }

  self_signed_certificates = {
    channel  = "latest/stable"
    revision = 264
    base     = "ubuntu@22.04"
    config = {
      ca-common-name   = "CA"
      root-ca-validity = 3650
    }
  }

  rabbitmq_server = {
    channel     = "3.9/stable"
    revision    = 227
    base        = "ubuntu@22.04"
    constraints = var.rabbitmq_constraints
  }

  redis_k8s = {
    channel     = "latest/edge"
    revision    = 39
    base        = "ubuntu@22.04"
    constraints = "arch=amd64"
    storage = {
      database = var.redis_storage
    }
  }

  s3_integrator = {
    channel     = "latest/stable"
    revision    = 62
    base        = "ubuntu@22.04"
    constraints = "arch=amd64"
    config = {
      bucket   = openstack_objectstorage_container_v1.opencti.name
      endpoint = data.vault_generic_secret.s3.data["endpoint_url"]
    }
  }

  s3_integrator_opensearch = {
    channel     = "latest/stable"
    revision    = 62
    base        = "ubuntu@22.04"
    constraints = "arch=amd64 cores=1"
    config = {
      bucket       = openstack_objectstorage_container_v1.opensearch_backup.name
      endpoint     = data.vault_generic_secret.s3_opensearch.data["endpoint_url"]
      region       = openstack_objectstorage_container_v1.opensearch_backup.region
      s3-uri-style = "path"
    }
  }

  sysconfig = {
    channel  = "latest/stable"
    revision = 89
  }

  providers = {
    juju            = juju
    juju.opencti_db = juju.opencti_db
  }
}

resource "juju_access_secret" "opencti-admin-access" {
  model        = var.juju_model_name
  applications = [module.opencti.app_name]
  secret_id    = juju_secret.opencti-admin.secret_id
}

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

resource "juju_application" "lego" {
  name  = "lego"
  model = var.juju_model_name

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
  model = var.juju_model_name
  applications = [
    juju_application.lego.name
  ]
  secret_id = juju_secret.lego_credentials.secret_id
}

resource "juju_application" "gateway-api-integrator" {
  name  = "gateway-api"
  model = var.juju_model_name

  charm {
    name     = "gateway-api-integrator"
    revision = 97
    channel  = "latest/stable"
  }

  config = {
    external-hostname = var.opencti_external_hostname
    gateway-class     = "cilium"
  }

  trust = true
}

resource "juju_application" "grafana-agent" {
  name  = "grafana-agent"
  model = var.juju_db_model_name

  charm {
    name     = "grafana-agent"
    revision = 490
    channel  = "1/stable"
    base     = "ubuntu@22.04"
  }

  provider = juju.opencti_db
}

resource "juju_application" "opencti-abuseipdb-ipblacklist-connector" {
  name  = "opencti-abuseipdb-ipblacklist-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-abuseipdb-ipblacklist-connector"
    channel  = "latest/edge"
    revision = 16
    base     = "ubuntu@24.04"
  }

  config = {
    abuseipdb-api-key   = data.vault_generic_secret.abuseipdb-ipblacklist.data["api-key"]
    abuseipdb-interval  = 10
    abuseipdb-limit     = 10000
    abuseipdb-score     = 80
    connector-scope     = "abuseipdb"
    abuseipdb-url       = "https://api.abuseipdb.com/api/v2/blacklist"
    connector-log-level = "info"
  }
}

resource "juju_application" "opencti-alienvault-connector" {
  name  = "opencti-alienvault-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-alienvault-connector"
    channel  = "latest/edge"
    revision = 12
    base     = "ubuntu@24.04"
  }

  config = {
    alienvault-api-key                        = data.vault_generic_secret.alienvault.data["api-key"]
    alienvault-base-url                       = "https://otx.alienvault.com"
    alienvault-excluded-pulse-indicator-types = "FileHash-MD5,FileHash-SHA1"
    alienvault-guess-cve                      = false
    alienvault-guess-malware                  = false
    alienvault-interval-sec                   = 1800
    alienvault-pulse-start-timestamp          = "2020-05-01T00:00:00"
    alienvault-report-status                  = "New"
    alienvault-tlp                            = "Green"
    connector-duration-period                 = "PT30M"
    connector-scope                           = "alienvault"
    connector-log-level                       = "info"
  }
}

resource "juju_application" "opencti-cisa-kev-connector" {
  name  = "opencti-cisa-kev-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-cisa-kev-connector"
    channel  = "latest/edge"
    revision = 14
    base     = "ubuntu@24.04"
  }

  config = {
    cisa-catalog-url            = "https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json"
    cisa-create-infrastructures = false
    cisa-tlp                    = "TLP:CLEAR"
    connector-duration-period   = "P7D"
    connector-scope             = "cisa"
    connector-log-level         = "info"
  }
}

resource "juju_application" "opencti-crowdstrike-connector" {
  name  = "opencti-crowdstrike-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-crowdstrike-connector"
    channel  = "latest/edge"
    revision = 14
    base     = "ubuntu@24.04"
  }

  config = {
    connector-log-level                       = "info"
    connector-duration-period                 = "PT30M"
    crowdstrike-base-url                      = "https://api.eu-1.crowdstrike.com"
    crowdstrike-client-id                     = data.vault_generic_secret.crowdstrike.data["client-id"]
    crowdstrike-client-secret                 = data.vault_generic_secret.crowdstrike.data["client-secret"]
    crowdstrike-tlp                           = "Amber"
    crowdstrike-create-observables            = true
    crowdstrike-create-indicators             = true
    crowdstrike-scopes                        = "actor,report,indicator,yara_master"
    crowdstrike-actor-start-timestamp         = 0
    crowdstrike-report-start-timestamp        = 0
    crowdstrike-report-status                 = "New"
    crowdstrike-report-include-types          = "notice,tipper,intelligence report,periodic report"
    crowdstrike-report-type                   = "threat-report"
    crowdstrike-report-target-industries      = ""
    crowdstrike-report-guess-malware          = false
    crowdstrike-indicator-start-timestamp     = 0
    crowdstrike-indicator-exclude-types       = "hash_ion,hash_md5,hash_sha1"
    crowdstrike-default-x-opencti-score       = 50
    crowdstrike-indicator-low-score           = 40
    crowdstrike-indicator-low-score-labels    = "MaliciousConfidence/Low"
    crowdstrike-indicator-medium-score        = 60
    crowdstrike-indicator-medium-score-labels = "MaliciousConfidence/Medium"
    crowdstrike-indicator-high-score          = 80
    crowdstrike-indicator-high-score-labels   = "MaliciousConfidence/High"
    crowdstrike-indicator-unwanted-labels     = ""
  }
}

resource "juju_application" "opencti-cyber-campaign-connector" {
  name  = "opencti-cyber-campaign-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-cyber-campaign-connector"
    channel  = "latest/edge"
    revision = 13
    base     = "ubuntu@24.04"
  }

  config = {
    connector-log-level         = "info"
    connector-run-and-terminate = false
    connector-scope             = "report"
    cyber-monitor-from-year     = 2023
    cyber-monitor-interval      = 3
  }
}

resource "juju_application" "opencti-export-file-csv-connector" {
  name  = "opencti-export-file-csv-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-export-file-csv-connector"
    channel  = "latest/edge"
    revision = 13
    base     = "ubuntu@24.04"
  }

  config = {
    connector-scope = "text/csv"
  }
}

resource "juju_application" "opencti-export-file-stix-connector" {
  name  = "opencti-export-file-stix-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-export-file-stix-connector"
    channel  = "latest/edge"
    revision = 12
    base     = "ubuntu@24.04"
  }

  config = {
    connector-scope = "application/vnd.oasis.stix+json"
  }
}

resource "juju_application" "opencti-export-file-txt-connector" {
  name  = "opencti-export-file-txt-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-export-file-txt-connector"
    channel  = "latest/edge"
    revision = 13
    base     = "ubuntu@24.04"
  }

  config = {
    connector-scope = "text/plain"
  }
}

resource "juju_application" "opencti-import-document-connector" {
  name  = "opencti-import-document-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-import-document-connector"
    channel  = "latest/edge"
    revision = 14
    base     = "ubuntu@24.04"
  }

  config = {
    connector-auto                   = false
    connector-confidence-level       = 100
    connector-only-contextual        = false
    connector-scope                  = "application/pdf,text/plain,text/html,text/markdown"
    connector-validate-before-import = true
    import-document-create-indicator = false
  }
}

resource "juju_application" "opencti-import-file-stix-connector" {
  name  = "opencti-import-file-stix-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-import-file-stix-connector"
    channel  = "latest/edge"
    revision = 14
    base     = "ubuntu@24.04"
  }

  config = {
    connector-auto                   = false
    connector-confidence-level       = 15
    connector-scope                  = "application/json,application/xml"
    connector-validate-before-import = true
  }
}

resource "juju_application" "opencti-ipinfo-connector" {
  name  = "opencti-ipinfo-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-ipinfo-connector"
    channel  = "latest/edge"
    revision = 9
    base     = "ubuntu@24.04"
  }

  config = {
    connector-auto             = true
    connector-confidence-level = 75
    connector-scope            = "IPv4-Addr,IPv6-Addr"
    ipinfo-max-tlp             = "TLP:AMBER"
    ipinfo-token               = data.vault_generic_secret.ipinfo.data["token"]
    ipinfo-use-asn-name        = true
    connector-log-level        = "info"
  }
}

resource "juju_application" "opencti-malwarebazaar-connector" {
  name  = "opencti-malwarebazaar-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-malwarebazaar-connector"
    channel  = "latest/edge"
    revision = 12
    base     = "ubuntu@24.04"
  }

  config = {
    connector-log-level                             = "info"
    malwarebazaar-recent-additions-api-url          = "https://mb-api.abuse.ch/api/v1/"
    malwarebazaar-recent-additions-cooldown-seconds = 900
    malwarebazaar-recent-additions-labels-color     = "#54483b"
  }
}

resource "juju_application" "opencti-misp-feed-connector" {
  name  = "opencti-misp-feed-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-misp-feed-connector"
    channel  = "latest/edge"
    revision = 13
    base     = "ubuntu@24.04"
  }

  config = {
    connector-scope     = "misp"
    misp-feed-interval  = 15
    connector-log-level = "info"
    misp-feed-url       = "https://www.circl.lu/doc/misp/feed-osint"
  }
}

resource "juju_application" "opencti-mitre-connector" {
  name  = "opencti-mitre-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-mitre-connector"
    channel  = "latest/edge"
    revision = 13
    base     = "ubuntu@24.04"
  }

  config = {
    connector-scope                = "tool,report,malware,identity,campaign,intrusion-set,attack-pattern,course-of-action,x-mitre-data-source,x-mitre-data-component,x-mitre-matrix,x-mitre-tactic,x-mitre-collection"
    mitre-interval                 = 7
    mitre-remove-statement-marking = true
    connector-log-level            = "info"
  }
}

resource "juju_application" "opencti-sekoia-connector" {
  name  = "opencti-sekoia-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-sekoia-connector"
    channel  = "latest/edge"
    revision = 14
    base     = "ubuntu@24.04"
  }

  config = {
    connector-scope           = "identity,attack-pattern,course-of-action,intrusion-set,malware,tool,report,location,vulnerability,indicator,campaign,infrastructure,relationship"
    sekoia-api-key            = data.vault_generic_secret.sekoia.data["api-key"]
    sekoia-create-observables = true
    connector-log-level       = "info"
    sekoia-base-url           = "https://api.sekoia.io"
  }
}

resource "juju_application" "opencti-urlhaus-connector" {
  name  = "opencti-urlhaus-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-urlhaus-connector"
    channel  = "latest/edge"
    revision = 9
    base     = "ubuntu@24.04"
  }

  config = {
    connector-confidence-level  = 50
    urlhaus-interval            = 10
    connector-log-level         = "info"
    connector-scope             = "urlhaus"
    urlhaus-csv-url             = "https://urlhaus.abuse.ch/downloads/csv_recent/"
    urlhaus-import-offline      = true
    urlhaus-threats-from-labels = true
  }
}

resource "juju_application" "opencti-vxvault-connector" {
  name  = "opencti-vxvault-connector"
  model = var.juju_model_name

  charm {
    name     = "opencti-vxvault-connector"
    channel  = "latest/edge"
    revision = 14
    base     = "ubuntu@24.04"
  }

  config = {
    connector-scope           = "vxvault"
    vxvault-create-indicators = true
    vxvault-interval          = 10
    vxvault-ssl-verify        = true
    vxvault-url               = "https://vxvault.net/URL_List.php"
  }
}

resource "juju_integration" "ingress" {
  model = var.juju_model_name

  application {
    name     = module.opencti.app_name
    endpoint = module.opencti.requires.ingress
  }

  application {
    name     = juju_application.gateway-api-integrator.name
    endpoint = "gateway"
  }
}

resource "juju_integration" "tls-certificates" {
  model = var.juju_model_name

  application {
    name     = juju_application.gateway-api-integrator.name
    endpoint = "certificates"
  }

  application {
    name     = juju_application.lego.name
    endpoint = "certificates"
  }
}

resource "juju_integration" "opencti-grafana" {
  model = var.juju_model_name

  application {
    name     = module.opencti.app_name
    endpoint = module.opencti.provides.grafana_dashboard
  }

  application {
    offer_url = var.grafana_offer_url
  }
}

resource "juju_integration" "opencti-prometheus-scrape" {
  model = var.juju_model_name

  application {
    name     = module.opencti.app_name
    endpoint = module.opencti.provides.metrics_endpoint
  }

  application {
    offer_url = var.prometheus_metrics_endpoint_offer_url
  }
}

resource "juju_integration" "opencti-loki" {
  model = var.juju_model_name

  application {
    name     = module.opencti.app_name
    endpoint = module.opencti.requires.logging
  }

  application {
    offer_url = var.loki_offer_url
  }
}

resource "juju_integration" "opencti-connector" {
  for_each = local.connector_charms

  model = var.juju_model_name

  application {
    name     = module.opencti.app_name
    endpoint = module.opencti.requires.opencti_connector
  }

  application {
    name     = each.key
    endpoint = "opencti-connector"
  }
}

resource "juju_integration" "opencti-connector-loki" {
  for_each = local.connector_charms

  model = var.juju_model_name

  application {
    name     = each.key
    endpoint = "logging"
  }

  application {
    offer_url = var.loki_offer_url
  }
}

resource "juju_integration" "opensearch-grafana-agent" {
  model = var.juju_db_model_name

  application {
    name     = "opensearch"
    endpoint = "cos-agent"
  }

  application {
    name     = juju_application.grafana-agent.name
    endpoint = "cos-agent"
  }

  provider = juju.opencti_db
}

resource "juju_integration" "grafana-agent-cos" {
  for_each = toset([
    var.grafana_offer_url,
    var.loki_offer_url,
    var.prometheus_remote_write_offer_url
  ])

  model = var.juju_db_model_name

  application {
    name = juju_application.grafana-agent.name
  }

  application {
    offer_url = each.key
  }

  provider = juju.opencti_db
}

resource "juju_secret" "opencti-admin" {
  name  = "opencti-admin"
  model = var.juju_model_name
  value = {
    email    = data.vault_generic_secret.opencti-admin.data["email"]
    password = data.vault_generic_secret.opencti-admin.data["password"]
  }
}

resource "juju_offer" "opencti_connector" {
  model            = var.juju_model_name
  application_name = module.opencti.app_name
  endpoints        = [module.opencti.requires.opencti_connector]
}

resource "juju_access_offer" "opencti_connector" {
  admin     = [var.juju_model_name]
  offer_url = juju_offer.opencti_connector.url
  consume   = var.opencti_consumers
}

resource "juju_application" "landscape-client" {
  name  = "landscape-client"
  model = var.juju_db_model_name

  charm {
    name     = "landscape-client"
    revision = 72
    channel  = "latest/stable"
    base     = "ubuntu@22.04"
  }

  config = {
    registration-key = data.vault_generic_secret.landscape_registration_key.data["key"]
    url              = "https://landscape.is.canonical.com/message-system"
    ping-url         = "http://landscape.is.canonical.com/ping"
    account-name     = "standalone"
  }

  provider = juju.opencti_db
}

resource "juju_integration" "landscape_client" {
  for_each = local.machine_charms
  model    = var.juju_db_model_name

  application {
    name     = each.key
    endpoint = "juju-info"
  }
  application {
    name     = juju_application.landscape-client.name
    endpoint = "container"
  }

  provider = juju.opencti_db
}

resource "juju_application" "ubuntu_pro" {
  name  = "ubuntu-pro"
  model = var.juju_db_model_name

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

  provider = juju.opencti_db
}

resource "juju_integration" "ubuntu_pro" {
  for_each = local.machine_charms
  model    = var.juju_db_model_name

  application {
    name     = each.key
    endpoint = "juju-info"
  }
  application {
    name     = juju_application.ubuntu_pro.name
    endpoint = "juju-info"
  }

  provider = juju.opencti_db
}
