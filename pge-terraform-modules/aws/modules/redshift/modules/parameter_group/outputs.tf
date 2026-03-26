output "parameter_group_arn" {
  description = "Amazon Resource Name (ARN) of parameter group."
  value       = aws_redshift_parameter_group.parameter-group.arn
}

output "parameter_group_id" {
  description = "The Redshift parameter group name."
  value       = aws_redshift_parameter_group.parameter-group.id
}

output "aws_redshift_parameter_group_all" {
  description = "A map of aws redshift parameter group resource attributes references"
  value       = aws_redshift_parameter_group.parameter-group

}