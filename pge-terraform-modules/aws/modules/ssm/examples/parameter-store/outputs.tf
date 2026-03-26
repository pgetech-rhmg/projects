output "name" {
  description = "Name of the ssm parameter."
  value       = module.ssm.name
}

output "version" {
  description = "Version of the ssm parameter."
  value       = module.ssm.version
}

output "arn" {
  description = "ARN of the ssm parameter."
  value       = module.ssm.arn
}

output "type" {
  description = "Type of the ssm parameter."
  value       = module.ssm.type
}
