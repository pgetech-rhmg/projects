data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms_policy_document" {
  // KMS permissions

  statement {

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }

    actions = [
      "kms:DescribeKey",
      "kms:CreateCustomKeyStore",
      "kms:DescribeCustomKeyStores",
      "kms:CreateKey",
      "kms:List*",
      "kms:GetKeyPolicy",
      "kms:UpdatePrimaryRegion",
      "kms:ConnectCustomKeyStore",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyPair",
      "kms:SynchronizeMultiRegionKey",
      "kms:ReplicateKey",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GetKeyPolicy"
    ]

    resources = [
      "*",
    ]
  }
}

/*
    --- Sumo && Lambda Permissions ---
*/

data "aws_iam_policy_document" "lambda_policy_document" {

  // Logs permissions
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DescribeLogGroups",
      "logs:ListTagsLogGroup",
      "logs:PutLogEvents",
      "logs:TagLogGroup",
    ]

    resources = [
      "*",
    ]
  }

  // ECR Permissions
  statement {
    actions = [
      "ecr:CreateRepository",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListTagsForResource",
    ]

    resources = [
      "*",
    ]
  }

  // IAM Permissions
  statement {
    actions = [
      "iam:*",
    ]

    resources = [
      "*",
    ]
  }

  // Lambda permissions
  statement {
    actions = [
      "lambda:*",
    ]

    resources = [
      "*",
    ]
  }

  // API Gateway Permissions
  statement {
    actions = [
      "apigateway:*"
    ]

    resources = [
      "*",
    ]
  }

  // DynamoDB Permissions
  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]

    resources = [
      "*",
    ]
  }

  // SQS Permissions
  statement {
    actions = [
      "sqs:*",
    ]

    resources = [
      "*",
    ]
  }

  // SNS Permissions
  statement {
    actions = [
      "sns:Subscribe",
      "sns:Get*",
      "sns:List*",
    ]

    resources = [
      "*",
    ]
  }

  // CodeBuild/CodePipeline permissions
  statement {
    actions = [
      "codebuild:BatchGetProjects",
      "codebuild:CreateProject",
      "codebuild:CreateWebhook",
      "codebuild:DeleteProject",
      "codebuild:DeleteWebhook",
      "codepipeline:CreatePipeline",
      "codepipeline:DeletePipeline",
      "codepipeline:GetPipeline",
      "codepipeline:ListTagsForResource",
      "codepipeline:TagResource",
      "codepipeline:UpdatePipeline"
    ]
    resources = [
      "*",
    ]
  }

  // SSM permissions
  statement {
    actions = [
      "ssm:GetParameter",
    ]
    resources = [
      "*",
    ]
  }

  // s3 permissions
  statement {
    actions = [
      "s3:CreateBucket",
      "s3:Delete*",
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
    ]

    resources = [
      "*",
    ]
  }

  // Secret permissions
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "*",
    ]
  }

  // SQS permissions
  statement {
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]

    resources = [
      "*",
    ]
  }

  // EC2 Permissions
  statement {
    actions = [
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
      "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DescribeTags",
      "ec2:Describe*",
    ]

    resources = [
      "*",
    ]
  }

  // Hodgepodge permissions for manual deployment
  statement {
    actions = [
      "ec2:AttachNetworkInterface",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries",
      "xray:PutTelemetryRecords",
      "xray:PutTraceSegments",
    ]

    resources = [
      "*",
    ]
  }
}

# Fetch the Sumo HTTP endpoint URL from AWS SSM Parameter Store
data "aws_ssm_parameter" "sumo_firehose_http_endpoint_url" {
  # from mrad-shared-infra
  name = "/mrad/sumo_firehose_http_endpoint_url"
}

# Fetch the Sumo Firehose backup bucket name from AWS SSM Parameter Store
# from mrad-shared-infra
data "aws_ssm_parameter" "sumo_firehose_backup_bucket" {
  name = "/mrad/sumo_firehose_backup_bucket"
}

# Use the value from SSM parameter to fetch the S3 bucket
data "aws_s3_bucket" "sumo_firehose_backup_bucket" {
  bucket = data.aws_ssm_parameter.sumo_firehose_backup_bucket.value
}

data "aws_kms_key" "kinesis" {
  key_id = "alias/aws/kinesis"
}
