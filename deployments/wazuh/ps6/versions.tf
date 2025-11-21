terraform {
  required_version = ">= 1.6.6"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.8.0"
    }
    juju = {
      source                = "juju/juju"
      version               = "~> 0.23.0"
      configuration_aliases = [juju.wazuh_indexer, juju.wazuh_dashboard]
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.54.1"
    }
  }
}
