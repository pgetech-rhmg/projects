###############################################################################
# Tags
###############################################################################

module "tags" {
	source = "git::https://github.com/pgetech/epic-pipeline-module-aws-tags.git?ref=main"

	aws_account_id     = var.aws_account_id
	environment        = var.environment
	appid              = var.appid
	compliance         = var.compliance
	cris               = var.cris
	dataclassification = var.dataclassification
	notify             = var.notify
	order              = var.order
	owner              = var.owner
}


###############################################################################
# EPIC Deployment Role
###############################################################################

data "aws_iam_policy_document" "epic_assume_role" {
	statement {
		effect = "Allow"
		principals {
			type        = "AWS"
			identifiers = [var.epic_service_account]
		}
		actions = ["sts:AssumeRole"]
		condition {
			test     = "ArnLike"
			variable = "aws:PrincipalArn"
			values   = [var.epic_service_role_arn]
		}
	}
}

resource "aws_iam_role" "epic_deployment" {
	name                 = "pge-epic-deployment-role"
	assume_role_policy   = data.aws_iam_policy_document.epic_assume_role.json
	max_session_duration = 3600
	tags                 = module.tags.tags
}


###############################################################################
# Infrastructure Provisioning Policy
###############################################################################

data "aws_iam_policy_document" "epic_infrastructure" {
	# EC2
	statement {
		sid    = "EC2Management"
		effect = "Allow"
		actions = [
			"ec2:*"
		]
		resources = ["*"]
	}

	# VPC
	statement {
		sid    = "VPCManagement"
		effect = "Allow"
		actions = [
			"ec2:*Vpc*",
			"ec2:*Subnet*",
			"ec2:*Gateway*",
			"ec2:*RouteTable*",
			"ec2:*NetworkAcl*",
			"ec2:*SecurityGroup*"
		]
		resources = ["*"]
	}

	# ELB/ALB
	statement {
		sid    = "LoadBalancerManagement"
		effect = "Allow"
		actions = [
			"elasticloadbalancing:*"
		]
		resources = ["*"]
	}

	# S3
	statement {
		sid    = "S3Management"
		effect = "Allow"
		actions = [
			"s3:*"
		]
		resources = ["*"]
	}

	# IAM (limited)
	statement {
		sid    = "IAMManagement"
		effect = "Allow"
		actions = [
			"iam:CreateRole",
			"iam:DeleteRole",
			"iam:GetRole",
			"iam:ListRolePolicies",
			"iam:ListAttachedRolePolicies",
			"iam:AttachRolePolicy",
			"iam:DetachRolePolicy",
			"iam:PutRolePolicy",
			"iam:DeleteRolePolicy",
			"iam:GetRolePolicy",
			"iam:CreateInstanceProfile",
			"iam:DeleteInstanceProfile",
			"iam:GetInstanceProfile",
			"iam:AddRoleToInstanceProfile",
			"iam:RemoveRoleFromInstanceProfile",
			"iam:PassRole",
			"iam:TagRole",
			"iam:UntagRole",
			"iam:CreatePolicy",
			"iam:DeletePolicy",
			"iam:GetPolicy",
			"iam:GetPolicyVersion",
			"iam:ListPolicyVersions",
			"iam:CreatePolicyVersion",
			"iam:DeletePolicyVersion",
			"iam:TagPolicy",
			"iam:UntagPolicy"
		]
		resources = ["*"]
	}

	# CloudFront
	statement {
		sid    = "CloudFrontManagement"
		effect = "Allow"
		actions = [
			"cloudfront:*"
		]
		resources = ["*"]
	}

	# ACM
	statement {
		sid    = "CertificateManagement"
		effect = "Allow"
		actions = [
			"acm:*"
		]
		resources = ["*"]
	}

	# Route53
	statement {
		sid    = "Route53Management"
		effect = "Allow"
		actions = [
			"route53:*"
		]
		resources = ["*"]
	}

	# Secrets Manager
	statement {
		sid    = "SecretsManagement"
		effect = "Allow"
		actions = [
			"secretsmanager:*"
		]
		resources = ["*"]
	}

	# KMS
	statement {
		sid    = "KMSManagement"
		effect = "Allow"
		actions = [
			"kms:Create*",
			"kms:Describe*",
			"kms:Enable*",
			"kms:List*",
			"kms:Put*",
			"kms:Update*",
			"kms:Revoke*",
			"kms:Disable*",
			"kms:Get*",
			"kms:Delete*",
			"kms:ScheduleKeyDeletion",
			"kms:CancelKeyDeletion",
			"kms:Encrypt",
			"kms:Decrypt",
			"kms:GenerateDataKey"
		]
		resources = ["*"]
	}

	# SSM Parameter Store
	statement {
		sid    = "SSMManagement"
		effect = "Allow"
		actions = [
			"ssm:*"
		]
		resources = ["*"]
	}

	# DynamoDB
	statement {
		sid    = "DynamoDBManagement"
		effect = "Allow"
		actions = [
			"dynamodb:*"
		]
		resources = ["*"]
	}

	# CloudWatch Logs
	statement {
		sid    = "CloudWatchManagement"
		effect = "Allow"
		actions = [
			"logs:*"
		]
		resources = ["*"]
	}

	# Lambda
	statement {
		sid    = "LambdaManagement"
		effect = "Allow"
		actions = [
			"lambda:*"
		]
		resources = ["*"]
	}

	# Auto Scaling
	statement {
		sid    = "AutoScalingManagement"
		effect = "Allow"
		actions = [
			"autoscaling:*"
		]
		resources = ["*"]
	}

	# CloudWatch
	statement {
		sid    = "CloudWatchMetrics"
		effect = "Allow"
		actions = [
			"cloudwatch:*"
		]
		resources = ["*"]
	}

	# SNS
	statement {
		sid    = "SNSManagement"
		effect = "Allow"
		actions = [
			"sns:*"
		]
		resources = ["*"]
	}

	# SQS
	statement {
		sid    = "SQSManagement"
		effect = "Allow"
		actions = [
			"sqs:*"
		]
		resources = ["*"]
	}

	# ECS
	statement {
		sid    = "ECSManagement"
		effect = "Allow"
		actions = [
			"ecs:*"
		]
		resources = ["*"]
	}

	# ECR
	statement {
		sid    = "ECRManagement"
		effect = "Allow"
		actions = [
			"ecr:*"
		]
		resources = ["*"]
	}

	# RDS
	statement {
		sid    = "RDSManagement"
		effect = "Allow"
		actions = [
			"rds:*"
		]
		resources = ["*"]
	}
}

resource "aws_iam_role_policy" "epic_infrastructure" {
	name   = "pge-epic-infrastructure-provisioning"
	role   = aws_iam_role.epic_deployment.id
	policy = data.aws_iam_policy_document.epic_infrastructure.json
}


###############################################################################
# Application Deployment Policy
###############################################################################

data "aws_iam_policy_document" "epic_application" {
	# S3 for app artifacts
	statement {
		sid    = "S3ApplicationDeployment"
		effect = "Allow"
		actions = [
			"s3:PutObject",
			"s3:GetObject",
			"s3:DeleteObject",
			"s3:ListBucket"
		]
		resources = ["*"]
	}

	# EC2 for app deployment
	statement {
		sid    = "EC2ApplicationDeployment"
		effect = "Allow"
		actions = [
			"ec2:DescribeInstances",
			"ec2:DescribeInstanceStatus",
			"ec2:StartInstances",
			"ec2:StopInstances",
			"ec2:RebootInstances"
		]
		resources = ["*"]
	}

	# SSM for remote execution
	statement {
		sid    = "SSMApplicationDeployment"
		effect = "Allow"
		actions = [
			"ssm:SendCommand",
			"ssm:GetCommandInvocation",
			"ssm:ListCommands",
			"ssm:ListCommandInvocations"
		]
		resources = ["*"]
	}

	# CloudFront invalidation
	statement {
		sid    = "CloudFrontInvalidation"
		effect = "Allow"
		actions = [
			"cloudfront:CreateInvalidation",
			"cloudfront:GetInvalidation"
		]
		resources = ["*"]
	}
}

resource "aws_iam_role_policy" "epic_application" {
	name   = "pge-epic-application-deployment"
	role   = aws_iam_role.epic_deployment.id
	policy = data.aws_iam_policy_document.epic_application.json
}


###############################################################################
# State Backend Access Policy
###############################################################################

data "aws_iam_policy_document" "epic_state_backend" {
	statement {
		sid    = "S3StateAccess"
		effect = "Allow"
		actions = [
			"s3:ListBucket",
			"s3:GetBucketVersioning"
		]
		resources = ["arn:aws:s3:::pge-epic-terraform-state"]
	}

	statement {
		sid    = "S3ObjectAccess"
		effect = "Allow"
		actions = [
			"s3:GetObject",
			"s3:PutObject",
			"s3:DeleteObject"
		]
		resources = ["arn:aws:s3:::pge-epic-terraform-state/*"]
	}

	statement {
		sid    = "KMSAccess"
		effect = "Allow"
		actions = [
			"kms:Decrypt",
			"kms:Encrypt",
			"kms:GenerateDataKey",
			"kms:DescribeKey"
		]
		resources = ["arn:aws:kms:${var.aws_region}:750713712981:key/*"]
	}
}

resource "aws_iam_role_policy" "epic_state_backend" {
	name   = "pge-epic-state-backend-access"
	role   = aws_iam_role.epic_deployment.id
	policy = data.aws_iam_policy_document.epic_state_backend.json
}