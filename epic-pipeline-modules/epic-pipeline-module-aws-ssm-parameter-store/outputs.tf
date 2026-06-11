output "parameter_name" {
  description = "Resolved parameter name (path)."
  value       = aws_ssm_parameter.this.name
}

output "parameter_arn" {
  description = "Parameter ARN."
  value       = aws_ssm_parameter.this.arn
}

output "parameter_version" {
  description = "Parameter version."
  value       = aws_ssm_parameter.this.version
}

output "parameter_type" {
  description = "Parameter type (String, StringList, SecureString)."
  value       = aws_ssm_parameter.this.type
}
