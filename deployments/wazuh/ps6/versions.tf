terraform {
  required_version = ">= 1.6.6"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.6.0"
    }
    juju = {
      source                = "juju/juju"
      version               = "~> 1.1.1"
      configuration_aliases = [juju.wazuh_indexer, juju.wazuh_dashboard]
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.54.1"
    }
  }
}
