output "codebuild_report_arn" {
  description = "ARN of the CodeBuild Report Group"
  value       = aws_codebuild_report_group.codebuild_rg.arn
}

output "codebuild_report_created" {
  description = "The date and time this Report Group was created"
  value       = aws_codebuild_report_group.codebuild_rg.created
}

output "codebuild_report_tags_all" {
  description = "A map of tags assigned to the resource"
  value       = aws_codebuild_report_group.codebuild_rg.tags_all
}

output "codebuild_report_group" {
  description = "A map of codebuild report group"
  value       = aws_codebuild_report_group.codebuild_rg
}

output "codebuild_resource_policy" {
  description = "A map of codebuild resource policy"
  value       = aws_codebuild_resource_policy.codebuild_resource_policy
}