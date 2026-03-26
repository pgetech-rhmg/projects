#Outputs for cluster parameter group

output "documentdb_cluster_parameter_group" {
  description = "The documentDB cluster parameter group."
  value       = aws_docdb_cluster_parameter_group.docdb_cluster_parameter_group
}

output "documentdb_cluster_parameter_group_id" {
  description = "The documentDB cluster parameter group name."
  value       = aws_docdb_cluster_parameter_group.docdb_cluster_parameter_group.id
}

output "documentdb_cluster_parameter_group_arn" {
  description = "The ARN of the documentDB cluster parameter group."
  value       = aws_docdb_cluster_parameter_group.docdb_cluster_parameter_group.arn
}

output "documentdb_cluster_parameter_group_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_docdb_cluster_parameter_group.docdb_cluster_parameter_group.tags_all
}