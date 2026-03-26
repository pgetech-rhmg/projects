#Outputs for environment
output "id" {
  description = "ID of the Elastic Beanstalk Environment."
  value       = aws_elastic_beanstalk_environment.environment.id
}

output "name" {
  description = "Name of the Elastic Beanstalk Environment."
  value       = aws_elastic_beanstalk_environment.environment.name
}

output "description" {
  description = "Description of the Elastic Beanstalk Environment."
  value       = aws_elastic_beanstalk_environment.environment.description
}

output "tier" {
  description = "The environment tier specified."
  value       = aws_elastic_beanstalk_environment.environment.tier
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider"
  value       = aws_elastic_beanstalk_environment.environment.tags_all
}

output "application" {
  description = "The Elastic Beanstalk Application specified for this environment."
  value       = aws_elastic_beanstalk_environment.environment.application
}

output "setting" {
  description = "Settings specifically set for this Environment."
  value       = aws_elastic_beanstalk_environment.environment.setting
}

output "all_settings" {
  description = "List of all option settings configured in this Environment. "
  value       = aws_elastic_beanstalk_environment.environment.all_settings
}

output "cname" {
  description = "Fully qualified DNS name for this Environment."
  value       = aws_elastic_beanstalk_environment.environment.cname
}

output "autoscaling_groups" {
  description = "The autoscaling groups used by this Environment."
  value       = aws_elastic_beanstalk_environment.environment.autoscaling_groups
}

output "instances" {
  description = "Instances used by this Environment."
  value       = aws_elastic_beanstalk_environment.environment.instances
}

output "launch_configurations" {
  description = "Launch configurations in use by this Environment."
  value       = aws_elastic_beanstalk_environment.environment.launch_configurations
}

output "load_balancers" {
  description = "Elastic load balancers in use by this Environment."
  value       = aws_elastic_beanstalk_environment.environment.load_balancers
}

output "queues" {
  description = "SQS queues in use by this Environment."
  value       = aws_elastic_beanstalk_environment.environment.queues
}

output "triggers" {
  description = " Autoscaling triggers in use by this Environment."
  value       = aws_elastic_beanstalk_environment.environment.triggers
}

output "endpoint_url" {
  description = "The URL to the Load Balancer for this Environment"
  value       = aws_elastic_beanstalk_environment.environment.endpoint_url
}


output "aws_elastic_beanstalk_environment_all" {
  description = "Map of all aws_elastic_beanstalk_environment attributes"
  value       = aws_elastic_beanstalk_environment.environment
}