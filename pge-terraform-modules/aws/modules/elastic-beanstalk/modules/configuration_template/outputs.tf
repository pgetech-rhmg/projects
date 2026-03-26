#Outputs for configuration template
output "name" {
  description = "The name of the template."
  value       = aws_elastic_beanstalk_configuration_template.configuration_template.name
}

output "application" {
  description = "Name of the application to associate with this configuration template."
  value       = aws_elastic_beanstalk_configuration_template.configuration_template.application
}

output "description" {
  description = "Description of the template."
  value       = aws_elastic_beanstalk_configuration_template.configuration_template.description
}

output "environment_id" {
  description = "The ID of the environment used with this configuration template."
  value       = aws_elastic_beanstalk_configuration_template.configuration_template.environment_id
}

output "solution_stack_name" {
  description = "Name of the solution stack."
  value       = aws_elastic_beanstalk_configuration_template.configuration_template.solution_stack_name
}

output "aws_elastic_beanstalk_configuration_template_all" {
  description = "Map of all aws_elastic_beanstalk_configuration_template attributes"
  value       = aws_elastic_beanstalk_configuration_template.configuration_template
}