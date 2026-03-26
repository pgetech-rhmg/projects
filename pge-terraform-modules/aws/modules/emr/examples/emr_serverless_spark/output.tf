output "spark_arn" {
  description = "Amazon Resource Name (ARN) of the application"
  value       = module.emr_serverless_spark.emr_serverless_arn
}

output "spark_id" {
  description = "ID of the application"
  value       = module.emr_serverless_spark.emr_serverless_id
}
