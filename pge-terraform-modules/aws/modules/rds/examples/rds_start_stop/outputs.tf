output "rds_start_stop_module_id" {
  value       = module.rds_start_stop
  description = "Map of values of the rds_start_stop module"
}

output "vpc_endpoint_rds_id" {
  value       = module.vpc_endpoint_rds
  description = "Map of values of the vpc_endpoint_rds module id"
}

output "iam_role_rds_auto_start_stop_arn" {
  value       = module.iam_role_rds_auto_start_stop
  description = "Map of values of the iam_role_rds_auto_start_stop module arn"
}

output "security_group_lambda_id" {
  value       = module.security_group_lambda
  description = "Map of values of the security_group_lambda module id"
  sensitive   = true
}