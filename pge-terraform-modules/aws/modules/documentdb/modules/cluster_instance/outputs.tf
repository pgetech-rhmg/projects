output "docdb_cluster_instance_engine" {
  value       = aws_docdb_cluster_instance.cluster_instance[*]
  description = "The database engine."
}

output "docdb_cluster_instance_arn" {
  value       = aws_docdb_cluster_instance.cluster_instance[*].arn
  description = "Amazon Resource Name (ARN) of cluster instance."
}

output "docdb_cluster_instance_db_subnet_group_name" {
  value       = aws_docdb_cluster_instance.cluster_instance[*].db_subnet_group_name
  description = "The DB subnet group to associate with this DB instance."
}

output "docdb_cluster_instance_dbi_resource_id" {
  value       = aws_docdb_cluster_instance.cluster_instance[*].dbi_resource_id
  description = "The region-unique, immutable identifier for the DB instance."
}

output "docdb_cluster_instance_endpoint" {
  value       = aws_docdb_cluster_instance.cluster_instance[*].endpoint
  description = "The DNS address for this instance. May not be writable."
}

output "docdb_cluster_instance_engine_version" {
  value       = aws_docdb_cluster_instance.cluster_instance[*].engine_version
  description = "The database engine version."
}

output "docdb_cluster_instance_kms_key_id" {
  value       = aws_docdb_cluster_instance.cluster_instance[*].kms_key_id
  description = "The ARN for the KMS encryption key if one is set to the cluster."
}

output "docdb_cluster_instance_port" {
  value       = aws_docdb_cluster_instance.cluster_instance[*].port
  description = "The database port."
}

output "docdb_cluster_instance_preferred_backup_window" {
  value       = aws_docdb_cluster_instance.cluster_instance[*].preferred_backup_window
  description = "The daily time range during which automated backups are created if automated backups are enabled."
}

output "docdb_cluster_instance_storage_encrypted" {
  value       = aws_docdb_cluster_instance.cluster_instance[*].storage_encrypted
  description = "Specifies whether the DB cluster is encrypted."
}

output "docdb_cluster_instance_tags_all" {
  value       = aws_docdb_cluster_instance.cluster_instance[*].tags_all
  description = "A map of tags assigned to the resource."
}

output "docdb_cluster_instance_writer" {
  value       = aws_docdb_cluster_instance.cluster_instance[*].writer
  description = "Boolean indicating if this instance is writable. False indicates this instance is a read replica."
}

output "docdb_cluster_instance_ca_cert_identifier" {
  value       = aws_docdb_cluster_instance.cluster_instance[*].ca_cert_identifier
  description = "The identifier of the CA certificate for the DB instance."
}

