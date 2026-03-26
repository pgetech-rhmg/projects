output "endpoint_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this endpoint."
  value       = aws_sagemaker_endpoint.endpoint.arn
}

output "endpoint_name" {
  description = "The name of the endpoint."
  value       = aws_sagemaker_endpoint.endpoint.name
}

output "sagemaker_endpoint_all" {
  description = "A map of aws sagemaker endpoint"
  value       = aws_sagemaker_endpoint.endpoint
}