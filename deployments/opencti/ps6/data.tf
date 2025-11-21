data "vault_generic_secret" "landscape_registration_key" {
  path = "secret/juju/common/subordinates/landscape-registration"
}

data "vault_generic_secret" "lego_credentials" {
  path = "secret/prodstack6/roles/${var.juju_model_name}/lego"
}

data "vault_generic_secret" "ubuntu_pro_token" {
  path = "secret/juju/common/subordinates/ubuntu-pro"
}

data "vault_generic_secret" "abuseipdb-ipblacklist" {
  path = "secret/prodstack6/roles/${var.juju_model_name}/abuseipdb-ipblacklist"
}

data "vault_generic_secret" "alienvault" {
  path = "secret/prodstack6/roles/${var.juju_model_name}/alienvault"
}

data "vault_generic_secret" "crowdstrike" {
  path = "secret/prodstack6/roles/${var.juju_model_name}/crowdstrike"
}

data "vault_generic_secret" "ipinfo" {
  path = "secret/prodstack6/roles/${var.juju_model_name}/ipinfo"
}

data "vault_generic_secret" "opencti-admin" {
  path = "secret/prodstack6/roles/${var.juju_model_name}/opencti-admin"
}

data "vault_generic_secret" "s3" {
  path = "secret/prodstack6/roles/${var.juju_model_name}/s3"
}

data "vault_generic_secret" "s3_opensearch" {
  path = "secret/prodstack6/roles/${var.juju_db_model_name}/s3"
}

data "vault_generic_secret" "sekoia" {
  path = "secret/prodstack6/roles/${var.juju_model_name}/sekoia"
}
