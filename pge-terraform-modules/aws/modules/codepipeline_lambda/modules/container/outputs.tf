output "codepipeline_id" {
  value       = module.internal_lambda.codepipeline_id
  description = "The codepipeline ID"
}

output "codepipeline_arn" {
  value       = module.internal_lambda.codepipeline_arn
  description = "The codepipeline ARN"
}

output "codepipeline_all" {
  description = "Map of Codepipeline object"
  value       = module.internal_lambda
}