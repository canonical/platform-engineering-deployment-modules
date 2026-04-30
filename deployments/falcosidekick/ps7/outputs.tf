output "falcosidekick_http_endpoint_offer_url" {
  value = juju_offer.falcosidekick_http_endpoint.url
}

output "components" {
  value = {
    falcosidekick        = module.falcosidekick
    falcosidekick_ingress_configurator = juju_application.ingress_configurator_falcosidekick
  }
  description = "All Terraform charm modules which make up this product module"
}
