output "vpc_endpoint_service_id_networklb" {
  value       = aws_vpc_endpoint_service.network_load_balancer.id
  description = "The ID of the VPC endpoint Service for the Network Load Balancer."
}

output "vpc_endpoint_service_arn_networklb" {
  value       = aws_vpc_endpoint_service.network_load_balancer.arn
  description = "The ARN of the VPC endpoint Service for the Network Load Balancer."
}

output "vpc_endpoint_service_availability_zones_networklb" {
  value       = aws_vpc_endpoint_service.network_load_balancer.availability_zones
  description = "The Availability Zones in which the service for the Network Load Balancer is available."
}

output "vpc_endpoint_service_base_endpoint_dns_names_networklb" {
  value       = aws_vpc_endpoint_service.network_load_balancer.base_endpoint_dns_names
  description = "The DNS names for the service for the Network Load Balancer."
}

output "vpc_endpoint_service_manages_vpc_endpoints_networklb" {
  value       = aws_vpc_endpoint_service.network_load_balancer.manages_vpc_endpoints
  description = "Whether or not the service manages its VPC endpoints - true or false."
}

output "vpc_endpoint_service_servicename_networklb" {
  value       = aws_vpc_endpoint_service.network_load_balancer.service_name
  description = "The service_name of the VPC endpoint Service for the Network Load Balancer."
}

output "vpc_endpoint_service_service_type_networklb" {
  value       = aws_vpc_endpoint_service.network_load_balancer.service_type
  description = "The service_type of the VPC endpoint Service for the Network Load Balancer."
}

output "vpc_endpoint_service_state_networklb" {
  value       = aws_vpc_endpoint_service.network_load_balancer.state
  description = "Verification state of the VPC endpoint service for the Network Load Balancer. Consumers of the endpoint service can use the private name only when the state is verified."
}

output "vpc_endpoint_service_tags_all_networklb" {
  value       = aws_vpc_endpoint_service.network_load_balancer.tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
}