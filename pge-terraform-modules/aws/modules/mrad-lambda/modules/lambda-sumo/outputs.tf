#outputs for MRAD Lambda module

output "lambda_arn" {
  value = aws_lambda_function.lambda_function.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.lambda_function.invoke_arn
}

output "lambda_qualified_arn" {
  value = aws_lambda_function.lambda_function.qualified_arn
}

output "lambda_alias_invoke_arn" {
  value = module.lambda-mrad-alias.lambda_alias_invoke_arn
}

output "lambda_alias_arn" {
  value = module.lambda-mrad-alias.lambda_alias_arn
}

output "kms_key_arn" {
  value = var.kms_key_arn
}

output "lambda_function_name" {
  value = aws_lambda_function.lambda_function.function_name
}
