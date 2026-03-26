output "codebuild_project_arn" {
  description = "ARN of the CodeBuild project"
  value       = aws_codebuild_project.codebuild_project.arn
}

output "codebuild_project_badge_url" {
  description = "URL of the build badge when badge_enabled is enabled"
  value       = aws_codebuild_project.codebuild_project.badge_url
}

output "codebuild_project_id" {
  description = "Name or ARN of the CodeBuild project"
  value       = aws_codebuild_project.codebuild_project.id
}

output "codebuild_project_project_alias" {
  description = "The project identifier used with the public build APIs"
  value       = aws_codebuild_project.codebuild_project.public_project_alias
}

output "codebuild_project_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider"
  value       = aws_codebuild_project.codebuild_project.tags_all
}

output "codebuild_resource_policy" {
  description = "Map of codebuild resource policy"
  value       = aws_codebuild_resource_policy.codebuild_resource_policy
}

output "codebuild_project" {
  description = "Map of codebuild project"
  value       = aws_codebuild_project.codebuild_project
}

output "codescan_buildspec_python" {
  description = "The codescan python buildspec file"
  value       = data.local_file.codescan_buildspec_python.content
}

output "codescan_buildspec_nodejs" {
  description = "The codescan nodejs buildspec file"
  value       = data.local_file.codescan_buildspec_nodejs.content
}

output "codescan_buildspec_dotnet" {
  description = "The codescan dotnet buildspec file"
  value       = data.local_file.codescan_buildspec_dotnet.content
}

output "codescan_buildspec_java" {
  description = "The codescan java buildspec file"
  value       = data.local_file.codescan_buildspec_java.content
}

output "codepublish_buildspec_python" {
  description = "The codepublish python buildspec file"
  value       = data.local_file.codepublish_buildspec_python.content
}

output "codepublish_buildspec_nodejs" {
  description = "The codepublish nodejs buildspec file"
  value       = data.local_file.codepublish_buildspec_nodejs.content
}

output "codepublish_buildspec_dotnet" {
  description = "The codepublish dotnet buildspec file"
  value       = data.local_file.codepublish_buildspec_dotnet.content
}

output "codepublish_buildspec_java" {
  description = "The codepublish java buildspec file"
  value       = data.local_file.codepublish_buildspec_java.content
}

output "getartifact_buildspec_java" {
  description = "The codepublish java buildspec file"
  value       = data.local_file.getartifact_buildspec_java.content
}

output "getartifact_buildspec_dotnet" {
  description = "The codepublish dotnet buildspec file"
  value       = data.local_file.getartifact_buildspec_dotnet.content
}

output "getartifact_buildspec_nodejs" {
  description = "The codepublish nodejs buildspec file"
  value       = data.local_file.getartifact_buildspec_nodejs.content
}

output "secretscan_buildspec_container" {
  description = "The secretscan buildspec file for container"
  value       = data.local_file.secretscan_buildspec_container.content
}

output "wizscan_buildspec_container_python" {
  description = "The wizscan python buildspec file for container"
  value       = data.local_file.wizscan_buildspec_container_python.content
}

output "wizscan_buildspec_container_nodejs" {
  description = "The wizscan nodejs buildspec file for container"
  value       = data.local_file.wizscan_buildspec_container_nodejs.content
}

output "wizscan_buildspec_container_java" {
  description = "The wizscan java buildspec file for container"
  value       = data.local_file.wizscan_buildspec_container_java.content
}

# Windows-specific buildspec outputs for .NET
output "codescan_buildspec_dotnet_windows" {
  description = "The codescan dotnet Windows buildspec file"
  value       = data.local_file.codescan_buildspec_dotnet_windows.content
}

output "codepublish_buildspec_dotnet_windows" {
  description = "The codepublish dotnet Windows buildspec file"
  value       = data.local_file.codepublish_buildspec_dotnet_windows.content
}
output "codescan_buildspec_java_lambda_container" {
  description = "The codescan container (Java Lambda) buildspec file"
  value       = data.local_file.codescan_buildspec_java_lambda_container.content
}
output "codepublish_buildspec_java_lambda_container" {
  description = "The codepublish container (Java Lambda) buildspec file"
  value       = data.local_file.codepublish_buildspec_java_lambda_container.content
}