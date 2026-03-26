output "codebuild_report_arn" {
  description = "ARN of the CodeBuild Report Group"
  value       = module.codebuild_report_group.codebuild_report_arn
}

output "codebuild_report_created" {
  description = "The date and time this Report Group was created"
  value       = module.codebuild_report_group.codebuild_report_created
}

output "codebuild_report_tags_all" {
  description = "A map of tags assigned to the resource"
  value       = module.codebuild_report_group.codebuild_report_tags_all
}