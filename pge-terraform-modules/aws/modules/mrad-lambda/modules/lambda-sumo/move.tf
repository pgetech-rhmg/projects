### Resources moves for tfc migration (remove in future version)

moved {
  from = aws_s3_bucket.s3
  to   = module.lambda-s3.aws_s3_bucket.default
}

moved {
  from = module.iam.aws_iam_role.lambda_role
  to   = module.lambda_iam_role.aws_iam_role.default
}

moved {
  from = aws_cloudwatch_log_group.lambda_log_group
  to   = module.log_group.aws_cloudwatch_log_group.this[0]
}

moved {
  from = module.log_group.aws_cloudwatch_log_group.this[0]
  to   = module.log_group.aws_cloudwatch_log_group.this
}

moved {
  from = aws_lambda_alias.lambda_function_alias
  to   = module.lambda-mrad-alias.aws_lambda_alias.lambda_alias
}

moved {
  from = aws_s3_bucket_policy.ssl_only_policy
  to   = module.lambda-s3.aws_s3_bucket_policy.default
}

moved {
  from = aws_s3_bucket_public_access_block.s3_access
  to   = module.lambda-s3.aws_s3_bucket_public_access_block.default
}

moved {
  from = module.iam.aws_iam_policy.lambda_policy
  to   = module.lambda_iam_policy.aws_iam_policy.default
}

# State migration for rc14 -> rc15 upgrade (module.kms_key -> module.kms_key[0])
moved {
  from = module.kms_key
  to   = module.kms_key[0]
}
