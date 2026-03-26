#outputs for MRAD Lambda module

output "lambda_arn" {
  value = module.lambda-mrad.lambda_arn
}

output "lambda_invoke_arn" {
  value = module.lambda-mrad.lambda_invoke_arn
}

output "lambda_qualified_arn" {
  value = module.lambda-mrad.lambda_qualified_arn
}

output "lambda_alias_invoke_arn" {
  value = module.lambda-mrad-alias.lambda_alias_invoke_arn
}

output "lambda_alias_arn" {
  value = module.lambda-mrad-alias.lambda_alias_arn
}

output "kms_key_arn" {
  value = module.kms_key.key_arn
}
