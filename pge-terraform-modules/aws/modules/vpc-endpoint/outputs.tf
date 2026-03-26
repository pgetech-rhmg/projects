output "vpc_endpoint_id" {
  value       = aws_vpc_endpoint.vpc_endpoint.id
  description = "The ID of the VPC endpoint"
}

output "vpc_endpoint_arn" {
  value       = aws_vpc_endpoint.vpc_endpoint.arn
  description = "The Amazon Resource Name (ARN) of the VPC endpoint"
}

output "vpc_endpoint_dns_entry" {
  value       = aws_vpc_endpoint.vpc_endpoint.dns_entry
  description = "The DNS entries for the VPC Endpoint"
}

output "vpc_endpoint_network_interface_ids" {
  value       = aws_vpc_endpoint.vpc_endpoint.network_interface_ids
  description = "One or more network interfaces for the VPC Endpoint"
}

output "vpc_endpoint_owner_id" {
  value       = aws_vpc_endpoint.vpc_endpoint.owner_id
  description = "The ID of the AWS account that owns the VPC endpoint"
}

output "vpc_endpoint_requester_managed" {
  value       = aws_vpc_endpoint.vpc_endpoint.requester_managed
  description = "Whether or not the VPC Endpoint is being managed by its service"
}

output "vpc_endpoint_state" {
  value       = aws_vpc_endpoint.vpc_endpoint.state
  description = "The state of the VPC endpoint"
}

output "vpc_endpoint_tags_all" {
  value       = aws_vpc_endpoint.vpc_endpoint.tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider"
}