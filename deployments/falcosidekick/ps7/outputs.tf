output "falcosidekick_http_endpoint_offer_url" {
  value = juju_offer.falcosidekick_http_endpoint.url
}

output "components" {
  value = {
    falcosidekick        = module.falcosidekick
    ingress_configurator = module.ingress_configurator
  }
  description = "All Terraform charm modules which make up this product module"
}
