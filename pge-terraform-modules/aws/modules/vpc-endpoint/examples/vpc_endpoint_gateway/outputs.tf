output "vpc_endpoint_id" {
  value       = module.vpc_endpoint.vpc_endpoint_id
  description = "The ID of the VPC endpoint"
}

output "vpc_endpoint_arn" {
  value       = module.vpc_endpoint.vpc_endpoint_arn
  description = "The Amazon Resource Name (ARN) of the VPC endpoint"
}

output "vpc_endpoint_cidr_blocks" {
  value       = module.vpc_endpoint.vpc_endpoint_cidr_blocks
  description = "The list of CIDR blocks for the exposed AWS service"
}

output "vpc_endpoint_owner_id" {
  value       = module.vpc_endpoint.vpc_endpoint_owner_id
  description = "The ID of the AWS account that owns the VPC endpoint"
}

output "vpc_endpoint_prefix_list_id" {
  value       = module.vpc_endpoint.vpc_endpoint_prefix_list_id
  description = "The prefix list ID of the exposed AWS service"
}

output "vpc_endpoint_requester_managed" {
  value       = module.vpc_endpoint.vpc_endpoint_requester_managed
  description = "Whether or not the VPC Endpoint is being managed by its service"
}

output "vpc_endpoint_state" {
  value       = module.vpc_endpoint.vpc_endpoint_state
  description = "The state of the VPC endpoint"
}

output "vpc_endpoint_tags_all" {
  value       = module.vpc_endpoint.vpc_endpoint_tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider"
}
