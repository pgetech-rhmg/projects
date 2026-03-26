#Outputs for snapshot cluster
output "neptune_snapshot_allocated_storage" {
  description = "Specifies the allocated storage size in gigabytes (GB)."
  value       = module.neptune_cluster_snapshot.neptune_snapshot_allocated_storage
}

output "neptune_snapshot_availability_zones" {
  description = "List of EC2 Availability Zones that instances in the DB cluster snapshot can be restored in."
  value       = module.neptune_cluster_snapshot.neptune_snapshot_availability_zones
}

output "neptune_snapshot_db_cluster_snapshot_arn" {
  description = "The Amazon Resource Name (ARN) for the DB Cluster Snapshot."
  value       = module.neptune_cluster_snapshot.neptune_snapshot_db_cluster_snapshot_arn
}

output "neptune_snapshot_engine" {
  description = "Specifies the name of the database engine."
  value       = module.neptune_cluster_snapshot.neptune_snapshot_engine
}

output "neptune_snapshot_engine_version" {
  description = "Version of the database engine for this DB cluster snapshot."
  value       = module.neptune_cluster_snapshot.neptune_snapshot_engine_version
}

output "neptune_snapshot_kms_key_id" {
  description = "If storage_encrypted is true, the AWS KMS key identifier for the encrypted DB cluster snapshot."
  value       = module.neptune_cluster_snapshot.neptune_snapshot_kms_key_id
}

output "neptune_snapshot_license_model" {
  description = "License model information for the restored DB cluster."
  value       = module.neptune_cluster_snapshot.neptune_snapshot_license_model
}

output "neptune_snapshot_port" {
  description = "Port that the DB cluster was listening on at the time of the snapshot."
  value       = module.neptune_cluster_snapshot.neptune_snapshot_port
}

output "neptune_snapshot_storage_encrypted" {
  description = "Specifies whether the DB cluster snapshot is encrypted."
  value       = module.neptune_cluster_snapshot.neptune_snapshot_storage_encrypted
}

output "neptune_snapshot_status" {
  description = "The status of this DB Cluster Snapshot."
  value       = module.neptune_cluster_snapshot.neptune_snapshot_status
}

output "neptune_snapshot_vpc_id" {
  description = "The VPC ID associated with the DB cluster snapshot."
  value       = module.neptune_cluster_snapshot.neptune_snapshot_vpc_id
}

#Outputs for event subscription
output "event_subscription_id" {
  description = "The name of the Neptune event notification subscription."
  value       = module.neptune_event_subscription.event_subscription_id
}

output "event_subscription_arn" {
  description = "The Amazon Resource Name of the Neptune event notification subscription."
  value       = module.neptune_event_subscription.event_subscription_arn
}

output "event_subscription_customer_aws_id" {
  description = "The AWS customer account associated with the Neptune event notification subscription."
  value       = module.neptune_event_subscription.event_subscription_customer_aws_id
}

output "event_subscription_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.neptune_event_subscription.event_subscription_tags_all
}

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
