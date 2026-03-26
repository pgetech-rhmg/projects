output "emr_serverless_arn" {
  description = "Amazon Resource Name (ARN) of the application"
  value       = aws_emrserverless_application.this.arn
}

output "emr_serverless_id" {
  description = "ID of the application"
  value       = aws_emrserverless_application.this.id
}
