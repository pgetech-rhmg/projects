#Outputs for snapshot cluster
output "neptune_snapshot_allocated_storage" {
  description = "Specifies the allocated storage size in gigabytes (GB)."
  value       = aws_neptune_cluster_snapshot.neptune_cluster_snapshot.allocated_storage
}

output "neptune_snapshot_availability_zones" {
  description = "List of EC2 Availability Zones that instances in the DB cluster snapshot can be restored in."
  value       = aws_neptune_cluster_snapshot.neptune_cluster_snapshot.availability_zones
}

output "neptune_snapshot_db_cluster_snapshot_arn" {
  description = "The Amazon Resource Name (ARN) for the DB Cluster Snapshot."
  value       = aws_neptune_cluster_snapshot.neptune_cluster_snapshot.db_cluster_snapshot_arn
}

output "neptune_snapshot_engine" {
  description = "Specifies the name of the database engine."
  value       = aws_neptune_cluster_snapshot.neptune_cluster_snapshot.engine
}

output "neptune_snapshot_engine_version" {
  description = "Version of the database engine for this DB cluster snapshot."
  value       = aws_neptune_cluster_snapshot.neptune_cluster_snapshot.engine_version
}

output "neptune_snapshot_kms_key_id" {
  description = "If storage_encrypted is true, the AWS KMS key identifier for the encrypted DB cluster snapshot."
  value       = aws_neptune_cluster_snapshot.neptune_cluster_snapshot.kms_key_id
}

output "neptune_snapshot_license_model" {
  description = "License model information for the restored DB cluster."
  value       = aws_neptune_cluster_snapshot.neptune_cluster_snapshot.license_model
}

output "neptune_snapshot_port" {
  description = "Port that the DB cluster was listening on at the time of the snapshot."
  value       = aws_neptune_cluster_snapshot.neptune_cluster_snapshot.port
}

output "neptune_snapshot_storage_encrypted" {
  description = "Specifies whether the DB cluster snapshot is encrypted."
  value       = aws_neptune_cluster_snapshot.neptune_cluster_snapshot.storage_encrypted
}

output "neptune_snapshot_status" {
  description = "The status of this DB Cluster Snapshot."
  value       = aws_neptune_cluster_snapshot.neptune_cluster_snapshot.status
}

output "neptune_snapshot_vpc_id" {
  description = "The VPC ID associated with the DB cluster snapshot."
  value       = aws_neptune_cluster_snapshot.neptune_cluster_snapshot.id
}

output "neptune_cluster_snapshot_all" {
  description = "A map of aws neptune cluster snapshot"
  value       = aws_neptune_cluster_snapshot.neptune_cluster_snapshot

}