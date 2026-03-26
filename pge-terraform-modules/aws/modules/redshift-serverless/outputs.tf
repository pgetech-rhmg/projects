# Namespace Outputs
output "namespace_arn" {
  description = "Amazon Resource Name (ARN) of the Redshift Serverless Namespace."
  value       = aws_redshiftserverless_namespace.this.arn
}

output "namespace_id" {
  description = "The Redshift Serverless Namespace ID."
  value       = aws_redshiftserverless_namespace.this.id
}

output "namespace_name" {
  description = "The Redshift Serverless Namespace Name."
  value       = aws_redshiftserverless_namespace.this.namespace_name
}

output "namespace_admin_username" {
  description = "The username of the administrator for the namespace."
  value       = aws_redshiftserverless_namespace.this.admin_username
}

output "namespace_db_name" {
  description = "The name of the first database created in the namespace."
  value       = aws_redshiftserverless_namespace.this.db_name
}

output "namespace_kms_key_id" {
  description = "The ARN of the KMS key used to encrypt the namespace."
  value       = aws_redshiftserverless_namespace.this.kms_key_id
}

output "namespace_iam_roles" {
  description = "List of IAM roles associated with the namespace."
  value       = aws_redshiftserverless_namespace.this.iam_roles
}

# Workgroup Outputs
output "workgroup_arn" {
  description = "Amazon Resource Name (ARN) of the Redshift Serverless Workgroup."
  value       = aws_redshiftserverless_workgroup.this.arn
}

output "workgroup_id" {
  description = "The Redshift Serverless Workgroup ID."
  value       = aws_redshiftserverless_workgroup.this.id
}

output "workgroup_name" {
  description = "The Redshift Serverless Workgroup Name."
  value       = aws_redshiftserverless_workgroup.this.workgroup_name
}

output "workgroup_endpoint" {
  description = "The endpoint that is created from the workgroup."
  value       = aws_redshiftserverless_workgroup.this.endpoint
}

output "workgroup_port" {
  description = "The port number on which the workgroup accepts incoming connections."
  value       = aws_redshiftserverless_workgroup.this.port
}

output "workgroup_base_capacity" {
  description = "The base data warehouse capacity of the workgroup in RPUs."
  value       = aws_redshiftserverless_workgroup.this.base_capacity
}

output "workgroup_subnet_ids" {
  description = "An array of VPC subnet IDs associated with the workgroup."
  value       = aws_redshiftserverless_workgroup.this.subnet_ids
}

output "workgroup_security_group_ids" {
  description = "An array of security group IDs associated with the workgroup."
  value       = aws_redshiftserverless_workgroup.this.security_group_ids
}
