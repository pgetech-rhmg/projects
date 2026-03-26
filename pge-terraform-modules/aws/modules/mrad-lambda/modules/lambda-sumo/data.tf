data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.archive_path
  output_path = "${var.lambda_name}.zip"
}

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

data "aws_iam_policy_document" "lambda_policy_document" {
  // Events permissions
  statement {
    actions = [
      "events:*",
    ]

    resources = [
      "*",
    ]
  }

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
      "logs:PutSubscriptionFilter",
      "logs:DescribeSubscriptionFilters",
      "logs:DeleteSubscriptionFilter"
    ]

    resources = [
      "*",
    ]
  }

  // ECS Permissions
  statement {
    actions = [
      "ecs:DeleteCluster",
      "ecs:DeleteService",
      "ecs:DeleteTaskSet",
      "ecs:Describe*",
      "ecs:UntagResource",
      "ecs:UpdateService",
      "ecs:DeregisterTaskDefinition",
    ]

    resources = [
      "*",
    ]
  }

  // ELB permissions
  statement {
    actions = [
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:Describe*"
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
      "ecr:DeleteLifecyclePolicy",
      "ecr:GetLifecyclePolicy",
      "ecr:GetRepositoryPolicy",
      "ecr:ListTagsForResource",
      "ecr:DeleteRepository",
      "ecr:Describe*",
      "ecr:Get*",
      "ecr:List*",
      "ecr:Put*",
      "ecr:UntagResource"
    ]

    resources = [
      "*",
    ]
  }

  // KMS Permissions
  statement {
    actions = [
      "kms:Decrypt*",
      "kms:Describe*",
      "kms:Encrypt*",
      "kms:Get*",
      "kms:GenerateDataKey*",
      "kms:List*",
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
      "sns:Unsubscribe"
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
      "codepipeline:DeleteWebhook",
      "codepipeline:Get*",
      "codepipeline:ListTagsForResource",
      "codepipeline:ListWebhooks",
      "codepipeline:PutJobFailureResult",
      "codepipeline:PutJobSuccessResult",
      "codepipeline:PutWebhook",
      "codepipeline:TagResource",
      "codepipeline:UpdatePipeline",
    ]
    resources = [
      "*",
    ]
  }

  // SSM permissions
  statement {
    actions = [
      "ssm:DeleteParameter",
      "ssm:Describe*",
      "ssm:Get*",
      "ssm:List*",
      "ssm:PutParameter",
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

  // Secret permissions (incl for rotation)
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
      "secretsmanager:GetRandomPassword",
    ]

    resources = [
      "*",
    ]
  }

  // ACM permissions
  statement {
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
      "acm:ListTagsForCertificate"
    ]

    resources = [
      "*",
    ]
  }

  // EC2 Permissions
  statement {
    actions = [
      "ec2:Describe*",
      "ec2:*NetworkInterface*",
      "ec2:*SecurityGroup*",
    ]

    resources = [
      "*",
    ]
  }

  // xray permissions for manual deployment
  statement {
    actions = [
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

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::686137062481:role/DCDNSCrossAccountRole",
      "arn:aws:iam::925741509387:role/TransAccountKeyRotatorRole",
    ]
  }

  // AppConfig permissions
  statement {
    actions = [
          "appconfig:StartConfigurationSession",
          "appconfig:Get*",
          "appconfig:List*",
          "appconfig:Update*",
          "appconfig:Validate*"
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "bucket_ssl_only_policy_document" {
  // Force SSL-only access, courtesy of binaryalert on Github
  statement {
    sid    = "ForceSSLOnlyAccess"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      module.lambda-s3.arn,
      "${module.lambda-s3.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

locals {
  private_subnet1 = var.partner == "MRAD" ? "${var.partner}-${var.subnet_qualifier[var.aws_account]}-PrivateSubnet1" : var.subnet1
  private_subnet2 = var.partner == "MRAD" ? "${var.partner}-${var.subnet_qualifier[var.aws_account]}-PrivateSubnet2" : var.subnet2
  private_subnet3 = var.partner == "MRAD" ? "${var.partner}-${var.subnet_qualifier[var.aws_account]}-PrivateSubnet3" : var.subnet3
  security_group  = var.sg_name
}

data "aws_subnet" "private1" {
  filter {
    name   = "tag:Name"
    values = [local.private_subnet1]
  }
}

data "aws_subnet" "private2" {
  filter {
    name   = "tag:Name"
    values = [local.private_subnet2]
  }
}

data "aws_subnet" "private3" {
  filter {
    name   = "tag:Name"
    values = [local.private_subnet3]
  }
}

data "aws_security_groups" "lambda_sgs" {
  filter {
    name   = "group-name"
    values = [local.security_group]
  }
}

data "aws_s3_bucket" "logging_bucket" {
  bucket = "ccoe-s3-accesslogs-spoke-${var.aws_region}-${data.aws_caller_identity.current.account_id}"
}
