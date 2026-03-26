provider "aws" {
    region  =  var.aws_region
}

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.Optional_tags
}
 
module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.0"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.0"
  tags    = var.tags
}

locals {
  ec2_ami_upgrade_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
			"Action": [
				"ssm:GetParameter",
				"ssm:PutParameter"
			],
			"Effect": "Allow",
			"Resource": "arn:aws:ssm:us-west-2:750713712981:parameter/ami/linux/test",
			"Sid": "SSMParameterAccess"
		},
    {
      "Sid": "IAM",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:AttachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:GetRolePolicy",
        "iam:GetRole",
        "iam:TagRole",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfilesForRole"
      ],
      "Resource": "arn:aws:iam::750713712981:role/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:CreateFunction",
        "lambda:UpdateFunctionCode",
        "lambda:UpdateFunctionConfiguration",
        "lambda:GetFunctionConfiguration",
        "iam:PassRole"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowEventBridgeToInvokeLambda",
      "Effect": "Allow",
      "Action": [
        "events:PutTargets",
        "events:PutRule",
        "events:DescribeRule",
        "events:TagResource",
        "events:DeleteRule",
        "events:RemoveTargets",
        "events:ListTagsForResource"
      ],
      "Resource": "arn:aws:events:us-west-2:750713712981:rule/750713712981-parameter-store-update"
    },
    {
      "Sid": "AllowlambdaExecution",
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:us-west-2:750713712981:function:750713712981-ami-upgrade"
    },
    {
      "Sid": "CloudWatchLogsAccess",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:us-west-2:750713712981:*"
    },
    {
      "Sid": "AutoScalingAccess",
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeInstanceRefreshes",
        "autoscaling:UpdateAutoScalingGroup",
        "autoscaling:StartInstanceRefresh",
        "autoscaling:DescribeAutoScalingGroups"
      ],
      "Resource": "*"
    },
    {
      "Sid": "LaunchTemplateAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:CreateLaunchTemplateVersion"
      ],
      "Resource": "arn:aws:ec2:us-west-2:750713712981:launch-template/*"
    },
    {
      "Sid": "StandaloneInstanceAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceAttribute",
        "ec2:DescribeTags",
        "ec2:TerminateInstances",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:RunInstances",
        "ec2:DescribeVolumes"
      ],
      "Resource": "*"
    },
    {
      "Sid": "EBSVolumePermissions",
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:DescribeVolumes",
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    },
    {
      "Sid": "KMSPermissions",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:CreateGrant",
        "kms:GenerateDataKey",
        "kms:DescribeKey"
      ],
      "Resource": "arn:aws:kms:us-west-2:750713712981:key/03cbf668-2183-4140-a87c-5423ecd1da45"
    },
    {
      "Sid": "LambdaS3Access",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::ami-upgrade",
        "arn:aws:s3:::ami-upgrade/*"
      ]
    },
    {
      "Sid": "EC2NetworkInterfacePermissions",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}


EOF
}

data "aws_iam_policy_document" "assume_trusted_aws_principals" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = var.trusted_aws_principals
      type        = "AWS"
    }
  }

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}


module "iam_role" {
  source = "app.terraform.io/pgetech/iam/aws"
  name                  = var.role_name
  trusted_aws_principals = var.trusted_aws_principals
  aws_service           = var.aws_service
  description           = var.description
  path                  = var.path
  force_detach_policies = var.force_detach_policies
  permission_boundary   = var.permission_boundary
  max_session_duration  = var.max_session_duration
  policy_arns           = var.policy_arns
  inline_policy         = [local.ec2_ami_upgrade_policy]
  tags  = merge(module.tags.tags, local.optional_tags)
}

module "lambda_function" {
  source  = "app.terraform.io/pgetech/lambda/aws//modules/lambda_s3_bucket"
  version = "0.1.0"
  function_name                 = "750713712981-ami-upgrade"
  role                          = module.iam_role.arn  # Ensure this is the correct ARN for the execution role
  runtime                       = "python3.9"
  s3_bucket                     = "ami-upgrade"  # Replace with your S3 bucket name
  s3_key                        = "lambda.zip"           # Key to your uploaded ZIP file
  timeout = 900
  publish = true
  handler = "lambda.lambda_handler"
  tags                          = merge(module.tags.tags, local.optional_tags)
  vpc_config_security_group_ids = var.vpc_config_security_group_ids
  vpc_config_subnet_ids         = var.vpc_config_subnet_ids
  environment_variables = {
    variables = {
     EXCLUDED_INSTANCES = join(",", var.excluded_instances)
     EXCLUDED_ASGS = join(",", var.excluded_asgs)
     ASG_CONFIGURATIONS = jsonencode(var.asg_configurations)
    }
    kms_key_arn = var.kms_key_arn
  }    
}

resource "aws_cloudwatch_event_rule" "parameter_store_update" {
    tags  = merge(module.tags.tags, local.optional_tags)
    name = "${var.account_id}-parameter-store-update"
    description = "Trigger lambda when the golden ami parameter is updated"
    event_pattern = jsonencode(
      {
        "detail": {
          "eventName": ["PutParameter"],
          "eventSource": ["ssm.amazonaws.com"],
          "requestParameters": {
            "name": ["/ami/linux/test"]
          },
          "userIdentity": {
            "arn": ["arn:aws:sts::750713712981:assumed-role/CloudAdmin/ATCV@utility.pge.com"]
          }
        },
        "detail-type": ["AWS API Call via CloudTrail"],
        "source": ["aws.ssm"]
      }
    )
}

resource "aws_lambda_alias" "dev_alias" {
  name             = "dev"
  function_name    = module.lambda_function.lambda_arn
  function_version = module.lambda_function.lambda_version
}


resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule = aws_cloudwatch_event_rule.parameter_store_update.name
  target_id = "750713712981-ami-upgrade"
  arn       = aws_lambda_alias.dev_alias.arn
  #tags  = merge(module.tags.tags, local.optional_tags)
}


resource "aws_lambda_permission" "lambda_permission" {
action             = "lambda:InvokeFunction"
function_name = aws_lambda_alias.dev_alias.arn
principal          = "events.amazonaws.com"
source_arn         = aws_cloudwatch_event_rule.parameter_store_update.arn
depends_on = [aws_cloudwatch_event_rule.parameter_store_update]
}
