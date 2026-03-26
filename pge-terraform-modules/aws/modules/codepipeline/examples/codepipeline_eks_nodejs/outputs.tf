output "codepipeline_id" {
  value       = module.codepipeline.codepipeline_id
  description = "The codepipeline ID"
}
output "codepipeline_arn" {
  value       = module.codepipeline.codepipeline_arn
  description = "The codepipeline ARN"
}

output "codepipeline_bucket" {
  value       = module.s3.id
  description = "codepipeline bucket name"
}

output "sns_arn" {
  value = module.codepipeline.sns_arn
}

output "lambda_arn" {
  value = module.codepipeline.lambda_arn
}



