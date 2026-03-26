
# Outputs for dynamodb global table

output "dynamodb_global_table_arn" {
  description = "The ARN of the DynamoDB Global Table."
  value       = aws_dynamodb_global_table.dynamodb_global_table.arn
}

output "dynamodb_global_table_id" {
  description = "The name of the DynamoDB Global Table."
  value       = aws_dynamodb_global_table.dynamodb_global_table.id
}