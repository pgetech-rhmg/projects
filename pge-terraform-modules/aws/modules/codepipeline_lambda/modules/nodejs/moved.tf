moved {
  from = aws_codepipeline.codepipeline
  to   = module.internal_lambda.aws_codepipeline.codepipeline
}

moved {
  from = module.codebuild_codepublish.aws_codebuild_project.codebuild_project
  to   = module.internal_lambda.module.codebuild_codepublish.aws_codebuild_project.codebuild_project
}

moved {
  from = module.codebuild_codepublish.aws_codebuild_resource_policy.codebuild_resource_policy
  to   = module.internal_lambda.module.codebuild_codepublish.aws_codebuild_resource_policy.codebuild_resource_policy
}

moved {
  from = module.codebuild_codescan.aws_codebuild_project.codebuild_project
  to   = module.internal_lambda.module.codebuild_codescan.aws_codebuild_project.codebuild_project
}

moved {
  from = module.codebuild_codescan.aws_codebuild_resource_policy.codebuild_resource_policy
  to   = module.internal_lambda.module.codebuild_codescan.aws_codebuild_resource_policy.codebuild_resource_policy
}

moved {
  from = module.codebuild_iam_role.aws_iam_role.default
  to   = module.internal_lambda.module.codebuild_iam_role.aws_iam_role.default
}

moved {
  from = module.codebuild_iam_role.aws_iam_role_policy.role_policy[0]
  to   = module.internal_lambda.module.codebuild_iam_role.aws_iam_role_policy.role_policy[0]
}

moved {
  from = module.codebuild_project.aws_codebuild_project.codebuild_project
  to   = module.internal_lambda.module.codebuild_project.aws_codebuild_project.codebuild_project
}

moved {
  from = module.codebuild_project.aws_codebuild_resource_policy.codebuild_resource_policy
  to   = module.internal_lambda.module.codebuild_project.aws_codebuild_resource_policy.codebuild_resource_policy
}

moved {
  from = module.codepublish_iam_role.aws_iam_role.default
  to   = module.internal_lambda.module.codepublish_iam_role.aws_iam_role.default
}

moved {
  from = module.codescan_iam_role.aws_iam_role.default
  to   = module.internal_lambda.module.codescan_iam_role.aws_iam_role.default
}

moved {
  from = module.codescan_iam_role.aws_iam_role_policy.role_policy[0]
  to   = module.internal_lambda.module.codescan_iam_role.aws_iam_role_policy.role_policy[0]
}

moved {
  from = module.security-group.aws_security_group.default
  to   = module.internal_lambda.module.security-group.aws_security_group.default
}

moved {
  from = module.security-group.aws_security_group_rule.cidr_egress["CCOE egress rules 0 0 -1}"]
  to   = module.internal_lambda.module.security-group.aws_security_group_rule.cidr_egress["CCOE egress rules 0 0 -1}"]
}

moved {
  from = module.codebuild_codepublish.aws_codebuild_source_credential.codebuild_source_credential
  to   = module.internal_lambda.module.codebuild_codepublish.aws_codebuild_source_credential.codebuild_source_credential
}

moved {
  from = module.codebuild_codescan.aws_codebuild_source_credential.codebuild_source_credential
  to   = module.internal_lambda.module.codebuild_codescan.aws_codebuild_source_credential.codebuild_source_credential
}

moved {
  from = module.codebuild_project.aws_codebuild_source_credential.codebuild_source_credential
  to   = module.internal_lambda.module.codebuild_project.aws_codebuild_source_credential.codebuild_source_credential
}

moved {
  from = module.codepublish_iam_role.aws_iam_role_policy.role_policy
  to   = module.internal_lambda.module.codepublish_iam_role.aws_iam_role_policy.role_policy
}
