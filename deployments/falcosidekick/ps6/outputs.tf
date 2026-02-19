output "falcosidekick_app_name" {
  description = "Name of the deployed Lego application."
  value       = module.falcosidekick.falco_k8s.name
}

output "falcosidekick_provides" {
  value = module.falcosidekick.falcosidekick_provides
}
