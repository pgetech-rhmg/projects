/*
Rolling EC2 Non Blue-Green Deployment Module

Creates an ALB with single Auto Scaling Group and controlled
AMI automation via SSM + Lambda.

Features:
- AMI selection via SSM catalog
- Partner-safe, fully parameterized inputs

Module: aws/modules/rolling_ec2
Author: PG&E
Created: Jan 20, 2026
*/

locals {
  module_tags = merge(var.tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}


module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

######################################################
########### SECURITY GROUP #############################
#################################################

module "security-group" {
  source      = "app.terraform.io/pgetech/security-group/aws"
  version     = "0.1.2"
  tags        = merge(local.module_tags)
  name        = var.security_group_name
  description = "Shared SG for ALB and ASG"
  vpc_id      = var.vpc_id

  #### Ingress: HTTPS to ALB
  cidr_ingress_rules = var.cidr_ingress_rules

  #### Ingress: ALB ↔ EC2 (self SG)
  security_group_ingress_rules = var.security_group_ingress_rules

  #### Egress
  cidr_egress_rules = var.cidr_egress_rules
}


###############################################################
################ IAM ROLE AND POLICY #####################
###########################################

module "aws_iam_role_bluegreen_testing" {
  source        = "app.terraform.io/pgetech/iam/aws"
  version       = "0.1.1"
  name          = var.bluegreen_iam_role_name
  aws_service   = var.bluegreen_iam_services
  inline_policy = [data.aws_iam_policy_document.bluegreen_testing_combined_policy.json]
  tags          = merge(local.module_tags)
}



resource "aws_iam_instance_profile" "profile" {
  tags = merge(local.module_tags)
  name = var.bluegreen_instance_profile_name
  role = module.aws_iam_role_bluegreen_testing.name

  depends_on = [
    module.aws_iam_role_bluegreen_testing
  ]
}


####################################
###  LOCALS  #################
#############################

locals {
  ami_catalog = try(
    jsondecode(data.aws_ssm_parameter.ami_catalog_param.value),
    []
  )

  ami_count = length(local.ami_catalog)

  latest_ami_id = coalesce(
    try(local.ami_catalog[local.ami_count - 1].ami_id, null),
    data.aws_ssm_parameter.latest_ami.value
  )

  selected_ami_id = (
    var.release_version == "latest"
    ? local.latest_ami_id
    : try(
      one([
        for e in local.ami_catalog : e.ami_id
        if tostring(e.version) == tostring(var.release_version)
      ]),
      local.latest_ami_id
    )
  )
}



####################################################
#####SSM PARAMETER ##################
##################################################

data "aws_ssm_parameter" "latest_ami" {
  name = var.latest_ami_param_name
}

module "ssm_ami_catalog" {
  source      = "app.terraform.io/pgetech/ssm/aws"
  version     = "0.1.2"
  tags        = merge(local.module_tags)
  name        = var.ami_catalog_param_name
  description = "Non Blue/Green AMI version catalog (managed by Lambda)"
  type        = "String"
  value       = "[]" # Initial empty array; Lambda appends entries
}


data "aws_ssm_parameter" "ami_catalog_param" {
  name       = module.ssm_ami_catalog.name
  depends_on = [module.ssm_ami_catalog]
}



#####################################
# ALB (SINGLE TARGET GROUP)
#####################################
module "alb_baseline" {
  source  = "app.terraform.io/pgetech/alb/aws//modules/internal_alb_bluegreen"
  version = "0.1.3"

  tags            = merge(local.module_tags)
  alb_name        = var.alb_name
  bucket_name     = var.lambda_bucket_name
  vpc_id          = var.vpc_id
  subnets         = var.subnet_ids
  security_groups = [module.security-group.sg_id]

  lb_listener_https = var.lb_listener_https

  lb_target_group = var.lb_target_group
}

#####################################
# ASG (ROLLING UPDATE)
#####################################
module "asg" {
  source  = "app.terraform.io/pgetech/asg/aws"
  version = "0.1.3"

  asg_name             = var.asg_name
  asg_min_size         = var.min_size
  asg_max_size         = var.max_size
  asg_desired_capacity = var.desired_capacity

  image_id             = local.selected_ami_id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.profile.name
  user_data            = base64encode(templatefile("${path.module}/user_data.tpl", {}))

  asg_vpc_zone_identifier = var.subnet_ids
  asg_target_group_arns   = [module.alb_baseline.target_group_arn[var.lb_target_group[0].name]]

  autoscaling_policy_name = var.autoscaling_policy_name
  policy_type             = var.asg_policy_type
  scaling_adjustment      = var.asg_scaling_adjustment
  adjustment_type         = var.asg_adjustment_type
  cooldown                = var.asg_cooldown

  create_launch_template  = var.create_launch_template
  launch_template_name    = var.launch_template_name
  launch_template_version = var.launch_template_version
  update_default_version = var.update_default_version
  network_interfaces = [
    {
      device_index                = var.nic_device_index
      subnet_id                   = var.subnet_ids[0]
      associate_public_ip_address = var.associate_public_ip_address
      security_groups             = [module.security-group.sg_id]
    }
  ]

  tags = merge(local.module_tags)
}

###################################################
###########S3 Bucket##############
##########################################

module "s3_bucket" {
  source      = "app.terraform.io/pgetech/s3/aws"
  version     = "0.1.3"
  bucket_name = var.lambda_bucket_name
  acl         = "private"
  policy      = templatefile("${path.module}/alb_logs_policy.json", { account_num = var.account_num, bucket_name = var.lambda_bucket_name, log_prefix = var.alb_log_prefix })
  tags        = merge(local.module_tags)
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_package"
  output_path = "${path.module}/lambda_package/lambda.zip"
}

resource "aws_s3_object" "lambda_zip" {
  bucket = module.s3_bucket.id
  key    = "lambda.zip"

  source = data.archive_file.lambda_zip.output_path
  depends_on = [data.archive_file.lambda_zip]
  tags        = merge(local.module_tags)
}

#############################################################
##############LAMBDA MODULES##########
######################################################

module "lambda_s3_bucket" {
  source  = "app.terraform.io/pgetech/lambda/aws//modules/lambda_s3_bucket"
  version = "0.1.3"

  function_name     = var.lambda_function_name
  role              = module.aws_iam_role_bluegreen_testing.arn
  runtime           = var.lambda_runtime
  s3_bucket         = module.s3_bucket.id
  s3_key            = aws_s3_object.lambda_zip.key
  s3_object_version = aws_s3_object.lambda_zip.version_id
  source_code_hash  = data.archive_file.lambda_zip.output_base64sha256
  timeout           = var.lambda_timeout
  publish           = var.lambda_publish

  handler = var.lambda_handler
  tags    = merge(local.module_tags)

  vpc_config_security_group_ids = [module.security-group.sg_id]
  vpc_config_subnet_ids         = var.subnet_ids

  environment_variables = {
    variables = {
      TFC_ORG_NAME           = var.tfc_org_name
      ENABLE_AMI_AUTOMATION  = tostring(var.enable_ami_automation)
      AUTO_APPLY_AMI_UPDATES = tostring(var.auto_apply_ami_updates)
    }
    kms_key_arn = var.kms_key_arn
  }
}

resource "aws_cloudwatch_event_rule" "parameter_store_update" {
  tags        = merge(local.module_tags)
  name        = "${var.account_num}-parameter-store-update"
  description = var.parameter_store_event_description

  event_pattern = jsonencode({
    "detail" : {
      "eventName" : ["PutParameter"],
      "eventSource" : ["ssm.amazonaws.com"],
      "requestParameters" : {
        "name" : [var.latest_ami_param_name]
      }
    },
    "detail-type" : ["AWS API Call via CloudTrail"],
    "source" : ["aws.ssm"]
  })
}

resource "aws_lambda_alias" "dev_alias" {
  name             = var.lambda_alias_name
  function_name    = module.lambda_s3_bucket.lambda_arn
  function_version = module.lambda_s3_bucket.lambda_version
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.parameter_store_update.name
  target_id = var.lambda_function_name
  arn       = aws_lambda_alias.dev_alias.arn
}


module "lambda_log_group" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.1.3"

  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.retention_in_days
  tags              = local.module_tags
}

resource "aws_lambda_function_event_invoke_config" "lambda_retry" {
  function_name                = module.lambda_s3_bucket.lambda_arn
  maximum_retry_attempts       = var.lambda_max_retry_attempts
  maximum_event_age_in_seconds = var.lambda_max_event_age_seconds

  lifecycle {
    ignore_changes = [function_name]
  }

  depends_on = [aws_lambda_alias.dev_alias]
}

resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_alias.dev_alias.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.parameter_store_update.arn

  lifecycle {
    ignore_changes = [function_name]
  }

  depends_on = [
    module.aws_iam_role_bluegreen_testing,
    module.lambda_s3_bucket,
    aws_cloudwatch_event_rule.parameter_store_update
  ]
}

module "secretsmanager" {
  source  = "app.terraform.io/pgetech/secretsmanager/aws"
  version = "0.1.3"
  secretsmanager_name        = var.secretsmanager_name
  secretsmanager_description = var.secretsmanager_description         
  secret_string              = var.secret_string
  secret_version_enabled     = var.secret_version_enabled
  tags        = merge(local.module_tags)
}