output "vpc_endpoint_arn" {
  description = "The Amazon Resource Name (ARN) of the VPC endpoint"
  value       = module.rds_vpc_endpoint_interface.vpc_endpoint_arn
}
output "vpc_endpoint_dns_entry" {
  description = "The DNS entries for the VPC Endpoint"
  value       = module.rds_vpc_endpoint_interface.vpc_endpoint_dns_entry
}
output "vpc_endpoint_id" {
  description = "The ID of the VPC endpoint"
  value       = module.rds_vpc_endpoint_interface.vpc_endpoint_id
}
output "vpc_endpoint_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint"
  value       = module.rds_vpc_endpoint_interface.vpc_endpoint_network_interface_ids
}
output "vpc_endpoint_owner_id" {
  description = "The ID of the AWS account that owns the VPC endpoint"
  value       = module.rds_vpc_endpoint_interface.vpc_endpoint_owner_id
}

output "vpc_endpoint_requester_managed" {
  description = "Whether or not the VPC Endpoint is being managed by its service"
  value       = module.rds_vpc_endpoint_interface.vpc_endpoint_requester_managed
}
output "vpc_endpoint_state" {
  description = "The state of the VPC endpoint"
  value       = module.rds_vpc_endpoint_interface.vpc_endpoint_state
}
output "vpc_endpoint_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider"
  value       = module.rds_vpc_endpoint_interface.vpc_endpoint_tags_all
}

