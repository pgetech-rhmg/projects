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
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${local.lambda_name}-policy"
  description = "A policy that allows a Lambda to execute"
  policy      = data.aws_iam_policy_document.lambda_policy_document.json
  tags        = var.tags
}

resource "aws_iam_role" "lambda_role" {
  name               = "${local.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  tags               = var.tags
}

resource "aws_iam_policy_attachment" "lambda_attach" {
  name       = "${local.lambda_name}-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_policy.arn
}
