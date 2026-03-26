output "name" {
  value       = data.aws_ssm_parameter.read.name
  description = "Name of the parameter."
}

output "value" {
  value       = data.aws_ssm_parameter.read.value
  description = "Value of the parameter. This value is always marked as sensitive in the Terraform plan output, regardless of type."
  sensitive   = true
}

output "arn" {
  value       = data.aws_ssm_parameter.read.arn
  description = "ARN of the parameter."
}

output "version" {
  value       = data.aws_ssm_parameter.read.version
  description = "Version of the parameter."
}

output "type" {
  value       = data.aws_ssm_parameter.read.type
  description = "Type of the parameter. Valid types are String, StringList and SecureString."
}
