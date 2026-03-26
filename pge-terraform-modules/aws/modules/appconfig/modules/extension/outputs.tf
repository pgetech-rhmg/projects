output "id" {
  description = "AppConfig Extension ID"
  value       = aws_appconfig_extension.pge_extension.id
}

output "arn" {
  description = "ARN of the Extension"
  value       = aws_appconfig_extension.pge_extension.arn
}

output "version" {
  description = "The version number for the extension."
  value       = aws_appconfig_extension.pge_extension.version
}
