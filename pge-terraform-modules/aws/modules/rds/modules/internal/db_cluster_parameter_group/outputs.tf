output "db_cluster_parameter_group_id" {
  description = "The db cluster parameter group id."
  value       = element(concat(aws_rds_cluster_parameter_group.this[*].id, [""]), 0)
}

output "db_cluster_parameter_group_arn" {
  description = "The ARN of the db cluster parameter group."
  value       = element(concat(aws_rds_cluster_parameter_group.this[*].arn, [""]), 0)
}

output "db_cluster_parameter_group_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = element(concat(aws_rds_cluster_parameter_group.this[*].tags, [""]), 0)
}

output "db_cluster_parameter_group_name" {
  description = "Name of the db cluster parameter group."
  value       = element(concat(aws_rds_cluster_parameter_group.this[*].name, [""]), 0)
}