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

output "codebuild_project_id" {
  description = "Name or ARN of the CodeBuild project"
  value       = module.codebuild_project.codebuild_project_id
}

output "codepipeline_all" {
  description = "Map of Codepipeline object"
  value       = aws_codepipeline.codepipeline
}
