output "s3_creds" {
  value     = openstack_identity_ec2_credential_v3.wazuh_indexer_s3_creds
  sensitive = true
}

output "lego_provides" {
  value = {
    certificates = "certificates"
  }
}
