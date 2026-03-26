# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# IAM Policy for creating the Service-Linked Role
data "aws_iam_policy_document" "service_linked_role" {
  count = local.create_runtime ? 1 : 0

  statement {
    sid    = "CreateBedrockAgentCoreIdentityServiceLinkedRolePermissions"
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = [
      "arn:aws:iam::*:role/aws-service-role/runtime-identity.bedrock-agentcore.amazonaws.com/AWSServiceRoleForBedrockAgentCoreRuntimeIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values = [
        "runtime-identity.bedrock-agentcore.amazonaws.com"
      ]
    }
  }
}

