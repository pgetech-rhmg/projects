output "redshift_subnet_group_arn" {
  description = "Amazon Resource Name (ARN) of the Redshift Subnet group name"
  value       = aws_redshift_subnet_group.redshift_subnet_group.arn
}

output "redshift_subnet_group_id" {
  description = "The Redshift Subnet group ID."
  value       = aws_redshift_subnet_group.redshift_subnet_group.id
}

output "redshift_subnet_group_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = aws_redshift_subnet_group.redshift_subnet_group.tags_all
}

output "aws_redshift_subnet_group_all" {
  description = "A map of aws redshift subnet group attributes references"
  value       = aws_redshift_subnet_group.redshift_subnet_group

}