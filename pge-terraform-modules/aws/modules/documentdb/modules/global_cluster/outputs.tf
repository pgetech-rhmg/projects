#outputs for global cluster for new cluster
output "arn" {
  description = "Global Cluster Amazon Resource Name (ARN)"
  value       = try(aws_docdb_global_cluster.global_cluster[0].arn, "")
}

output "global_cluster_members" {
  description = "Set of objects containing Global Cluster members."
  value       = try(aws_docdb_global_cluster.global_cluster[0].global_cluster_members, "")
}

output "global_cluster_resource_id" {
  description = "AWS Region-unique, immutable identifier for the global database cluster. This identifier is found in AWS CloudTrail log entries whenever the AWS KMS key for the DB cluster is accessed."
  value       = try(aws_docdb_global_cluster.global_cluster[0].global_cluster_resource_id, "")
}

output "id" {
  description = "Attribute provides DocDB Global Cluster identifier that is created."
  value       = try(aws_docdb_global_cluster.global_cluster[0].id, "")
}

#outputs for global cluster for existing cluster
output "arn_for_existing_cluster" {
  description = "Global Cluster Amazon Resource Name (ARN)"
  value       = try(aws_docdb_global_cluster.global_cluster_for_existing_cluster[0].arn, "")
}

output "global_cluster_members_for_existing_cluster" {
  description = "Set of objects containing Global Cluster members."
  value       = try(aws_docdb_global_cluster.global_cluster_for_existing_cluster[0].global_cluster_members, "")
}

output "global_cluster_resource_id_for_existing_cluster" {
  description = "AWS Region-unique, immutable identifier for the global database cluster. This identifier is found in AWS CloudTrail log entries whenever the AWS KMS key for the DB cluster is accessed."
  value       = try(aws_docdb_global_cluster.global_cluster_for_existing_cluster[0].global_cluster_resource_id, "")
}

output "id_for_existing_cluster" {
  description = "Attribute provides DocDB Global Cluster identifier that is created."
  value       = try(aws_docdb_global_cluster.global_cluster_for_existing_cluster[0].id, "")
}