output "neptune_cluster_parameter_group_id" {
  description = "The neptune cluster parameter group name."
  value       = aws_neptune_cluster_parameter_group.neptune_cluster_parameter_group.id
}

output "neptune_cluster_parameter_group_arn" {
  description = "The ARN of the neptune cluster parameter group"
  value       = aws_neptune_cluster_parameter_group.neptune_cluster_parameter_group.arn
}

output "neptune_cluster_parameter_group_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block"
  value       = aws_neptune_cluster_parameter_group.neptune_cluster_parameter_group.tags_all
}

output "neptune_cluster_parameter_group_all" {
  description = "A map of aws neptune cluster parameter group"
  value       = aws_neptune_cluster_parameter_group.neptune_cluster_parameter_group

}