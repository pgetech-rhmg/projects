output "git_branch" {
  value       = var.git_branch
  description = "The branch of the queries repository to build and deploy"
}

output "pipeline_name" {
  value       = aws_codepipeline.pipeline.name
  sensitive   = false
  description = "The full pipeline name as created by the module"
}
