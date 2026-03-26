# Outputs of AppSync Function

output "id" {
  description = "API Function ID (Formatted as ApiId-FunctionId)"
  value       = aws_appsync_function.function.id
}

output "function_arn" {
  description = "ARN of the Function object."
  value       = aws_appsync_function.function.arn
}

output "function_id" {
  description = "Unique ID representing the Function object."
  value       = aws_appsync_function.function.function_id
}

output "aws_appsync_function_all" {
  description = "Map of aws_appsync_function object."
  value       = aws_appsync_function.function
}