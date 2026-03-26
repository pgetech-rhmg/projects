

data "aws_iam_policy_document" "irsa" {
  statement {
    sid       = "PutLogEvents"
    effect    = "Allow"
    resources = ["arn:*:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*"]
    actions   = ["logs:PutLogEvents"]
  }

  statement {
    sid       = "CreateCWLogs"
    effect    = "Allow"
    resources = ["arn:*:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
  }
}

data "aws_iam_policy_document" "kms" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root", ]
      # data.aws_iam_session_context.current.issuer_arn]
    }
  }

  statement {
    sid       = "Enable Encryption for LogGroup"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Decrypt*",
      "kms:Describe*",
      "kms:Encrypt*",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]

    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/${var.cluster_name}/worker-fluentbit-logs"]
    }

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}


resource "aws_cloudwatch_log_group" "aws_for_fluent_bit" {
  count             = var.create_aws_for_fluentbit_resources && var.attach_aws_for_fluentbit_policy ? 1 : 0
  name              = local.log_group_name
  retention_in_days = var.cw_log_group_retention
  kms_key_id        = var.cw_log_group_kms_key_arn == null ? module.kms[0].key_arn : var.cw_log_group_kms_key_arn
  tags              = var.tags
}

resource "aws_iam_policy" "aws_for_fluent_bit" {
  count       = var.create_aws_for_fluentbit_resources && var.attach_aws_for_fluentbit_policy ? 1 : 0
  name        = "${var.cluster_name}-fluentbit"
  description = "IAM Policy for AWS for FluentBit"
  policy      = data.aws_iam_policy_document.irsa.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "aws_for_fluent_bit" {
  count = var.create_aws_for_fluentbit_resources && var.attach_aws_for_fluentbit_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.aws_for_fluent_bit[0].arn
}

module "kms" {
  count       = var.create_aws_for_fluentbit_resources ? 1 : 0
  source      = "app.terraform.io/pgetech/kms/aws"
  version     = "0.1.3"
  description = "EKS Workers FluentBit CloudWatch Log group KMS Key"
  name        = "${var.cluster_name}-fluentbit-kms"
  aws_role    = "CloudAdmin"
  kms_role    = "CloudAdmin"
  policy      = data.aws_iam_policy_document.kms.json
  tags        = var.tags
}

locals {
  name           = "aws-for-fluent-bit"
  log_group_name = var.cw_log_group_name == null ? "/${var.cluster_name}/worker-fluentbit-logs" : var.cw_log_group_name
}


