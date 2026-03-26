
#outputs of cluster
output "cluster_arn" {
  description = "The Neptune Cluster Amazon Resource Name (ARN)"
  value       = module.neptune_cluster.cluster_arn
}

output "neptune_cluster_resource_id" {
  description = "The Neptune Cluster Resource ID"
  value       = module.neptune_cluster.neptune_cluster_resource_id
}

output "neptune_cluster_members" {
  description = "List of Neptune Instances that are a part of this cluster"
  value       = module.neptune_cluster.neptune_cluster_members
}

output "neptune_cluster_endpoint" {
  description = "The DNS address of the Neptune instance"
  value       = module.neptune_cluster.neptune_cluster_endpoint
}

output "hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint"
  value       = module.neptune_cluster.hosted_zone_id
}

output "neptune_cluster_id" {
  description = "The Neptune Cluster Identifier"
  value       = module.neptune_cluster.neptune_cluster_id
}

output "neptune_cluster_reader_endpoint" {
  description = "A read-only endpoint for the Neptune cluster, automatically load-balanced across replicas"
  value       = module.neptune_cluster.neptune_cluster_reader_endpoint
}

output "neptune_cluster_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.neptune_cluster.neptune_cluster_tags_all
}

#Outputs for cluster instance
output "cluster_instance_address" {
  description = "The hostname of the instance."
  value       = module.neptune_cluster_instance.cluster_instance_address
}

output "cluster_instance_arn" {
  description = "Amazon Resource Name (ARN) of neptune instance."
  value       = module.neptune_cluster_instance.cluster_instance_arn
}

output "cluster_instance_dbi_resource_id" {
  description = "The region-unique, immutable identifier for the neptune instance."
  value       = module.neptune_cluster_instance.cluster_instance_dbi_resource_id
}

output "cluster_instance_endpoint" {
  description = "The connection endpoint in address:port format."
  value       = module.neptune_cluster_instance.cluster_instance_endpoint
}

output "cluster_instance_id" {
  description = "The Instance identifier."
  value       = module.neptune_cluster_instance.cluster_instance_id
}

output "cluster_instance_kms_key_arn" {
  description = "The ARN for the KMS encryption key if one is set to the neptune cluster."
  value       = module.neptune_cluster_instance.cluster_instance_kms_key_arn
}

output "cluster_instance_storage_encrypted" {
  description = "Specifies whether the neptune cluster is encrypted."
  value       = module.neptune_cluster_instance.cluster_instance_storage_encrypted
}

output "cluster_instance_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.neptune_cluster_instance.cluster_instance_tags_all
}

output "cluster_instance_writer" {
  description = "Boolean indicating if this instance is writable. False indicates this instance is a read replica."
  value       = module.neptune_cluster_instance.cluster_instance_writer
}

#outputs of cluster endpoint
output "neptune_cluster_endpoint_arn" {
  description = "The Neptune Cluster Endpoint Amazon Resource Name (ARN)."
  value       = module.neptune_cluster_endpoint.neptune_cluster_endpoint_arn
}

output "neptune_endpoint" {
  description = "The DNS address of the endpoint."
  value       = module.neptune_cluster_endpoint.neptune_cluster_endpoint
}

output "neptune_cluster_endpoint_id" {
  description = "The Neptune Cluster Endpoint Identifier"
  value       = module.neptune_cluster_endpoint.neptune_cluster_endpoint_id
}

output "neptune_cluster_endpoint_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.neptune_cluster_endpoint.neptune_cluster_endpoint_tags_all
}

#outputs of cluster parameter group
output "neptune_cluster_parameter_group_id" {
  description = "The neptune cluster parameter group name"
  value       = module.neptune_cluster_parameter_group.neptune_cluster_parameter_group_id
}

output "neptune_cluster_parameter_group_arn" {
  description = "The ARN of the neptune cluster parameter group"
  value       = module.neptune_cluster_parameter_group.neptune_cluster_parameter_group_arn
}

output "neptune_cluster_parameter_group_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block"
  value       = module.neptune_cluster_parameter_group.neptune_cluster_parameter_group_tags_all
}

#outputs of instance parameter group
output "neptune_instance_parameter_group_id" {
  description = "The neptune instance parameter group name"
  value       = module.neptune_instance_parameter_group.neptune_instance_parameter_group_id
}

output "neptune_instance_parameter_group_arn" {
  description = "The ARN of the neptune instance parameter group"
  value       = module.neptune_instance_parameter_group.neptune_instance_parameter_group_arn
}

output "neptune_instance_parameter_group_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block"
  value       = module.neptune_instance_parameter_group.neptune_instance_parameter_group_tags_all
}

#Outputs for subnet group
output "neptune_subnet_group_id" {
  description = "The neptune subnet group name"
  value       = module.neptune_subnet_group.neptune_subnet_group_id
}

output "neptune_subnet_group_arn" {
  description = "The ARN of the neptune subnet group"
  value       = module.neptune_subnet_group.neptune_subnet_group_arn
}

output "neptune_subnet_group_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.neptune_subnet_group.neptune_subnet_group_tags_all
}