moved {
  from = aws_s3_bucket_policy.ssl_only_policy
  to   = module.s3.aws_s3_bucket_policy.default
}

moved {
  from = aws_codepipeline.pipeline
  to   = aws_codepipeline.codepipeline
}

moved {
  from = module.iam.aws_iam_role.codepipeline_role
  to   = module.codepipeline_iam_role.aws_iam_role.default
}

moved {
  from = aws_s3_bucket_public_access_block.pipeline_bucket_access
  to   = module.s3.aws_s3_bucket_public_access_block.default
}
