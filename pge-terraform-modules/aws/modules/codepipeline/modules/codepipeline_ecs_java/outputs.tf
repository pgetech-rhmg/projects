output "codepipeline_id" {
  value       = aws_codepipeline.codepipeline.id
  description = "The codepipeline ID"
}

output "codepipeline_arn" {
  value       = aws_codepipeline.codepipeline.arn
  description = "The codepipeline ARN"
}

output "codepipeline_tags_all" {
  value       = aws_codepipeline.codepipeline.tags_all
  description = "A map of tags assigned to the resource"
}

output "sns_arn" {
  value       = module.codestar-notifications.sns_arn
  description = "sns arn"
}

output "lambda_arn" {
  value = module.codestar-notifications.lambda_arn
}

output "codepipeline_all" {
  description = "Map of Codepipeline object"
  value       = aws_codepipeline.codepipeline
}