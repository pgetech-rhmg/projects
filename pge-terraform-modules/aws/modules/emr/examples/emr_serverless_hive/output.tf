output "hive_arn" {
  description = "Amazon Resource Name (ARN) of the application"
  value       = module.emr_serverless_hive.emr_serverless_arn
}

output "hive_id" {
  description = "ID of the application"
  value       = module.emr_serverless_hive.emr_serverless_id
}
