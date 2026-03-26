data "aws_iam_policy_document" "lambda_policy_document" {
  # Neptune/RDS permissions - Required for creating and managing Neptune instances
  statement {
    actions = [
      "rds:CreateDBInstance",
      "rds:DeleteDBInstance",
      "rds:DeleteDBCluster",
      "rds:StopDBCluster",
      "rds:StartDBCluster",
      "rds:ModifyDBInstance",
      "rds:ModifyDBCluster",
      "rds:RebootDBInstance",
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusterParameters",
      "rds:DescribeDBParameters",
      "rds:DescribeDBSubnetGroups",
      "rds:DescribeDBClusterParameterGroups",
      "rds:DescribeDBParameterGroups",
      "rds:AddTagsToResource",
      "rds:RemoveTagsFromResource",
      "rds:ListTagsForResource",
      "neptune-db:*"
    ]

    resources = [
      "*"
    ]
  }

  # CloudWatch Logs permissions
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
      "logs:ListTagsLogGroup",
      "logs:PutLogEvents",
      "logs:TagLogGroup"
    ]

    resources = [
      "*"
    ]
  }

  # VPC/Network permissions
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses"
    ]

    resources = [
      "*"
    ]
  }

  # SNS permissions
  statement {
    actions = [
      "sns:Subscribe",
      "sns:Get*",
      "sns:List*"
    ]

    resources = [
      "*"
    ]
  }

  # SSM Parameter Store permissions (for configuration)
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:DescribeParameters"
    ]

    resources = [
      "*"
    ]
  }

  # KMS permissions
  statement {
    actions = [
      "kms:Decrypt",
      "kms:Describe*",
      "kms:Encrypt*",
      "kms:Get*",
      "kms:GenerateDataKey*",
      "kms:List*"
    ]

    resources = [
      "*"
    ]
  }

  # Lambda permissions
  statement {
    actions = [
      "lambda:*"
    ]

    resources = [
      "*"
    ]
  }

  # EventBridge permissions
  statement {
    actions = [
      "events:Describe*",
      "events:EnableRule",
      "events:DisableRule",
      "events:List*"
    ]

    resources = [
      "*"
    ]
  }

  # X-Ray tracing permissions
  statement {
    actions = [
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries",
      "xray:PutTelemetryRecords",
      "xray:PutTraceSegments"
    ]

    resources = [
      "*"
    ]
  }

  # Secrets Manager permissions (for database credentials if needed)
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
      "secretsmanager:GetRandomPassword"
    ]

    resources = [
      "*"
    ]
  }

  # S3 permissions
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Put*"
    ]

    resources = [
      "*"
    ]
  }
}

# Lambda assume role policy
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# IAM Policy
resource "aws_iam_policy" "lambda_policy" {
  name        = "${local.lambda_name}-policy"
  description = "A policy that allows Neptune Lambda to execute"
  policy      = data.aws_iam_policy_document.lambda_policy_document.json
  tags        = var.tags
}

# IAM Role
resource "aws_iam_role" "lambda_role" {
  name               = "${local.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  tags               = var.tags
}

# IAM Policy Attachment
resource "aws_iam_policy_attachment" "lambda_attach" {
  name       = "${local.lambda_name}-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_policy.arn
}