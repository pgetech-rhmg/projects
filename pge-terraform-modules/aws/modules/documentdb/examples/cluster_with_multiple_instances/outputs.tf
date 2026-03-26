#Outputs for cluster
output "docdb_cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster."
  value       = module.docdb_cluster.docdb_cluster_arn
}

output "docdb_cluster_cluster_members" {
  description = "List of DocDB Instances that are a part of this cluster."
  value       = module.docdb_cluster.docdb_cluster_cluster_members
}

output "docdb_cluster_resource_id" {
  description = "The DocDB Cluster Resource ID."
  value       = module.docdb_cluster.docdb_cluster_resource_id
}

output "docdb_cluster_endpoint" {
  description = "The DNS address of the DocDB instance."
  value       = module.docdb_cluster.docdb_cluster_endpoint
}

output "docdb_cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint."
  value       = module.docdb_cluster.docdb_cluster_hosted_zone_id
}

output "docdb_cluster_id" {
  description = "The DocDB Cluster Identifier."
  value       = module.docdb_cluster.docdb_cluster_id
}

output "docdb_cluster_reader_endpoint" {
  description = "A read-only endpoint for the DocDB cluster, automatically load-balanced across replicas."
  value       = module.docdb_cluster.docdb_cluster_reader_endpoint
}

output "docdb_cluster_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = module.docdb_cluster.docdb_cluster_tags_all
}

#Outputs for subnet group
output "docdb_subnet_group_id" {
  description = "The docdb subnet group name."
  value       = module.subnet_group.docdb_subnet_group_id
}

output "docdb_subnet_group_arn" {
  description = "The ARN of the docdb subnet group."
  value       = module.subnet_group.docdb_subnet_group_arn
}

output "docdb_subnet_group_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = module.subnet_group.docdb_subnet_group_tags_all
}

#Outputs for cluster parameter group
output "documentdb_cluster_parameter_group_id" {
  description = "The documentDB cluster parameter group name."
  value       = module.cluster_parameter_group.documentdb_cluster_parameter_group_id
}

output "documentdb_cluster_parameter_group_arn" {
  description = "The ARN of the documentDB cluster parameter group."
  value       = module.cluster_parameter_group.documentdb_cluster_parameter_group_arn
}

output "documentdb_cluster_parameter_group_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.cluster_parameter_group.documentdb_cluster_parameter_group_tags_all
}