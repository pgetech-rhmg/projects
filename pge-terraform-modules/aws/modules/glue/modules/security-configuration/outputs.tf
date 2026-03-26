# Outputs for Glue Security Configuration

output "glue_security_configuration_id" {
  description = "Glue security configuration name"
  value       = aws_glue_security_configuration.glue_security_configuration.id
}

output "aws_glue_security_configuration" {
  description = "A map of aws_glue_security_configuration object."
  value       = aws_glue_security_configuration.glue_security_configuration
}