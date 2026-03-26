### Resources moves for tfc migration (remove in future version)

moved {
  from = aws_lambda_function.lambda_function
  to   = module.lambda.aws_lambda_function.lambda_function
}

moved {
  from = module.iam.aws_iam_role.lambda_role
  to   = module.lambda_role.aws_iam_role.default
}

moved {
  from = module.iam.aws_iam_policy.lambda_policy
  to   = module.lambda_policy.aws_iam_policy.default
}
