output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.sor_enterprise_alb.lb_dns_name
}

# Output command IDs for monitoring
output "primary_webadaptor_ssm_command_id" {
  description = "SSM Command ID for Primary WebAdaptor configuration"
  value       = null_resource.trigger_primary_webadaptor_config[*].id
}

output "primary_hosted_arcgiserver_ssm_command_id" {
  description = "SSM Command ID for Primary Hosted ArcGIS Server configuration"
  value       = null_resource.trigger_primary_hosted_arcgisserver_config[*].id
}

output "primary_ent_arcgiserver_ssm_command_id" {
  description = "SSM Command ID for Primary ENT ArcGIS Server configuration"
  value       = null_resource.trigger_primary_ent_arcgisserver_config[*].id
}

output "primary_arcgis_portal_ssm_command_id" {
  description = "SSM Command ID for Primary Portal configuration"
  value       = null_resource.trigger_primary_portal_config[*].id
}