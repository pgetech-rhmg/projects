output "codepipeline_id" {
  #  value       = aws_codepipeline.codepipeline.id
  value       = module.internal_container.codepipeline_id
  description = "The codepipeline ID"
}

output "codepipeline_arn" {
  value       = module.internal_container.codepipeline_arn
  description = "The codepipeline ARN"
}

output "codepipeline_tags_all" {
  value       = module.internal_container.codepipeline_tags_all
  description = "A map of tags assigned to the resource"
}

output "sns_arn" {
  value       = module.internal_container.sns_arn
  description = "sns arn"
}

output "lambda_arn" {
  value = module.internal_container.lambda_arn
}

output "codepipeline_all" {
  description = "Map of Codepipeline object"
  value       = module.internal_container.codepipeline_all
}
