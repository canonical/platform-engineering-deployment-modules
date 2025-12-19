output "s3_creds" {
  value     = openstack_identity_ec2_credential_v3.wazuh_indexer_s3_creds
  sensitive = true
}

output "lego_app_name" {
  description = "Name of the deployed Lego application."
  value       = juju_application.lego.name
}

output "lego_provides" {
  value = {
    certificates = "certificates"
  }
}

output "lego_offer_url" {
  value = juju_offer.lego.url
}

output "self_signed_certificates_app_name" {
  description = "Name of the deployed self-signed-certificates application."
  value       = module.wazuh.self_signed_certificates_app_name
}

output "self_signed_certificates_provides" {
  value = module.wazuh.self_signed_certificates_provides
}
