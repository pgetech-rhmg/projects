/*
Blue-Green EC2 Deployment Module

Creates an ALB with Blue and Green Auto Scaling Groups and supports
weighted traffic shifting, AMI catalog–based rollouts, and controlled
AMI automation via SSM + Lambda.

Features:
- ALB with weighted target group routing (blue/green)
- ASG Blue & Green with launch templates
- AMI selection via SSM catalog (N / N-1 logic)
- Partner-safe, fully parameterized inputs

Module: aws/modules/blue-green
Author: PG&E
Created: Jan 02, 2026
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
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.1"
  name        = var.bluegreen_iam_role_name
  aws_service = var.bluegreen_iam_services
  inline_policy = [data.aws_iam_policy_document.bluegreen_testing_combined_policy.json]
  tags        = merge(local.module_tags)
}



resource "aws_iam_instance_profile" "profile" {
  tags        = merge(local.module_tags)
  name = var.bluegreen_instance_profile_name
  role = module.aws_iam_role_bluegreen_testing.name

  depends_on = [
    module.aws_iam_role_bluegreen_testing
  ]
}

####################################################
#####SSM PARAMETER ##################
##################################################

data "aws_ssm_parameter" "latest_ami" {
  name = var.latest_ami_param_name
}

module "ssm_ami_catalog" {
  source  = "app.terraform.io/pgetech/ssm/aws"
  version = "0.1.2"
  tags        = merge(local.module_tags)
  name        = var.ami_catalog_param_name
  description = "Blue/Green AMI version catalog (managed by Lambda)"
  type        = "String"
  value       = "[]" # Initial empty array; Lambda appends entries
}


data "aws_ssm_parameter" "ami_catalog_param" {
  name       = module.ssm_ami_catalog.name
  depends_on = [module.ssm_ami_catalog]
}



####################################
###  LOCALS  #################
#############################

locals {
  # ========= Weighted listener (unchanged shape) =========
  lb_listener_rule_https = {
    weight_split = {
      lb_listener_https_port = "443"
      priority               = 10
      conditions             = [{ path_pattern = ["*"] }]
      actions = [
        {
          type = "weighted-forward"
          target_group = [
            { target_group_name = "blue-tg", weight = 100 - var.green_percent },
            { target_group_name = "green-tg", weight = var.green_percent }
          ]
          stickiness = { enabled = true, duration = 300 }
        }
      ]
    }
  }

  # ========= AMI catalog selection =========
  ami_catalog = try(jsondecode(data.aws_ssm_parameter.ami_catalog_param.value), [])
  _len        = length(local.ami_catalog)

  # Green (N)
  selected_ami_obj = (
    var.release_version == "latest"
    ? (
      local._len > 0
      ? local.ami_catalog[local._len - 1]
      : null
    )
    : try(
      one([
        for e in local.ami_catalog : e
        if tostring(e.version) == tostring(var.release_version)
      ]),
      null
    )
  )

  selected_ami_id = coalesce(
    try(local.selected_ami_obj.ami_id, null),
    data.aws_ssm_parameter.latest_ami.value
  )

  # Blue (N-1 of latest)
  _prev_of_latest_ami_id = (
    local._len > 1
    ? local.ami_catalog[local._len - 2].ami_id
    : null
  )

  # Blue (N-1 of selected)
  _selected_idx = (
    local.selected_ami_obj == null
    ? -1
    : (
      contains(local.ami_catalog[*].version, local.selected_ami_obj.version)
      ? index(local.ami_catalog[*].version, local.selected_ami_obj.version)
      : -1
    )
  )

  _prev_of_selected_ami_id = (
    local._selected_idx > 0
    ? local.ami_catalog[local._selected_idx - 1].ami_id
    : null
  )

  # Final Blue AMI based on mode
  blue_ami_id = (
    var.blue_mode == "relative_to_selected"
    ? local._prev_of_selected_ami_id
    : var.blue_mode == "pinned" && trim(var.blue_pinned_ami_id) != ""
    ? var.blue_pinned_ami_id
    : local._prev_of_latest_ami_id != null
    ? local._prev_of_latest_ami_id
    : null
  )
}


#####################################################
#######  ALB  ########################################
############################################################

module "alb_baseline" {
  source  = "app.terraform.io/pgetech/alb/aws//modules/internal_alb_bluegreen"
  version = "0.1.3"

  tags        = merge(local.module_tags)
  alb_name        = var.alb_name
  bucket_name     = var.lambda_bucket_name
  vpc_id          = var.vpc_id
  subnets         = var.subnet_ids
  security_groups = [module.security-group.sg_id]

  lb_listener_https = var.lb_listener_https
  lb_listener_rule_https = local.lb_listener_rule_https

  lb_target_group = var.lb_target_group
}



#####################################
##### ASG Modules #####################
#################################

module "asg_blue" {
  source                  = "app.terraform.io/pgetech/asg/aws"
  version                 = "0.1.3"
  tags        = merge(local.module_tags)

  asg_name                = var.blue_asg_name
  asg_min_size            = var.blue_min_size
  asg_max_size            = var.blue_max_size
  asg_desired_capacity    = var.blue_desired_capacity
  asg_force_delete        = var.asg_force_delete

  autoscaling_policy_name = var.blue_autoscaling_policy_name
  policy_type             = var.asg_policy_type
  scaling_adjustment      = var.asg_scaling_adjustment
  adjustment_type         = var.asg_adjustment_type
  cooldown                = var.asg_cooldown

  create_launch_template  = var.create_launch_template
  launch_template_name    = var.blue_launch_template_name
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

  image_id                = coalesce(local.blue_ami_id, data.aws_ssm_parameter.latest_ami.value)
  instance_type           = var.instance_type
  user_data               = base64encode(templatefile("${path.module}/user_data.tpl", {}))
  asg_vpc_zone_identifier = var.subnet_ids
  asg_target_group_arns   = [module.alb_baseline.target_group_arn[var.lb_target_group[0].name]]
  iam_instance_profile    = aws_iam_instance_profile.profile.name
}

module "asg_green" {
  source                  = "app.terraform.io/pgetech/asg/aws"
  version                 = "0.1.3"
  tags        = merge(local.module_tags)

  asg_name                = var.green_asg_name
  asg_min_size            = var.green_min_size
  asg_max_size            = var.green_max_size
  asg_desired_capacity    = var.green_desired_capacity
  asg_force_delete        = var.asg_force_delete

  autoscaling_policy_name = var.green_autoscaling_policy_name
  policy_type             = var.asg_policy_type
  scaling_adjustment      = var.asg_scaling_adjustment
  adjustment_type         = var.asg_adjustment_type
  cooldown                = var.asg_cooldown

  create_launch_template  = var.create_launch_template
  launch_template_name    = var.green_launch_template_name
  launch_template_version = var.launch_template_version
  update_default_version = var.update_default_version

  image_id                = local.selected_ami_id
  instance_type           = var.instance_type
  user_data               = base64encode(templatefile("${path.module}/user_data.tpl", {}))
  asg_vpc_zone_identifier = var.subnet_ids
  asg_target_group_arns   = [module.alb_baseline.target_group_arn[var.lb_target_group[1].name]]

  network_interfaces = [
    {
      device_index                = var.nic_device_index
      subnet_id                   = var.subnet_ids[0]
      associate_public_ip_address = var.associate_public_ip_address
      security_groups             = [module.security-group.sg_id]
    }
  ]

  iam_instance_profile = aws_iam_instance_profile.profile.name
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

module "lambda_lambda_s3_bucket" {
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
  tags        = merge(local.module_tags)

  vpc_config_security_group_ids = [module.security-group.sg_id]
  vpc_config_subnet_ids         = var.subnet_ids

  environment_variables = {
    variables = {
      TFC_ORG_NAME = var.tfc_org_name
      ENABLE_AMI_AUTOMATION = tostring(var.enable_ami_automation)
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
  function_name    = module.lambda_lambda_s3_bucket.lambda_arn
  function_version = module.lambda_lambda_s3_bucket.lambda_version
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
  function_name                = module.lambda_lambda_s3_bucket.lambda_arn
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
    module.lambda_lambda_s3_bucket,
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
