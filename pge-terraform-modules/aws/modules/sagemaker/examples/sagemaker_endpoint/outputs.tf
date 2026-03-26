output "endpoint_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this endpoint."
  value       = module.endpoint.endpoint_arn
}

output "endpoint_name" {
  description = "The name of the endpoint."
  value       = module.endpoint.endpoint_name
}