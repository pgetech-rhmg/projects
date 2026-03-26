#outputs for application version
output "arn" {
  description = "ARN assigned by AWS for this Elastic Beanstalk Application."
  value       = aws_elastic_beanstalk_application_version.application_version.arn
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_elastic_beanstalk_application_version.application_version.tags_all
}

output "aws_elastic_beanstalk_application_version_all" {
  description = "Map of all aws_elastic_beanstalk_application_version attrivutes"
  value       = aws_elastic_beanstalk_application_version.application_version
}