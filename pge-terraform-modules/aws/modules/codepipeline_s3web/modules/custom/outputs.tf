# output "codepipeline_id" {
#   value       = aws_codepipeline.codepipeline.id
#   description = "The codepipeline ID"
# }
# 
# output "codepipeline_arn" {
#   value       = aws_codepipeline.codepipeline.arn
#   description = "The codepipeline ARN"
# }
# 
# output "codepipeline_tags_all" {
#   value       = aws_codepipeline.codepipeline.tags_all
#   description = "A map of tags assigned to the resource"
# }
# 
# output "codebuild_project_id" {
#   description = "Name or ARN of the CodeBuild project"
#   value       = module.codebuild_project.codebuild_project_id
# }
# 
# output "codepipeline_all" {
#   description = "Map of Codepipeline object"
#   value       = aws_codepipeline.codepipeline
# }

output "codepipeline_id" {
  value       = module.internal_s3web.codepipeline_id
  description = "The codepipeline ID"
}

output "codepipeline_arn" {
  value       = module.internal_s3web.codepipeline_arn
  description = "The codepipeline ARN"
}

output "codepipeline_all" {
  description = "Map of Codepipeline object"
  value       = module.internal_s3web.codepipeline_all
}

output "codepipeline_tags_all" {
  value       = module.internal_s3web.codepipeline_tags_all
  description = "A map of tags assigned to the resource"
}

output "s3_codepipeiline_artifact_id" {
  description = "The name of the bucket"
  value       = module.internal_s3web.s3_codepipeiline_artifact_id
}

output "s3_codepipeiline_artifact_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname"
  value       = module.internal_s3web.s3_codepipeiline_artifact_arn
}


output "iam_codepipeline_role_arn" {
  value       = module.internal_s3web.iam_codepipeline_role_arn
  description = "The Amazon Resource Name (ARN) specifying the role"
}

output "sg_codebuild_id" {
  description = "security group id"
  value       = module.internal_s3web.sg_codebuild_id
}

output "iam_codebuild_role_arn" {
  value       = module.internal_s3web.iam_codebuild_role_arn
  description = "The Amazon Resource Name (ARN) specifying the role"
}

output "iam_codescan_role_arn" {
  value       = module.internal_s3web.iam_codescan_role_arn
  description = "The Amazon Resource Name (ARN) specifying the role"
}

output "iam_codepublish_role_arn" {
  value       = module.internal_s3web.iam_codepublish_role_arn
  description = "The Amazon Resource Name (ARN) specifying the role"
}

output "codebuild_build_project_id" {
  description = "Name or ARN of the CodeBuild project"
  value       = module.internal_s3web.codebuild_build_project_id
}

output "codebuild_codescan_project_id" {
  description = "Name or ARN of the CodeBuild project"
  value       = module.internal_s3web.codebuild_codescan_project_id
}

output "codebuild_codepublish_project_id" {
  description = "Name or ARN of the CodeBuild project"
  value       = module.internal_s3web.codebuild_codepublish_project_id
}
