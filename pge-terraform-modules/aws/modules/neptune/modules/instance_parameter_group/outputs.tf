#outputs for instance parameter group
output "neptune_instance_parameter_group_id" {
  description = "The Neptune parameter group name"
  value       = aws_neptune_parameter_group.instance_parameter_group.id
}

output "neptune_instance_parameter_group_arn" {
  description = "The Neptune parameter group Amazon Resource Name (ARN)"
  value       = aws_neptune_parameter_group.instance_parameter_group.arn
}

output "neptune_instance_parameter_group_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block"
  value       = aws_neptune_parameter_group.instance_parameter_group.tags_all
}

output "neptune_parameter_group_all" {
  description = "A map of aws neptune parameter group"
  value       = aws_neptune_parameter_group.instance_parameter_group

}