output "arn" {
  description = "The ARN assigned by AWS for this Elastic Beanstalk Application."
  value       = aws_elastic_beanstalk_application.elastic_beanstalk.arn
}

output "name" {
  description = "The name assigned by AWS for this Elastic Beanstalk Application."
  value       = aws_elastic_beanstalk_application.elastic_beanstalk.name
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_elastic_beanstalk_application.elastic_beanstalk.tags_all
}

output "aws_elastic_beanstalk_application_all" {
  description = "A map of all aws_elastic_beanstalk_application attributes"
  value       = aws_elastic_beanstalk_application.elastic_beanstalk
}