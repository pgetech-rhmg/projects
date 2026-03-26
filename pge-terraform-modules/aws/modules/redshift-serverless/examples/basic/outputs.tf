output "namespace_arn" {
  description = "ARN of the Redshift Serverless namespace"
  value       = module.redshift_serverless.namespace_arn
}

output "namespace_id" {
  description = "ID of the Redshift Serverless namespace"
  value       = module.redshift_serverless.namespace_id
}

output "namespace_name" {
  description = "Name of the Redshift Serverless namespace"
  value       = module.redshift_serverless.namespace_name
}

output "workgroup_arn" {
  description = "ARN of the Redshift Serverless workgroup"
  value       = module.redshift_serverless.workgroup_arn
}

output "workgroup_id" {
  description = "ID of the Redshift Serverless workgroup"
  value       = module.redshift_serverless.workgroup_id
}

output "workgroup_endpoint" {
  description = "Endpoint of the Redshift Serverless workgroup"
  value       = module.redshift_serverless.workgroup_endpoint
}

output "workgroup_port" {
  description = "Port of the Redshift Serverless workgroup"
  value       = module.redshift_serverless.workgroup_port
}

output "admin_password" {
  description = "Admin password (sensitive)"
  value       = random_password.redshift_password.result
  sensitive   = true
}

output "security_group_id" {
  description = "Security group ID for Redshift Serverless"
  value       = module.security_group_redshift.sg_id
}

output "iam_role_arn" {
  description = "IAM role ARN for Redshift Serverless"
  value       = module.redshift_iam_role.arn
}
