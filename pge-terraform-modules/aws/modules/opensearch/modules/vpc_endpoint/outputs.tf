output "vpc_endpoint" {
  description = "The connection endpoint ID for connecting to the domain"
  value       = aws_opensearch_vpc_endpoint.vpc_endpoint.endpoint
}

output "vpc_endpoint_id" {
  description = "The VPC endpoint id"
  value       = aws_opensearch_vpc_endpoint.vpc_endpoint.id
}

output "vpc_endpoint_all" {
  description = "Map of all VPC endpoint attributes"
  value       = aws_opensearch_vpc_endpoint.vpc_endpoint
}