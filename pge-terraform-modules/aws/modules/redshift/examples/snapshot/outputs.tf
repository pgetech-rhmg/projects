#Parameter group
output "parameter_group_arn" {
  description = "Amazon Resource Name (ARN) of parameter group."
  value       = module.parameter_group.parameter_group_arn
}

output "parameter_group_id" {
  description = "The Redshift parameter group name."
  value       = module.parameter_group.parameter_group_id
}

#Subnet group
output "redshift_subnet_group_arn" {
  description = "Amazon Resource Name (ARN) of the Redshift Subnet group name"
  value       = module.redshift_subnet_group.redshift_subnet_group_arn
}

output "redshift_subnet_group_id" {
  description = "The Redshift Subnet group ID."
  value       = module.redshift_subnet_group.redshift_subnet_group_id
}

output "redshift_subnet_group_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = module.redshift_subnet_group.redshift_subnet_group_tags_all
}

#Snapshot Schedule
output "snapshot_schedule_arn" {
  description = "Amazon Resource Name (ARN) of the Redshift Snapshot Schedule."
  value       = module.snapshot_schedule.snapshot_schedule_arn
}

output "snapshot_schedule_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider."
  value       = module.snapshot_schedule.snapshot_schedule_tags_all
}

#Event Subscription
output "redshift_event_subscription_arn" {
  description = "Amazon Resource Name (ARN) of the Redshift event notification subscription"
  value       = module.redshift_event_subscription.redshift_event_subscription_arn
}

output "redshift_event_subscription_id" {
  description = "The name of the Redshift event notification subscription"
  value       = module.redshift_event_subscription.redshift_event_subscription_id
}

output "redshift_event_subscription_customer_aws_id" {
  description = "The AWS customer account associated with the Redshift event notification subscription"
  value       = module.redshift_event_subscription.redshift_event_subscription_customer_aws_id
}

output "redshift_event_subscription_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider."
  value       = module.redshift_event_subscription.redshift_event_subscription_tags_all
}

#Snapshot Copy Grant
output "snapshot_grant_arn" {
  description = "Amazon Resource Name (ARN) of the Redshift sanpshot copy grant."
  value       = module.sanpshot_copy_grant_tf.snapshot_grant_copy_arn
}

output "snapshot_grant_id" {
  description = "ID of the Redshift sanpshot copy grant."
  value       = module.sanpshot_copy_grant_tf.snapshot_grant_copy_id
}

#Cluster
output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster."
  value       = module.cluster.cluster_arn
}

output "cluster_id" {
  description = "The Redshift Cluster ID."
  value       = module.cluster.cluster_id
}

output "cluster_cluster_identifier" {
  description = "The Cluster Identifier."
  value       = module.cluster.cluster_cluster_identifier
}

output "cluster_cluster_type" {
  description = "The cluster type."
  value       = module.cluster.cluster_cluster_type
}

output "cluster_node_type" {
  description = "The type of nodes in the cluster."
  value       = module.cluster.cluster_node_type
}

output "cluster_database_name" {
  description = "The name of the default database in the Cluster."
  value       = module.cluster.cluster_database_name
}

output "cluster_availability_zone" {
  description = "The availability zone of the Cluster."
  value       = module.cluster.cluster_availability_zone
}

output "cluster_automated_snapshot_retention_period" {
  description = "The backup retention period."
  value       = module.cluster.cluster_automated_snapshot_retention_period
}

output "cluster_preferred_maintenance_window" {
  description = "The backup window."
  value       = module.cluster.cluster_preferred_maintenance_window
}

output "cluster_endpoint" {
  description = "The connection endpoint."
  value       = module.cluster.cluster_endpoint
}

output "cluster_encrypted" {
  description = "Whether the data in the cluster is encrypted."
  value       = module.cluster.cluster_encrypted
}


output "cluster_vpc_security_group_ids" {
  description = "The VPC security group Ids associated with the cluster."
  value       = module.cluster.cluster_vpc_security_group_ids
}

output "cluster_dns_name" {
  description = "The DNS name of the cluster."
  value       = module.cluster.cluster_dns_name
}

output "cluster_port" {
  description = "The Port the cluster responds on."
  value       = module.cluster.cluster_port
}

output "cluster_cluster_version" {
  description = "The version of Redshift engine software."
  value       = module.cluster.cluster_cluster_version
}

output "cluster_cluster_parameter_group_name" {
  description = "The name of the parameter group to be associated with this cluster."
  value       = module.cluster.cluster_cluster_parameter_group_name
}

output "cluster_cluster_subnet_group_name" {
  description = "The name of a cluster subnet group to be associated with this cluster."
  value       = module.cluster.cluster_cluster_subnet_group_name
}

output "cluster_cluster_public_key" {
  description = "The public key for the cluster."
  value       = module.cluster.cluster_cluster_public_key
}

output "cluster_cluster_revision_number" {
  description = "The specific revision number of the database in the cluster."
  value       = module.cluster.cluster_cluster_revision_number
}

output "cluster_cluster_nodes" {
  description = "The nodes in the cluster. Cluster node blocks are documented below."
  value       = module.cluster.cluster_cluster_nodes
}

output "cluster_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.cluster.cluster_tags_all
}