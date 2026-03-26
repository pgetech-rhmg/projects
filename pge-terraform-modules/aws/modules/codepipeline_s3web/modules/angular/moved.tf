moved {
  from = module.s3.aws_s3_bucket.default
  to   = module.internal_s3web.module.s3.aws_s3_bucket.default
}

moved {
  from = module.codepipeline_iam_role.aws_iam_role.default
  to   = module.internal_s3web.module.codepipeline_iam_role.aws_iam_role.default
}

moved {
  from = module.codepipeline_iam_role.aws_iam_role_policy.role_policy[0]
  to   = module.internal_s3web.module.codepipeline_iam_role.aws_iam_role_policy.role_policy[0]
}

moved {
  from = module.s3.aws_s3_bucket_acl.default
  to   = module.internal_s3web.module.s3.aws_s3_bucket_acl.default
}

moved {
  from = module.s3.aws_s3_bucket_ownership_controls.default
  to   = module.internal_s3web.module.s3.aws_s3_bucket_ownership_controls.default
}

moved {
  from = module.s3.aws_s3_bucket_policy.default
  to   = module.internal_s3web.module.s3.aws_s3_bucket_policy.default
}

moved {
  from = module.s3.aws_s3_bucket_public_access_block.default
  to   = module.internal_s3web.module.s3.aws_s3_bucket_public_access_block.default
}

moved {
  from = module.s3.aws_s3_bucket_server_side_encryption_configuration.default
  to   = module.internal_s3web.module.s3.aws_s3_bucket_server_side_encryption_configuration.default
}

moved {
  from = module.s3.aws_s3_bucket_versioning.default
  to   = module.internal_s3web.module.s3.aws_s3_bucket_versioning.default
}

moved {
  from = module.codepublish_iam_role.aws_iam_role.default
  to   = module.internal_s3web.module.codepublish_iam_role.aws_iam_role.default
}

moved {
  from = module.codepublish_iam_role.aws_iam_role_policy.role_policy[0]
  to   = module.internal_s3web.module.codepublish_iam_role.aws_iam_role_policy.role_policy[0]
}

moved {
  from = module.codescan_iam_role.aws_iam_role.default
  to   = module.internal_s3web.module.codescan_iam_role.aws_iam_role.default
}

moved {
  from = module.codescan_iam_role.aws_iam_role_policy.role_policy[0]
  to   = module.internal_s3web.module.codescan_iam_role.aws_iam_role_policy.role_policy[0]
}

moved {
  from = module.security-group.aws_security_group.default
  to   = module.internal_s3web.module.security-group.aws_security_group.default
}

moved {
  from = module.security-group.aws_security_group_rule.cidr_egress["CCOE egress rules 0 0 -1}"]
  to   = module.internal_s3web.module.security-group.aws_security_group_rule.cidr_egress["CCOE egress rules 0 0 -1}"]
}

moved {
  from = module.codebuild_iam_role.aws_iam_role.default
  to   = module.internal_s3web.module.codebuild_iam_role.aws_iam_role.default
}

moved {
  from = module.codebuild_iam_role.aws_iam_role_policy.role_policy[0]
  to   = module.internal_s3web.module.codebuild_iam_role.aws_iam_role_policy.role_policy[0]
}

moved {
  from = module.codebuild_codescan.aws_codebuild_project.codebuild_project
  to   = module.internal_s3web.module.codebuild_codescan.aws_codebuild_project.codebuild_project
}

moved {
  from = module.codebuild_codescan.aws_codebuild_resource_policy.codebuild_resource_policy
  to   = module.internal_s3web.module.codebuild_codescan.aws_codebuild_resource_policy.codebuild_resource_policy
}

moved {
  from = module.codebuild_codescan.aws_codebuild_source_credential.codebuild_source_credential
  to   = module.internal_s3web.module.codebuild_codescan.aws_codebuild_source_credential.codebuild_source_credential
}

moved {
  from = module.codebuild_codepublish.aws_codebuild_project.codebuild_project
  to   = module.internal_s3web.module.codebuild_codepublish.aws_codebuild_project.codebuild_project
}

moved {
  from = module.codebuild_codepublish.aws_codebuild_resource_policy.codebuild_resource_policy
  to   = module.internal_s3web.module.codebuild_codepublish.aws_codebuild_resource_policy.codebuild_resource_policy
}

moved {
  from = module.codebuild_codepublish.aws_codebuild_source_credential.codebuild_source_credential
  to   = module.internal_s3web.module.codebuild_codepublish.aws_codebuild_source_credential.codebuild_source_credential
}

##
moved {
  from = module.codebuild_project.aws_codebuild_project.codebuild_project
  to   = module.internal_s3web.module.codebuild_project.aws_codebuild_project.codebuild_project
}

moved {
  from = module.codebuild_project.aws_codebuild_resource_policy.codebuild_resource_policy
  to   = module.internal_s3web.module.codebuild_project.aws_codebuild_resource_policy.codebuild_resource_policy
}

moved {
  from = module.codebuild_project.aws_codebuild_source_credential.codebuild_source_credential
  to   = module.internal_s3web.module.codebuild_project.aws_codebuild_source_credential.codebuild_source_credential
}
##

moved {
  from = module.internal_s3web.module.codebuild_project.aws_codebuild_project.codebuild_project
  to   = module.internal_s3web.module.codebuild_project[0].aws_codebuild_project.codebuild_project
}

moved {
  from = module.internal_s3web.module.codebuild_project.aws_codebuild_resource_policy.codebuild_resource_policy
  to   = module.internal_s3web.module.codebuild_project[0].aws_codebuild_resource_policy.codebuild_resource_policy
}

moved {
  from = module.internal_s3web.module.codebuild_project.aws_codebuild_source_credential.codebuild_source_credential
  to   = module.internal_s3web.module.codebuild_project[0].aws_codebuild_source_credential.codebuild_source_credential
}

moved {
  from = aws_codepipeline.codepipeline
  to   = module.internal_s3web.aws_codepipeline.codepipeline[0]
}

moved {
  from = module.internal_s3web.module.codebuild_project.aws_codebuild_source_credential.codebuild_source_credential
  to   = module.internal_s3web.module.codebuild_project[0].aws_codebuild_source_credential.codebuild_source_credential
}

moved {
  from = module.internal_s3web.module.codebuild_project.aws_codebuild_project.codebuild_project
  to   = module.internal_s3web.module.codebuild_project[0].aws_codebuild_project.codebuild_project
}

moved {
  from = module.internal_s3web.module.codebuild_project.aws_codebuild_resource_policy.codebuild_resource_policy
  to   = module.internal_s3web.module.codebuild_project[0].aws_codebuild_resource_policy.codebuild_resource_policy
}

moved {
  from = module.internal_s3web.module.codepipeline_iam_role.aws_iam_role.default
  to   = module.internal_s3web.module.codepipeline_iam_role[0].aws_iam_role.default
}

moved {
  from = module.internal_s3web.module.codepipeline_iam_role.aws_iam_role_policy.role_policy[0]
  to   = module.internal_s3web.module.codepipeline_iam_role[0].aws_iam_role_policy.role_policy[0]
}

moved {
  from = module.internal_s3web.module.s3.aws_s3_bucket.default
  to   = module.internal_s3web.module.s3[0].aws_s3_bucket.default
}

moved {
  from = module.internal_s3web.module.s3.aws_s3_bucket_acl.default
  to   = module.internal_s3web.module.s3[0].aws_s3_bucket_acl.default
}

moved {
  from = module.internal_s3web.module.s3.aws_s3_bucket_ownership_controls.default
  to   = module.internal_s3web.module.s3[0].aws_s3_bucket_ownership_controls.default
}

moved {
  from = module.internal_s3web.module.s3.aws_s3_bucket_policy.default
  to   = module.internal_s3web.module.s3[0].aws_s3_bucket_policy.default
}

moved {
  from = module.internal_s3web.module.s3.aws_s3_bucket_public_access_block.default
  to   = module.internal_s3web.module.s3[0].aws_s3_bucket_public_access_block.default
}

moved {
  from = module.internal_s3web.module.s3.aws_s3_bucket_server_side_encryption_configuration.default
  to   = module.internal_s3web.module.s3[0].aws_s3_bucket_server_side_encryption_configuration.default
}

moved {
  from = module.internal_s3web.module.s3.aws_s3_bucket_versioning.default
  to   = module.internal_s3web.module.s3[0].aws_s3_bucket_versioning.default
}

moved {
  from = module.internal_s3web.module.codebuild_iam_role.aws_iam_role.default
  to   = module.internal_s3web.module.codebuild_iam_role[0].aws_iam_role.default
}

moved {
  from = module.internal_s3web.module.codebuild_iam_role.aws_iam_role_policy.role_policy[0]
  to   = module.internal_s3web.module.codebuild_iam_role[0].aws_iam_role_policy.role_policy[0]
}

moved {
  from = module.internal_s3web.aws_codepipeline.codepipeline[0]
  to   = module.internal_s3web.aws_codepipeline.codepipeline
}