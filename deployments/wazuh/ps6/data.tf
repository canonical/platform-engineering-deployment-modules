data "vault_generic_secret" "landscape_registration_key" {
  path = "secret/juju/common/subordinates/landscape-registration"
}

data "vault_generic_secret" "lego_credentials" {
  path = "secret/prodstack6/roles/${var.juju_server_model_name}/lego"
}

data "vault_generic_secret" "ubuntu_pro_token" {
  path = "secret/juju/common/subordinates/ubuntu-pro"
}

data "vault_generic_secret" "s3" {
  path = "secret/prodstack6/roles/${var.juju_server_model_name}/s3"
}

data "vault_generic_secret" "git_ssh_key" {
  path = "secret/prodstack6/roles/${var.juju_server_model_name}/github-ssh-key"
}
