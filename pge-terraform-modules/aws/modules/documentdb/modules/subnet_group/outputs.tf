output "docdb_subnet_group" {
  description = "The docdb subnet group resource output."
  value       = aws_docdb_subnet_group.subnet_group
}

output "docdb_subnet_group_id" {
  description = "The docdb subnet group name."
  value       = aws_docdb_subnet_group.subnet_group.id
}

output "docdb_subnet_group_arn" {
  description = "The ARN of the docdb subnet group."
  value       = aws_docdb_subnet_group.subnet_group.arn
}

output "docdb_subnet_group_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = aws_docdb_subnet_group.subnet_group.tags_all
}
