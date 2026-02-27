############################################
# Outputs
############################################

output "eb_application_name" {
  value = aws_elastic_beanstalk_application.this.name
}

output "eb_environment_name" {
  value = aws_elastic_beanstalk_environment.this.name
}

output "eb_endpoint_url" {
  value = aws_elastic_beanstalk_environment.this.endpoint_url
}

output "eb_cname" {
  value = aws_elastic_beanstalk_environment.this.cname
}
