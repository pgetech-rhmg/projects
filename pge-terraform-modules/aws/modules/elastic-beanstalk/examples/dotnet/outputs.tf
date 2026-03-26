output "arn" {
  description = "The ARN assigned by AWS for this Elastic Beanstalk Application."
  value       = module.elastic_beanstalk_application.arn
}

output "name" {
  description = "elastic beanstalk application name."
  value       = module.elastic_beanstalk_application.name
}


output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.elastic_beanstalk_application.tags_all
}

#Outputs for environment
output "environment_id" {
  description = "ID of the Elastic Beanstalk Environment."
  value       = module.elastic_beanstalk_environment.id
}

output "environment_name" {
  description = "Name of the Elastic Beanstalk Environment."
  value       = module.elastic_beanstalk_environment.name
}

output "environment_description" {
  description = "Description of the Elastic Beanstalk Environment."
  value       = module.elastic_beanstalk_environment.description
}

output "environment_tier" {
  description = "The environment tier specified."
  value       = module.elastic_beanstalk_environment.tier
}

output "environment_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider"
  value       = module.elastic_beanstalk_environment.tags_all
}

output "environment_application" {
  description = "The Elastic Beanstalk Application specified for this environment."
  value       = module.elastic_beanstalk_environment.application
}

output "environment_setting" {
  description = "Settings specifically set for this Environment."
  value       = module.elastic_beanstalk_environment.setting
  sensitive   = true
}

output "environment_all_settings" {
  description = "List of all option settings configured in this Environment. "
  value       = module.elastic_beanstalk_environment.all_settings
  sensitive   = true
}

output "environment_cname" {
  description = "Fully qualified DNS name for this Environment."
  value       = module.elastic_beanstalk_environment.cname
}

output "environment_autoscaling_groups" {
  description = "The autoscaling groups used by this Environment."
  value       = module.elastic_beanstalk_environment.autoscaling_groups
}

output "environment_instances" {
  description = "Instances used by this Environment."
  value       = module.elastic_beanstalk_environment.instances
}

output "environment_launch_configurations" {
  description = "Launch configurations in use by this Environment."
  value       = module.elastic_beanstalk_environment.launch_configurations
}

output "environment_load_balancers" {
  description = "Elastic load balancers in use by this Environment."
  value       = module.elastic_beanstalk_environment.load_balancers
}

output "environment_queues" {
  description = "SQS queues in use by this Environment."
  value       = module.elastic_beanstalk_environment.queues
}

output "environment_triggers" {
  description = " Autoscaling triggers in use by this Environment."
  value       = module.elastic_beanstalk_environment.triggers
}

output "environment_endpoint_url" {
  description = "The URL to the Load Balancer for this Environment"
  value       = module.elastic_beanstalk_environment.endpoint_url
}

#Outputs for application version
output "application_version_arn" {
  description = "ARN assigned by AWS for this Elastic Beanstalk Application."
  value       = module.elastic_beanstalk_application_version.arn
}

#Outputs for Elastic Beanstalk configuration template
output "template_name" {
  description = "The name of the template."
  value       = module.configuration_template.name
}

output "template_application" {
  description = "Name of the application to associate with this configuration template."
  value       = module.configuration_template.application
}

output "template_description" {
  description = "Description of the template."
  value       = module.configuration_template.description
}

output "template_environment_id" {
  description = "The ID of the environment used with this configuration template."
  value       = module.configuration_template.environment_id
}

output "template_solution_stack_name" {
  description = "Name of the solution stack."
  value       = module.configuration_template.solution_stack_name
}
