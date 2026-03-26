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

#Outputs for application version
output "application_version_arn" {
  description = "ARN assigned by AWS for this Elastic Beanstalk Application."
  value       = module.elastic_beanstalk_application_version.arn
}

#Outputs for environment
output "all_settings" {
  description = "List of all option settings configured in this Environment."
  value       = module.elastic_beanstalk_environment.all_settings
}