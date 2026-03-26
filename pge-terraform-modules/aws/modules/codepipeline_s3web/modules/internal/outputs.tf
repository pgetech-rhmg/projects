output "codepipeline_id" {
  value       = aws_codepipeline.codepipeline.id
  description = "The codepipeline ID"
}

output "codepipeline_arn" {
  value       = aws_codepipeline.codepipeline.arn
  description = "The codepipeline ARN"
}


output "codepipeline_all" {
  description = "Map of Codepipeline object"
  value       = aws_codepipeline.codepipeline
}

output "codepipeline_tags_all" {
  value       = aws_codepipeline.codepipeline.tags_all
  description = "A map of tags assigned to the resource"
}

#####

# output "codepipeline_html_id" {
#   value       = var.codepipeline_type == "html" ? aws_codepipeline.codepipeline_html[0].id : null
#   description = "The codepipeline ID"
# }
# 
# output "codepipeline_html_arn" {
#   value       = var.codepipeline_type == "html" ? aws_codepipeline.codepipeline_html[0].arn : null
#   description = "The codepipeline ARN"
# }
# 
# 
# output "codepipeline_html_all" {
#   description = "Map of Codepipeline object"
#   value       = var.codepipeline_type == "html" ? aws_codepipeline.codepipeline_html : null
# }
# 
# output "codepipeline_html_tags_all" {
#   value       = var.codepipeline_type == "html" ? aws_codepipeline.codepipeline_html[0].tags_all : null
#   description = "A map of tags assigned to the resource"
# }

#####

output "s3_codepipeiline_artifact_id" {
  description = "The name of the bucket"
  value       = var.codepipeline_type != "custom" ? module.s3[0].id : var.artifact_store_location_bucket
}

output "s3_codepipeiline_artifact_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname"
  value       = var.codepipeline_type != "custom" ? module.s3[0].arn : var.artifact_store_location_bucket
}

output "iam_codepipeline_role_arn" {
  value       = var.codepipeline_type != "custom" ? module.codepipeline_iam_role[0].arn : var.codepipeline_role_arn
  description = "The Amazon Resource Name (ARN) specifying the role"
}

output "sg_codebuild_id" {
  description = "security group id"
  value       = module.security-group.sg_id
}

output "iam_codebuild_role_arn" {
  value       = var.codebuild_source_buildspec != null ? module.codebuild_iam_role[0].arn : null
  description = "The Amazon Resource Name (ARN) specifying the role"
}

output "iam_codescan_role_arn" {
  value       = module.codescan_iam_role.arn
  description = "The Amazon Resource Name (ARN) specifying the role"
}

output "iam_codepublish_role_arn" {
  value       = module.codepublish_iam_role.arn
  description = "The Amazon Resource Name (ARN) specifying the role"
}

output "codebuild_build_project_id" {
  description = "Name or ARN of the CodeBuild project"
  value       = var.codebuild_source_buildspec != null ? module.codebuild_project[0].codebuild_project_id : null
}

output "codebuild_codescan_project_id" {
  description = "Name or ARN of the CodeScan project"
  value       = module.codebuild_codescan.codebuild_project_id
}

output "codebuild_codepublish_project_id" {
  description = "Name or ARN of the CodePublish project"
  value       = module.codebuild_codepublish.codebuild_project_id
}

