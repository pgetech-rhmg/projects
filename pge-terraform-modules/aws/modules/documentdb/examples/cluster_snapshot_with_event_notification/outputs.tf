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

#Outputs for cluster snapshot
output "availability_zones" {
  description = "List of EC2 Availability Zones that instances in the DocDB cluster snapshot can be restored in."
  value       = module.docdb_cluster_snapshot.availability_zones
}

output "db_cluster_snapshot_arn" {
  description = "The Amazon Resource Name (ARN) for the DocDB Cluster Snapshot."
  value       = module.docdb_cluster_snapshot.db_cluster_snapshot_arn
}

output "engine" {
  description = "Specifies the name of the database engine."
  value       = module.docdb_cluster_snapshot.engine
}

output "engine_version" {
  description = "Version of the database engine for this DocDB cluster snapshot."
  value       = module.docdb_cluster_snapshot.engine_version
}

output "kms_key_id" {
  description = "If storage_encrypted is true, the AWS KMS key identifier for the encrypted DocDB cluster snapshot."
  value       = module.docdb_cluster_snapshot.kms_key_id
}

output "port" {
  description = "Port that the DocDB cluster was listening on at the time of the snapshot."
  value       = module.docdb_cluster_snapshot.port
}

output "storage_encrypted" {
  description = "Specifies whether the DocDB cluster snapshot is encrypted."
  value       = module.docdb_cluster_snapshot.storage_encrypted
}

output "status" {
  description = "The status of this DocDB Cluster Snapshot."
  value       = module.docdb_cluster_snapshot.status
}

output "vpc_id" {
  description = "The VPC ID associated with the DocDB cluster snapshot."
  value       = module.docdb_cluster_snapshot.vpc_id
}

#Outputs for event subscription
output "event_subscription_id" {
  description = "The name of the DocDB event notification subscription."
  value       = module.event_subscription.event_subscription_id
}

output "event_subscription_arn" {
  description = "The Amazon Resource Name of the DocDB event notification subscription."
  value       = module.event_subscription.event_subscription_arn
}

output "event_subscription_customer_aws_id" {
  description = "The AWS customer account associated with the DocDB event notification subscription."
  value       = module.event_subscription.event_subscription_customer_aws_id
}

output "event_subscription_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.event_subscription.event_subscription_tags_all
}