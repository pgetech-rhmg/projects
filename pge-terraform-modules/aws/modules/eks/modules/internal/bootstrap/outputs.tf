# output "codepipeline_id" {
#   value       = aws_codepipeline.codepipeline.id
#   description = "The codepipeline ID"
# }

# output "codepipeline_arn" {
#   value       = aws_codepipeline.codepipeline.arn
#   description = "The codepipeline ARN"
# }

# output "codepipeline_tags_all" {
#   value       = aws_codepipeline.codepipeline.tags_all
#   description = "A map of tags assigned to the resource"
# }

# output "codepipeline_all" {
#   description = "Map of Codepipeline object"
#   value       = aws_codepipeline.codepipeline
# }

# output "codepipeline_iam_role_arn" {
#   value       = module.codepipeline_iam_role.arn
#   description = "The codepipeline IAM role ARN"
# }

output "codebuild_iam_role_arn" {
  value       = module.codebuild_iam_role.arn
  description = "The codebuild IAM role ARN"
}