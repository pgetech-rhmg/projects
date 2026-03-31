# EventBridge rule for AMI publication events
resource "aws_cloudwatch_event_rule" "ami_published" {
  name_prefix = "ami-factory-ami-published-"
  description = "Trigger when AMI is published with environment label"

  event_pattern = jsonencode({
    source      = ["aws.ssm"]
    detail-type = ["Parameter Store Change"]
    detail = {
      operation = ["LabelParameterVersion"]
      name = [
        "/ami_factory/webadapter/ami",
        "/ami_factory/portal/ami",
        "/ami_factory/datastore/ami",
        "/ami_factory/server/ami"
      ]
      label = [var.environment]
    }
  })

  tags = merge(local.merged_tags, {
    Component = "pipeline"
  })
}

resource "aws_cloudwatch_event_target" "ami_published_sns" {
  rule      = aws_cloudwatch_event_rule.ami_published.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.pipeline_notifications.arn

  input_transformer {
    input_paths = {
      component = "$.detail.name"
      label     = "$.detail.label"
      version   = "$.detail.version"
    }
    input_template = "\"AMI published: <component> version <version> labeled as <label>\""
  }
}

resource "aws_sns_topic_policy" "pipeline_notifications" {
  arn = aws_sns_topic.pipeline_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforcedTLSOnly"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "sns:Publish",
          "sns:RemovePermission",
          "sns:SetTopicAttributes",
          "sns:DeleteTopic",
          "sns:AddPermission",
          "sns:GetTopicAttributes",
          "sns:Subscribe",
          "sns:ListSubscriptionsByTopic"
        ]
        Resource = aws_sns_topic.pipeline_notifications.arn
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "AllowPublishEncrypted"
        Effect = "Allow"
        Principal = {
          Service = [
            "codepipeline.amazonaws.com",
            "events.amazonaws.com"
          ]
        }
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.pipeline_notifications.arn
      }
    ]
  })
}

# custom event bus for pipeline events
# TODO: Add loggin configuration for event bus and encrytion using KMS key
# resource "aws_cloudwatch_event_bus" "ami_factory" {
#   name = "ami-factory-events"

#   tags = merge(local.merged_tags, {
#     Component = "pipeline"
#   })
# }

# cloudwatch envent bus policy to allow org to listen to events
# resource "aws_cloudwatch_event_bus_policy" "ami_factory_org_access" {
#   event_bus_name = aws_cloudwatch_event_bus.ami_factory.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid       = "AllowOrgReadAccess"
#         Effect    = "Allow"
#         Principal = "*"
#         Action = [
#           "events:PutRule",
#           "events:DescribeRule",
#           "events:EnableRule",
#           "events:DisableRule",
#           "events:DeleteRule",
#           "events:ListRules",
#           "events:PutTargets",
#           "events:RemoveTargets"
#         ]
#         Resource = "arn:aws:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:rule/ami-factory-events/*"
#         Condition = {
#           StringEquals = {
#             "aws:PrincipalOrgID" = data.aws_organizations_organization.current.id
#           }
#         }
#       }
#     ]
#   })

# }