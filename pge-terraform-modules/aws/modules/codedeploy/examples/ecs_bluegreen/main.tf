/*
* # AWS ECS with FARGATE usage example
* Terraform module which creates SAF2.0 ECS with FARGATE in AWS.
*/
#
# Filename    : modules/ecs/examples/ecs_fargate/main.tf
# Date        : 31 July 2022
# Author      : Tekyantra
# Description : The Terraform usage example creates AWS ECS FARGATE


locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  aws_role           = var.aws_role
  kms_role           = var.kms_role
  LogGroupNamePrefix = var.log_group_name_prefix
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
################################################################################
# Supporting Resources
################################################################################

data "aws_ssm_parameter" "vpc_id" {
  name = var.parameter_vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.parameter_subnet_id1_name
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.parameter_subnet_id2_name
}

data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "jfrog_credentials" {
  name = var.jfrog_credentials
}

module "ecs_fargate" {
  source  = "app.terraform.io/pgetech/ecs/aws//modules/ecs_fargate"
  version = "0.1.0"

  cluster_name                          = var.cluster_name
  log_cloud_watch_log_group_name        = module.log_group.cloudwatch_log_group_name
  setting_value                         = var.setting_value
  ecs_cluster_capacity_providers        = var.ecs_cluster_capacity_providers
  ecs_default_cluster_capacity_provider = var.ecs_default_cluster_capacity_provider

  tags = merge(module.tags.tags, local.optional_tags)
}

module "ecs_task_definition" {
  source  = "app.terraform.io/pgetech/ecs/aws//modules/ecs_task_definition"
  version = "0.1.1"

  family_service           = var.family_service
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = module.ecs_iam_role.arn
  task_role_arn            = module.ecs_iam_role.arn
  container_definition     = jsonencode([module.container.json_map_object])
  tags                     = merge(module.tags.tags, local.optional_tags)
}


module "container" {
  source  = "app.terraform.io/pgetech/ecs/aws//modules/ecs_container_definition"
  version = "0.1.1"

  container_name               = var.container_name
  container_image              = var.container_image
  container_memory             = var.container_memory
  container_cpu                = var.container_cpu
  command                      = var.command
  container_memory_reservation = var.container_memory_reservation
  essential                    = var.essential
  readonly_root_filesystem     = var.readonly_root_filesystem
  environment                  = var.container_environment
  privileged                   = var.privileged
  extra_hosts                  = var.extra_hosts
  hostname                     = var.hostname
  pseudo_terminal              = var.pseudo_terminal
  interactive                  = var.interactive
  port_mappings                = var.port_mappings
  wiz_container_name           = var.wiz_container_name
  wiz_container_image          = var.wiz_container_image
  log_configuration = {
    logDriver = var.logDriver
    options = {
      awslogs-region        = var.awslogs_region
      awslogs-group         = var.awslogs_group
      awslogs-group         = var.awslogs_group
      awslogs-stream-prefix = var.awslogs_stream_prefix
      awslogs-create-group  = "true"
    }
  }
  repository_Credentials = var.docker_registry == "JFROG" ? { credentialsParameter = data.aws_secretsmanager_secret.jfrog_credentials.arn } : null

  #   repository_Credentials = {
  #     credentialsParameter = var.credentials_parameter
  # 
  #   }

}

module "ecs_service" {
  source  = "app.terraform.io/pgetech/ecs/aws//modules/ecs_service"
  version = "0.1.1"

  service_name                    = var.service_name
  ecs_service_cluster_id          = module.ecs_fargate.ecs_cluster_id
  ecs_service_task_definition_arn = module.ecs_task_definition.ecs_task_definition_arn
  ecs_service_launch_type         = var.ecs_service_launch_type
  deployment_type                 = var.deployment_type
  target_group_arn                = module.alb.target_group_arn[var.lb_target_group_name]
  load_balancer                   = var.load_balancer
  subnets                         = [data.aws_ssm_parameter.subnet_id2.value]
  security_groups                 = [module.security_group_ecs.sg_id]
  desired_count                   = var.desired_count
  tags                            = merge(module.tags.tags, local.optional_tags)
  depends_on = [
    module.alb,
  ]
}

module "ecs_account_setting_default" {
  source  = "app.terraform.io/pgetech/ecs/aws//modules/ecs_account_setting_default"
  version = "0.1.0"

  ecs_account_name          = var.ecs_account_name
  ecs_account_setting_value = var.ecs_account_setting_value
}

#security group for ecs
module "security_group_ecs" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = var.ecs_sg_name
  description        = var.ecs_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.ecs_cidr_ingress_rules
  cidr_egress_rules  = var.ecs_cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}

# #iam for ecs
# module "ecs_iam_role" {
#   source      = "app.terraform.io/pgetech/iam/aws//modules/iam_role"
#   version     = "0.1.0"
#   name        = var.ecs_iam_name
#   aws_service = var.ecs_iam_aws_service
#   tags        = merge(module.tags.tags, local.optional_tags)
# 
#   #inline_policy
#   inline_policy = [templatefile("${path.module}/inline_policy.json", {
#     secretmanager_kms_key = var.secretmanager_kms_key
#     secretmanager_arn     = var.secretmanager_arn
#   })]
#   policy_arns = var.ecs_iam_policy_arns
# }

module "secretsmanager_kms_key" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.2"

  name        = join("-", [var.service_name, "kms-secretsmanager"])
  description = "Secretsmanager kms key"
  policy = templatefile("${path.module}/kms_user_policy.json",
    {
      account_num = data.aws_caller_identity.current.account_id
      ecs_iam     = module.ecs_iam_role.name
      aws_region  = var.aws_region
  })
  aws_role = local.aws_role
  kms_role = local.kms_role
  tags     = merge(module.tags.tags, local.optional_tags)
}

#iam for ecs
module "ecs_iam_role" {
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.1"
  name        = var.ecs_iam_name
  aws_service = var.ecs_iam_aws_service
  tags        = merge(module.tags.tags, local.optional_tags)

  #inline_policy
  inline_policy = [templatefile("${path.module}/inline_policy.json",
    {
      #       jfrog_secret_arn = data.aws_secretsmanager_secret.jfrog_credentials.arn
      kms_key_arn = module.secretsmanager_kms_key.key_arn
  })]
  policy_arns = var.ecs_iam_policy_arns
}

module "alb" {
  source      = "app.terraform.io/pgetech/alb/aws"
  version     = "0.1.2"
  alb_name    = var.alb_name
  bucket_name = var.alb_s3_bucket_name

  security_groups   = [module.security_group_alb.sg_id]
  subnets           = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  lb_listener_http  = var.lb_listener_http
  tags              = merge(module.tags.tags, local.optional_tags)
  lb_listener_https = var.lb_listener_https
  certificate_arn   = var.certificate_arn
  lb_target_group = [
    {
      name        = var.lb_target_group_name
      target_type = var.target_group_target_type
      port        = var.target_group_port
      protocol    = var.target_group_protocol
      health_check = [{
        enabled             = true
        interval            = 10
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 10
      }]
      stickiness = [{
        cookie_duration = 86400
        enabled         = true
        type            = "lb_cookie"
      }]
    },
    {
      name        = var.lb_target_group_name_test
      target_type = var.target_group_target_type
      port        = var.target_group_port_test
      protocol    = var.target_group_protocol
      health_check = [{
        enabled             = true
        interval            = 10
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 10
      }]
      stickiness = [{
        cookie_duration = 86400
        enabled         = true
        type            = "lb_cookie"
      }]
    }
  ]
  vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "s3" {
  source      = "app.terraform.io/pgetech/s3/aws"
  version     = "0.1.1"
  bucket_name = var.alb_s3_bucket_name
  policy      = data.template_file.s3_policy.rendered
  tags        = module.tags.tags
}

data "template_file" "s3_policy" {
  template = file("${path.module}/${var.policy}")
  vars = {
    bucket_name = var.alb_s3_bucket_name
    account_num = data.aws_caller_identity.current.account_id
    aws_role    = var.aws_role
  }
}



#security group for alb
module "security_group_alb" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = var.alb_sg_name
  description        = var.alb_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.alb_cidr_ingress_rules
  cidr_egress_rules  = var.alb_cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}

#security group for vpc_endpoint
module "security_group_vpc_endpoint" {
  source             = "app.terraform.io/pgetech/security-group/aws"
  version            = "0.1.1"
  name               = var.sg_name
  description        = var.sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules
  cidr_egress_rules  = var.cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}


#cloudwatch for ecs
module "log_group" {
  source      = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version     = "0.1.3"
  name_prefix = local.LogGroupNamePrefix
  tags        = merge(module.tags.tags, local.optional_tags)
}

# Create Application and Deployment group for CodeDeploy for Bluegreen deployment
module "ecs_codedeploy_app" {
  source                          = "../.."
  depends_on                      = [module.alb, module.ecs_service]
  codedeploy_app_name             = var.codedeploy_application_name
  codedeploy_app_compute_platform = var.codedeploy_app_compute_platform
  tags                            = merge(module.tags.tags, local.optional_tags)
}

module "ecs_codedeploy_deployment_group" {
  source = "../../modules/deployment_group"


  depends_on                        = [module.ecs_codedeploy_app, module.ecs_service, module.alb]
  deployment_group_app_name         = var.codedeploy_application_name
  deployment_group_name             = var.codedeploy_deployment_groupname
  deployment_config_name            = var.deployment_config_name
  deployment_group_service_role_arn = var.deployment_group_service_role_arn
  tags                              = merge(module.tags.tags, local.optional_tags)

  auto_rollback_configuration_enabled = var.auto_rollback_configuration_enabled
  auto_rollback_configuration_events  = var.auto_rollback_configuration_events

  blue_green_deployment_config = [{
    deployment_ready_option = [{
      action_on_timeout    = var.action_on_timeout
      wait_time_in_minutes = var.wait_time_in_minutes
    }]
    terminate_blue_instances_on_deployment_success = [{
      action                           = var.action
      termination_wait_time_in_minutes = var.termination_wait_time_in_minutes
    }]
  }]
  deployment_style = [{
    deployment_option = var.deployment_option
    deployment_type   = var.codedeploy_deployment_type
  }]
  ecs_service = [{
    cluster_name = var.cluster_name
    service_name = var.service_name
  }]

  load_balancer_info = [{
    target_group_pair_info = [{
      prod_traffic_route = [{
        listener_arns = [module.alb.listener_https_arn[var.target_group_port]]
      }]

      blue_target_group = [{
        name = var.lb_target_group_name
      }]

      green_target_group = [{
        name = var.lb_target_group_name_test
      }]
      test_traffic_route = [{
        listener_arns = [module.alb.listener_https_arn[var.target_group_port_test]]
      }]
    }]
  }]

}



