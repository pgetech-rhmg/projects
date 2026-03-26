moved {
  from = module.codestar-notifications.aws_codestarnotifications_notification_rule.build_notify
  to   = module.codepipeline_internal_codestar_notifications.aws_codestarnotifications_notification_rule.build_notify
}

moved {
  from = module.codestar-notifications.aws_iam_policy.policy_for_lambda
  to   = module.codepipeline_internal_codestar_notifications.aws_iam_policy.policy_for_lambda
}

moved {
  from = module.codestar-notifications.aws_iam_role.role_for_lambda
  to   = module.codepipeline_internal_codestar_notifications.aws_iam_role.role_for_lambda
}

moved {
  from = module.codestar-notifications.aws_iam_role_policy_attachment.policy_attachment_for_lambda
  to   = module.codepipeline_internal_codestar_notifications.aws_iam_role_policy_attachment.policy_attachment_for_lambda
}

moved {
  from = module.codestar-notifications.aws_lambda_permission.with_sns
  to   = module.codepipeline_internal_codestar_notifications.aws_lambda_permission.with_sns
}

moved {
  from = module.codestar-notifications.aws_sns_topic.sns-topic-trigger-email
  to   = module.codepipeline_internal_codestar_notifications.aws_sns_topic.sns-topic-trigger-email
}

moved {
  from = module.codestar-notifications.aws_sns_topic.sns-topic-trigger-lambda
  to   = module.codepipeline_internal_codestar_notifications.aws_sns_topic.sns-topic-trigger-lambda
}

moved {
  from = module.codestar-notifications.aws_sns_topic_policy.sns_trigger_email
  to   = module.codepipeline_internal_codestar_notifications.aws_sns_topic_policy.sns_trigger_email
}

moved {
  from = module.codestar-notifications.aws_sns_topic_policy.sns_trigger_lambda
  to   = module.codepipeline_internal_codestar_notifications.aws_sns_topic_policy.sns_trigger_lambda
}

moved {
  from = module.codestar-notifications.aws_sns_topic_subscription.sns_topic_subscription_trigger_lambda
  to   = module.codepipeline_internal_codestar_notifications.aws_sns_topic_subscription.sns_topic_subscription_trigger_lambda
}

moved {
  from = module.codestar-notifications.local_file.lambda_func
  to   = module.codepipeline_internal_codestar_notifications.local_file.lambda_func
}

moved {
  from = module.codestar-notifications.module.lambda_function.aws_lambda_function.lambda_function
  to   = module.codepipeline_internal_codestar_notifications.module.lambda_function.aws_lambda_function.lambda_function
}

moved {
  from = module.codestar-notifications.module.lambda_function.random_string.random
  to   = module.codepipeline_internal_codestar_notifications.module.lambda_function.random_string.random
}

moved {
  from = module.codestar-notifications.module.security-group-snslambda.aws_security_group.default
  to   = module.codepipeline_internal_codestar_notifications.module.security-group-snslambda.aws_security_group.default
}

moved {
  from = module.codestar-notifications.module.security-group-snslambda.aws_security_group_rule.cidr_egress["CCOE egress rules 0 0 -1}"]
  to   = module.codepipeline_internal_codestar_notifications.module.security-group-snslambda.aws_security_group_rule.cidr_egress["CCOE egress rules 0 0 -1}"]
}