output "lambda_alias_arn" {
  value       = aws_lambda_alias.lambda_alias.arn
  description = "The Amazon Resource Name (ARN) identifying your Lambda function alias"
}

output "lambda_alias_invoke_arn" {
  value       = aws_lambda_alias.lambda_alias.invoke_arn
  description = "The ARN to be used for invoking Lambda Function from API Gateway - to be used in aws_api_gateway_integration's uri"
}

output "lambda_alias_all" {
  value       = aws_lambda_alias.lambda_alias
  description = "Map of all Lambda object"
}