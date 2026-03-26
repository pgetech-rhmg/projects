#outputs for documentdb snapshot
output "aws_docdb_cluster_snapshot" {
  description = "The entire output of the aws_docdb_cluster_snapshot resource"
  value       = aws_docdb_cluster_snapshot.docdb_cluster_snapshot
}
output "availability_zones" {
  description = "List of EC2 Availability Zones that instances in the DocDB cluster snapshot can be restored in."
  value       = aws_docdb_cluster_snapshot.docdb_cluster_snapshot.availability_zones
}

output "db_cluster_snapshot_arn" {
  description = "The Amazon Resource Name (ARN) for the DocDB Cluster Snapshot."
  value       = aws_docdb_cluster_snapshot.docdb_cluster_snapshot.db_cluster_snapshot_arn
}

output "engine" {
  description = "Specifies the name of the database engine."
  value       = aws_docdb_cluster_snapshot.docdb_cluster_snapshot.engine
}

output "engine_version" {
  description = "Version of the database engine for this DocDB cluster snapshot."
  value       = aws_docdb_cluster_snapshot.docdb_cluster_snapshot.engine_version
}

output "kms_key_id" {
  description = "If storage_encrypted is true, the AWS KMS key identifier for the encrypted DocDB cluster snapshot."
  value       = aws_docdb_cluster_snapshot.docdb_cluster_snapshot.kms_key_id
}

output "port" {
  description = "Port that the DocDB cluster was listening on at the time of the snapshot."
  value       = aws_docdb_cluster_snapshot.docdb_cluster_snapshot.port
}

output "storage_encrypted" {
  description = "Specifies whether the DocDB cluster snapshot is encrypted."
  value       = aws_docdb_cluster_snapshot.docdb_cluster_snapshot.storage_encrypted
}

output "status" {
  description = "The status of this DocDB Cluster Snapshot."
  value       = aws_docdb_cluster_snapshot.docdb_cluster_snapshot.status
}

output "vpc_id" {
  description = "The VPC ID associated with the DocDB cluster snapshot."
  value       = aws_docdb_cluster_snapshot.docdb_cluster_snapshot.vpc_id
}