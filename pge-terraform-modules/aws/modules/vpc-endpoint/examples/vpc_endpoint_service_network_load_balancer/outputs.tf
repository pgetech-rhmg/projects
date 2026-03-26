output "vpc_endpoint_service_id_networklb" {
  value       = module.vpc_endpoint_service_network_load_balancer.vpc_endpoint_service_id_networklb
  description = "The ID of the VPC endpoint service."
}

output "vpc_endpoint_service_arn_networklb" {
  value       = module.vpc_endpoint_service_network_load_balancer.vpc_endpoint_service_arn_networklb
  description = "The ARN of the VPC endpoint service"
}

output "vpc_endpoint_service_servicename_networklb" {
  value       = module.vpc_endpoint_service_network_load_balancer.vpc_endpoint_service_servicename_networklb
  description = "The service_name of the VPC endpoint Service for the Network Load Balancer"
}

output "vpc_endpoint_service_service_type_networklb" {
  value       = module.vpc_endpoint_service_network_load_balancer.vpc_endpoint_service_service_type_networklb
  description = "The service_type of the VPC endpoint Service for the Network Load Balancer"
}

output "vpc_endpoint_service_availability_zones_networklb" {
  value       = module.vpc_endpoint_service_network_load_balancer.vpc_endpoint_service_availability_zones_networklb
  description = "The Availability Zones in which the service is available."
}

output "vpc_endpoint_service_base_endpoint_dns_names_networklb" {
  value       = module.vpc_endpoint_service_network_load_balancer.vpc_endpoint_service_base_endpoint_dns_names_networklb
  description = "The DNS names for the service."
}

output "vpc_endpoint_service_manages_vpc_endpoints_networklb" {
  value       = module.vpc_endpoint_service_network_load_balancer.vpc_endpoint_service_manages_vpc_endpoints_networklb
  description = " Whether or not the service manages its VPC endpoints - true or false."
}

output "vpc_endpoint_service_state_networklb" {
  value       = module.vpc_endpoint_service_network_load_balancer.vpc_endpoint_service_state_networklb
  description = "The state of the VPC endpoint service."
}

output "vpc_endpoint_service_tags_all_networklb" {
  value       = module.vpc_endpoint_service_network_load_balancer.vpc_endpoint_service_tags_all_networklb
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
}