moved {
  from = aws_codepipeline.codepipeline
  to   = module.internal_container.aws_codepipeline.codepipeline
}

moved {
  from = module.codebuild_codescan.aws_codebuild_project.codebuild_project
  to   = module.internal_container.module.codebuild_codescan.aws_codebuild_project.codebuild_project
}

moved {
  from = module.codebuild_codescan.aws_codebuild_resource_policy.codebuild_resource_policy
  to   = module.internal_container.module.codebuild_codescan.aws_codebuild_resource_policy.codebuild_resource_policy
}

moved {
  from = module.codebuild_codescan.aws_codebuild_source_credential.codebuild_source_credential
  to   = module.internal_container.module.codebuild_codescan.aws_codebuild_source_credential.codebuild_source_credential
}

moved {
  from = module.codebuild_iam_role.aws_iam_role.default
  to   = module.internal_container.module.codebuild_iam_role.aws_iam_role.default
}

moved {
  from = module.codebuild_iam_role.aws_iam_role_policy.role_policy[0]
  to   = module.internal_container.module.codebuild_iam_role.aws_iam_role_policy.role_policy[0]
}

moved {
  from = module.codebuild_project.aws_codebuild_project.codebuild_project
  to   = module.internal_container.module.codebuild_project.aws_codebuild_project.codebuild_project
}

moved {
  from = module.codebuild_project.aws_codebuild_resource_policy.codebuild_resource_policy
  to   = module.internal_container.module.codebuild_project.aws_codebuild_resource_policy.codebuild_resource_policy
}

moved {
  from = module.codebuild_project.aws_codebuild_source_credential.codebuild_source_credential
  to   = module.internal_container.module.codebuild_project.aws_codebuild_source_credential.codebuild_source_credential
}

moved {
  from = module.codepublish_iam_role.aws_iam_role.default
  to   = module.internal_container.module.codepublish_iam_role.aws_iam_role.default
}

moved {
  from = module.codepublish_iam_role.aws_iam_role_policy.role_policy[0]
  to   = module.internal_container.module.codepublish_iam_role.aws_iam_role_policy.role_policy[0]
}

moved {
  from = module.codescan_iam_role.aws_iam_role.default
  to   = module.internal_container.module.codescan_iam_role.aws_iam_role.default
}

moved {
  from = module.codescan_iam_role.aws_iam_role_policy.role_policy[0]
  to   = module.internal_container.module.codescan_iam_role.aws_iam_role_policy.role_policy[0]
}

moved {
  from = module.codesecret_iam_role.aws_iam_role.default
  to   = module.internal_container.module.codesecret_iam_role.aws_iam_role.default
}

moved {
  from = module.codesecret_iam_role.aws_iam_role_policy.role_policy[0]
  to   = module.internal_container.module.codesecret_iam_role.aws_iam_role_policy.role_policy[0]
}

moved {
  from = module.codesecret_project.aws_codebuild_project.codebuild_project
  to   = module.internal_container.module.codesecret_project.aws_codebuild_project.codebuild_project
}

moved {
  from = module.codesecret_project.aws_codebuild_resource_policy.codebuild_resource_policy
  to   = module.internal_container.module.codesecret_project.aws_codebuild_resource_policy.codebuild_resource_policy
}

moved {
  from = module.codesecret_project.aws_codebuild_source_credential.codebuild_source_credential
  to   = module.internal_container.module.codesecret_project.aws_codebuild_source_credential.codebuild_source_credential
}

moved {
  from = module.codestar-notifications.aws_codestarnotifications_notification_rule.build_notify
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.aws_codestarnotifications_notification_rule.build_notify
}
moved {
  from = module.codestar-notifications.aws_iam_policy.policy_for_lambda
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.aws_iam_policy.policy_for_lambda
}

moved {
  from = module.codestar-notifications.aws_iam_role.role_for_lambda
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.aws_iam_role.role_for_lambda
}

moved {
  from = module.codestar-notifications.aws_iam_role_policy_attachment.policy_attachment_for_lambda
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.aws_iam_role_policy_attachment.policy_attachment_for_lambda
}

moved {
  from = module.codestar-notifications.aws_lambda_permission.with_sns
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.aws_lambda_permission.with_sns
}

moved {
  from = module.codestar-notifications.aws_sns_topic.sns-topic-trigger-email
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.aws_sns_topic.sns-topic-rigger-email
}

moved {
  from = module.codestar-notifications.aws_sns_topic.sns-topic-trigger-lambda
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.aws_sns_topic.sns-topic-trigger-lambda
}


moved {
  from = module.codestar-notifications.aws_sns_topic_policy.sns_trigger_email
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.aws_sns_topic_policy.sns-trigger-email
}

moved {
  from = module.codestar-notifications.aws_sns_topic_policy.sns_trigger_lambda
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.aws_sns_topic_policy.sns_trigger_lambda
}

moved {
  from = module.codestar-notifications.aws_sns_topic_subscription.sns_topic_subscription_trigger_lambda
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.aws_sns_topic_subscription.sns_topic_subscription_trigger_lambda
}

moved {
  from = module.codestar-notifications.local_file.lambda_func
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.local_file.lambda_func
}

moved {
  from = module.security-group.aws_security_group.default
  to   = module.internal_container.module.security-group.aws_security_group.default
}

moved {
  from = module.security-group.aws_security_group_rule.cidr_egress["CCOE egress rules 0 0 -1}"]
  to   = module.internal_container.module.security-group.aws_security_group_rule.cidr_egress["CCOE egress rules 0 0 -1}"]
}

moved {
  from = module.security-group.aws_security_group_rule.cidr_egress["CCOE egress rules 443 443 tcp}"]
  to   = module.internal_container.module.security-group.aws_security_group_rule.cidr_egress["CCOE egress rules 443 443 tcp}"]
}

moved {
  from = module.codestar-notifications.module.lambda_function.aws_lambda_function.lambda_function
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.module.lambda_function.aws_lambda_function.lambda_function
}

moved {
  from = module.codestar-notifications.module.lambda_function.random_string.random
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.module.lambda_function.random_string.random
}

moved {
  from = module.codestar-notifications.module.security-group-snslambda.aws_security_group.default
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.module.security_group_snslambda.aws_security_group.default
}

moved {
  from = module.codestar-notifications.module.security-group-snslambda.aws_security_group_rule.cidr_egress["CCOE egress rules 0 0 -1}"]
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.module.security-group-snslambda.aws_security_group_rule.cidr_egress["CCOE egress rules 0 0 -1}"]
}
moved {
  from = module.internal_container.module.codepipeline_internal_codestar_notifications.aws_sns_topic.sns-topic-rigger-email
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.aws_sns_topic.sns-topic-trigger-email
}

moved {
  from = module.internal_container.module.codepipeline_internal_codestar_notifications.aws_sns_topic_policy.sns-trigger-email
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.aws_sns_topic_policy.sns_trigger_email

}

moved {
  from = module.internal_container.module.codepipeline_internal_codestar_notifications.module.security_group_snslambda.aws_security_group.default
  to   = module.internal_container.module.codepipeline_internal_codestar_notifications.module.security-group-snslambda.aws_security_group.default
}

