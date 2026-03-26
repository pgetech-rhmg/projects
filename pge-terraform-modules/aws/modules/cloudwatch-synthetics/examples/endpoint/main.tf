/*
 * # AWS Cloudwatch synthetics example, this is used to create Cloudwatch synthetics canary within a VPC
 * Terraform module which creates SAF2.0 Cloudwatch synthetics Alarms in AWS
*/

#
#  Filename    : aws/modules/cloudwatch-synthetics/examples/endpoint/main.tf
#  Date        : 14 Feb 2024
#  Author      : PGE
#  Description : AWS Cloudwatch synthetics example , this is used to create Clopudwatch Alarms
#

## NOTE
# To subscribe to SNS topic, either have an SNS topic created before passing it to the module or you can use SNS topic from pge private registry

locals {
  name               = var.name
  policy_name        = var.policy_name
  path               = var.path
  description        = var.description
  aws_service        = var.aws_service
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  Order              = var.Order
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}


data "aws_ssm_parameter" "private_subnet1_id" {
  name = "/vpc/2/privatesubnet1/id"

}
data "aws_ssm_parameter" "private_subnet2_id" {
  name = "/vpc/2/privatesubnet2/id"
}
data "aws_ssm_parameter" "private_subnet3_id" {
  name = "/vpc/2/privatesubnet3/id"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}
data "aws_caller_identity" "current" {
}
data "aws_region" "current" {
}



# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.2"
#  name        = var.kms_name
#  description = var.kms_description
#  tags        = merge(module.tags.tags, local.optional_tags)
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
# }

// Setup for one Canary. This section can be reused several time.
module "canary" {
  source             = "../../"
  name               = var.name
  runtime_version    = var.runtime_version
  take_screenshot    = var.take_screenshot
  api_hostname       = var.api_hostname
  api_path           = var.api_path
  reports-bucket     = module.s3.id
  execution_role_arn = module.aws_iam_role.arn
  security_group_id  = module.canary_security_group.sg_id
  subnet_ids = [
    data.aws_ssm_parameter.private_subnet3_id.value,
    data.aws_ssm_parameter.private_subnet2_id.value,
    data.aws_ssm_parameter.private_subnet1_id.value
  ]
  frequency = var.frequency
  tags      = merge(module.tags.tags, local.optional_tags)

}


#########################################
# Create S3 bucket with user defined policy
#########################################
module "s3" {
  source      = "app.terraform.io/pgetech/s3/aws"
  version     = "0.1.1"
  bucket_name = var.bucket_name
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  versioning  = var.versioning
  policy      = templatefile("${path.module}/s3_bucket_canary_policy.json", { aws_role = var.aws_role, account_num = var.account_num, bucket_name = var.bucket_name })
  tags        = merge(module.tags.tags, { DRTier = "TIER 1 - Active / Active", Org = "Information Technology" })

}


###########################################
# Role Creation with customer managed policy
###########################################
module "iam_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name        = local.policy_name
  path        = local.path
  description = local.description
  policy      = [data.aws_iam_policy_document.canary-policy.json]

  tags = merge(module.tags.tags, local.optional_tags)
}

module "aws_iam_role" {
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.1"
  name        = local.name
  aws_service = local.aws_service
  #Customer Managed Policy
  policy_arns = [module.iam_policy.arn]
  tags        = merge(module.tags.tags, local.optional_tags)

  depends_on = [
    module.iam_policy
  ]

}

data "aws_iam_policy_document" "canary-policy" {
  statement {
    sid    = "CanaryS3Permission1"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets"
    ]
    resources = [

      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }

  statement {
    sid    = "CanaryS3Permission2"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets"
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    sid    = "CanaryCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
    ]
  }

  statement {
    sid    = "CanaryCloudWatchAlarm"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      values   = ["CloudWatchSynthetics"]
      variable = "cloudwatch:namespace"
    }
  }

  statement {
    sid    = "CanaryinVPC"
    effect = "Allow"
    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:AttachNetworkInterface"
    ]
    resources = [
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = module.aws_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


module "canary_security_group" {

  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name                         = "canary_sg_2"
  description                  = "Allow canaries to call the services they need to call"
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules           = var.cidr_ingress_rules
  cidr_egress_rules            = var.cidr_egress_rules
  security_group_ingress_rules = var.security_group_ingress_rules
  security_group_egress_rules  = var.security_group_egress_rules
  tags                         = merge(module.tags.tags, { name = "canary-sg" })
}


module "cloudwatch_metric-alarm" {
  source              = "app.terraform.io/pgetech/cloudwatch/aws"
  version             = "0.1.3"
  alarm_name          = "canary-${var.name}"
  comparison_operator = var.comparison_operator
  period              = var.period // 5 minutes (should be calculated from the frequency of the canary)
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.namespace
  statistic           = var.statistic
  datapoints_to_alarm = var.datapoints_to_alarm
  threshold           = var.threshold
  alarm_actions       = [var.alert_sns_topic]
  alarm_description   = "Canary - ${var.alarm_description}"
  dimensions = {
    CanaryName = var.name
  }
  tags = merge(module.tags.tags, { name = "canary-alarm" })
}

