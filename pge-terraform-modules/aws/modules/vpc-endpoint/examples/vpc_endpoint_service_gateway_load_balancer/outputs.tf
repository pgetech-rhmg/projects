output "vpc_endpoint_service_id_gatewaylb" {
  value       = module.vpc_endpoint_service_gateway_load_balancer.vpc_endpoint_service_id_gatewaylb
  description = "The ID of the VPC endpoint Service for the Gateway Load Balancer."
}

output "vpc_endpoint_service_arn_gatewaylb" {
  value       = module.vpc_endpoint_service_gateway_load_balancer.vpc_endpoint_service_arn_gatewaylb
  description = "The ARN of the VPC endpoint Service for the Gateway Load Balancer."
}

output "vpc_endpoint_service_service_name_gatewaylb" {
  value       = module.vpc_endpoint_service_gateway_load_balancer.vpc_endpoint_service_service_name_gatewaylb
  description = "The service_name of the VPC endpoint Service for the Gateway Load Balancer"
}

output "vpc_endpoint_service_service_type_gatewaylb" {
  value       = module.vpc_endpoint_service_gateway_load_balancer.vpc_endpoint_service_service_type_gatewaylb
  description = "The service_type of the VPC endpoint Service for the Gateway Load Balancer"
}

output "vpc_endpoint_service_availability_zones_gatewaylb" {
  value       = module.vpc_endpoint_service_gateway_load_balancer.vpc_endpoint_service_availability_zones_gatewaylb
  description = "The Availability Zones in which the service is available."
}

output "vpc_endpoint_service_base_endpoint_dns_names_gatewaylb" {
  value       = module.vpc_endpoint_service_gateway_load_balancer.vpc_endpoint_service_base_endpoint_dns_names_gatewaylb
  description = "The DNS names for the service."
}

output "vpc_endpoint_service_manages_vpc_endpoints_gatewaylb" {
  value       = module.vpc_endpoint_service_gateway_load_balancer.vpc_endpoint_service_manages_vpc_endpoints_gatewaylb
  description = " Whether or not the service manages its VPC endpoints - true or false."
}

output "vpc_endpoint_service_state_gatewaylb" {
  value       = module.vpc_endpoint_service_gateway_load_balancer.vpc_endpoint_service_state_gatewaylb
  description = "The state of the VPC endpoint service."
}

output "vpc_endpoint_service_tags_all_gatewaylb" {
  value       = module.vpc_endpoint_service_gateway_load_balancer.vpc_endpoint_service_tags_all_gatewaylb
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
}