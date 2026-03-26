output "db_cluster_id" {
  description = "The RDS Cluster Identifier."
  value       = element(concat(aws_rds_cluster.aurora[*].id, [""]), 0)
}
output "db_cluster_arn" {
  description = "The ARN of the db cluster."
  value       = element(concat(aws_rds_cluster.aurora[*].arn, [""]), 0)
}
output "db_cluster_cluster_identifier" {
  description = "The RDS Cluster Identifier."
  value       = element(concat(aws_rds_cluster.aurora[*].cluster_identifier, [""]), 0)
}
output "db_cluster_cluster_resource_id" {
  description = "The RDS Cluster Resource ID."
  value       = element(concat(aws_rds_cluster.aurora[*].cluster_resource_id, [""]), 0)
}
output "db_cluster_cluster_members" {
  description = "List of RDS Instances that are a part of this cluster."
  value       = element(concat(aws_rds_cluster.aurora[*].cluster_members, [""]), 0)
}
output "db_cluster_availability_zones" {
  description = "The availability zone of the instance."
  value       = element(concat(aws_rds_cluster.aurora[*].availability_zones, [""]), 0)
}
output "db_cluster_backup_retention_period" {
  description = "The backup retention period."
  value       = element(concat(aws_rds_cluster.aurora[*].backup_retention_period, [""]), 0)
}
output "db_cluster_preferred_backup_window" {
  description = "The daily time range during which the backups happen."
  value       = element(concat(aws_rds_cluster.aurora[*].preferred_backup_window, [""]), 0)
}
output "db_cluster_preferred_maintenance_window" {
  description = "The maintenance window."
  value       = element(concat(aws_rds_cluster.aurora[*].preferred_maintenance_window, [""]), 0)
}
output "db_cluster_endpoint" {
  description = "The DNS address of the RDS instance."
  value       = element(concat(aws_rds_cluster.aurora[*].endpoint, [""]), 0)
}
output "db_cluster_reader_endpoint" {
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas."
  value       = element(concat(aws_rds_cluster.aurora[*].reader_endpoint, [""]), 0)
}
output "db_cluster_engine" {
  description = "The database engine."
  value       = element(concat(aws_rds_cluster.aurora[*].engine, [""]), 0)
}
output "db_cluster_engine_version_actual" {
  description = "The running version of the database."
  value       = element(concat(aws_rds_cluster.aurora[*].engine_version, [""]), 0)
}
output "db_cluster_database_name" {
  description = "The database name."
  value       = element(concat(aws_rds_cluster.aurora[*].database_name, [""]), 0)
}
output "db_cluster_port" {
  description = "The database port."
  value       = element(concat(aws_rds_cluster.aurora[*].port, [""]), 0)
}
output "db_cluster_master_username" {
  description = "The master username for the database."
  value       = element(concat(aws_rds_cluster.aurora[*].master_username, [""]), 0)
}
output "db_cluster_storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted."
  value       = element(concat(aws_rds_cluster.aurora[*].storage_encrypted, [""]), 0)
}
output "db_cluster_replication_source_identifier" {
  description = "ARN of the source DB cluster or DB instance if this DB cluster is created as a Read Replica."
  value       = element(concat(aws_rds_cluster.aurora[*].replication_source_identifier, [""]), 0)
}
output "db_cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint."
  value       = element(concat(aws_rds_cluster.aurora[*].hosted_zone_id, [""]), 0)
}
output "db_cluster_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block.."
  value       = element(concat(aws_rds_cluster.aurora[*].tags, [""]), 0)
}


output "aws_rds_cluster_all" {
  description = "Map of aws db cluster"
  value       = aws_rds_cluster.aurora
}

output "cluster_master_user_secret" {
  description = "The generated database master user secret when `manage_master_user_password` is set to `true`"
  value       = aws_rds_cluster.aurora.master_user_secret
}
