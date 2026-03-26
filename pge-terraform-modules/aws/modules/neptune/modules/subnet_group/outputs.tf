#Outputs for subnet group
output "neptune_subnet_group_id" {
  description = "The neptune subnet group name"
  value       = aws_neptune_subnet_group.neptune_subnet_group.id
}

output "neptune_subnet_group_arn" {
  description = "The ARN of the neptune subnet group"
  value       = aws_neptune_subnet_group.neptune_subnet_group.arn
}

output "neptune_subnet_group_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_neptune_subnet_group.neptune_subnet_group.tags_all
}

output "neptune_subnet_group_all" {
  description = "A map of aws neptune subnet group"
  value       = aws_neptune_subnet_group.neptune_subnet_group
}