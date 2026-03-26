output "codepipeline_id" {
  value       = module.codepipeline.codepipeline_id
  description = "The codepipeline ID"
}

output "codepipeline_arn" {
  value       = module.codepipeline.codepipeline_arn
  description = "The codepipeline ARN"
}

output "codepipeline_bucket" {
  value       = module.s3.id
  description = "codepipeline bucket name"
}

output "s3_id" {
  description = "The name of the bucket"
  value       = module.s3.id
}

output "s3_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname"
  value       = module.s3.arn
}

output "codepipeline_iam_role" {
  description = "Map of IAM Role object"
  value       = module.codepipeline_iam_role.iam_role
}

output "codepipeline_iam_role_name" {
  value       = join("", module.codepipeline_iam_role.iam_role[*].name)
  description = "The name of the IAM role created"
}

output "codepipeline_iam_role_arn" {
  value       = join("", module.codepipeline_iam_role.iam_role[*].arn)
  description = "The Amazon Resource Name (ARN) specifying the role"
}

output "security-group-codebuild_arn" {
  description = "security group id"
  value       = module.security-group-codebuild.sg_arn
}

