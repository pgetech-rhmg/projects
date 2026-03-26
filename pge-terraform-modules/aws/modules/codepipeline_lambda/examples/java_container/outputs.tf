################################################################################
# CodePipeline Outputs
################################################################################

output "codepipeline_id" {
  description = "The ID of the CodePipeline"
  value       = module.codepipeline.codepipeline_id
}

output "codepipeline_arn" {
  description = "The ARN of the CodePipeline"
  value       = module.codepipeline.codepipeline_arn
}



################################################################################
# Lambda Function Outputs
################################################################################

# output "lambda_function_name" {
#   description = "The name of the Lambda function"
#   value       = module.lambda_function.function_name
# }

# output "lambda_function_arn" {
#   description = "The ARN of the Lambda function"
#   value       = module.lambda_function.arn
# }