output "workgroup_name" {
  description = "Name of the Athena Workgroup created by this module."
  value       = aws_athena_workgroup.this.name
}

output "workgroup_arn" {
  description = "ARN of the Athena Workgroup, used for referencing and IAM permissions."
  value       = aws_athena_workgroup.this.arn
}
