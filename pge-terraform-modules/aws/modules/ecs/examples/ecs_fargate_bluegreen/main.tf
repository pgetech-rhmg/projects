/*
* # AWS ECS with FARGATE usage example
* Terraform module which creates SAF2.0 ECS with FARGATE Bluegreen in AWS.
*/
#
# Filename    : modules/ecs/examples/ecs_fargate_bluegreen/main.tf
# Date        : 03 January 2023
# Author      : Tekyantra
# Description : The Terraform usage example creates AWS ECS with FARGATE Bluegreen


locals {
  AppID                 = var.AppID
  Environment           = var.Environment
  DataClassification    = var.DataClassification
  CRIS                  = var.CRIS
  Notify                = var.Notify
  Owner                 = var.Owner
  Compliance            = var.Compliance
  Order                 = var.Order
  optional_tags         = var.optional_tags
  wiz_secret_credential = jsondecode(data.aws_secretsmanager_secret_version.wiz_secret_version.secret_string)
  aws_role              = var.aws_role
  custom_domain_name    = var.custom_domain_name
  base_domain_name      = regex("(.*).(alerts.pge.com|ccare.pge.com|cloudapi.pge.com|dc.pge.com|dcs.pge.com|digitalcatalyst.pge.com|io.pge.com|ss-dev.pge.com|ss.pge.com|pgepspsmap.com|pgepspsmaps.com|pgecloud.net|nonprod.pge.com|np-dev.pge.com|nonprod.pge.com|np-dev-api.pge.com|np-dev.pge.com)", var.custom_domain_name)[1]
  LogGroupNamePrefix    = join("/", ["/aws/ecs", var.service_name])
}



module "secretsmanager_kms_key" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.2"

  name        = join("-", [var.service_name, "kms-secretsmanager-new"])
  description = "Secretsmanager kms key"
  policy = templatefile("${path.module}/kms_user_policy.json",
    {
      account_num = data.aws_caller_identity.current.account_id
      ecs_iam     = module.ecs_iam_role.name
      aws_region  = var.aws_region
  })
  aws_role = local.aws_role
  kms_role = module.ecs_iam_role.name
  tags     = merge(module.tags.tags, local.optional_tags)
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


module "ecs_fargate" {
  source = "../../modules/ecs_fargate"

  cluster_name                          = var.cluster_name
  log_cloud_watch_log_group_name        = module.log_group.cloudwatch_log_group_name
  setting_value                         = var.setting_value
  ecs_cluster_capacity_providers        = var.ecs_cluster_capacity_providers
  ecs_default_cluster_capacity_provider = var.ecs_default_cluster_capacity_provider
  kms_key_id                            = null # replace with module.secretsmanager_kms_key.key_arn, after key creation
  log_execute_command                   = "OVERRIDE"
  tags                                  = merge(module.tags.tags, local.optional_tags)
}

module "ecs_task_definition" {
  source = "../../modules/ecs_task_definition"

  family_service           = join("-", [var.service_name, "ecs-task-definition"])
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = module.ecs_iam_role.arn
  task_role_arn            = module.ecs_iam_role.arn
  container_definition     = jsonencode([module.container.json_map_object, module.ecs_fargate.wiz_container_definition_json])
  tags                     = merge(module.tags.tags, local.optional_tags)
  runtime_platform         = var.runtime_platform
  volumes                  = var.volumes
}


module "container" {
  source = "../../modules/ecs_container_definition"

  container_name               = var.container_name
  container_image              = var.container_image
  container_memory             = var.container_memory
  container_cpu                = var.container_cpu
  command                      = var.command
  container_memory_reservation = var.container_memory_reservation
  essential                    = var.essential
  readonly_root_filesystem     = var.readonly_root_filesystem
  privileged                   = var.privileged
  extra_hosts                  = var.extra_hosts
  hostname                     = var.hostname
  pseudo_terminal              = var.pseudo_terminal
  interactive                  = var.interactive
  port_mappings                = var.port_mappings
  entrypoint                   = var.entrypoint
  healthcheck                  = var.healthcheck
  working_directory            = var.working_directory
  environment_files            = var.environment_files
  environment = [
    {
      "name" : "API_CLIENT_ID",
      "value" : local.wiz_secret_credential["WIZ_CLIENT_ID"]
    },
    {
      "name" : "API_CLIENT_SECRET",
      "value" : local.wiz_secret_credential["WIZ_CLIENT_SECRET"]
    }
  ]
  linux_parameters = {
    capabilities = {
      add  = ["SYS_PTRACE"]
      drop = []
    }
    devices            = []
    initProcessEnabled = false
    maxSwap            = null
    sharedMemorySize   = null
    swappiness         = null
    tmpfs              = null
  }
  ulimits = var.ulimits
  container_depends_on = [{
    "containerName" : "wiz-sensor",
    "condition" : "COMPLETE"
  }]
  links                  = var.links
  docker_labels          = var.docker_labels
  start_timeout          = var.start_timeout
  stop_timeout           = var.stop_timeout
  system_controls        = var.system_controls
  disable_networking     = var.disable_networking
  firelens_configuration = var.firelens_configuration
  mount_points           = var.mount_points
  dns_servers            = var.dns_servers
  dns_search_domains     = var.dns_search_domains
  log_configuration = {
    logDriver = var.logDriver
    options = {
      awslogs-region        = var.aws_region
      awslogs-group         = module.log_group.cloudwatch_log_group_name
      awslogs-stream-prefix = join("-", [var.container_name, "logs-stream"])
      awslogs-create-group  = "true"
    }
  }
  volumes_from = [
    {
      "sourceContainer" : module.ecs_fargate.wiz_container_name
      "readOnly" : false
    }
  ]
  repository_Credentials = var.docker_registry == "JFROG" ? { credentialsParameter = module.secretsmanager.arn } : null
}

data "aws_ecs_task_definition" "ecs_task_definition" {
  task_definition = module.ecs_task_definition.ecs_task_definition_family
}

module "ecs_service" {
  source = "../../modules/ecs_service_bluegreen"

  service_name           = var.service_name
  ecs_service_cluster_id = module.ecs_fargate.ecs_cluster_id

  # The task-definition revision changes outside of the terraform code(manually or by CICD). This will prevent the task-definition revision version change back to the original value.
  ecs_service_task_definition_arn = "${module.ecs_task_definition.ecs_task_definition_family}:${max(module.ecs_task_definition.ecs_task_definition_revision, data.aws_ecs_task_definition.ecs_task_definition.revision)}"

  ecs_service_launch_type       = var.ecs_service_launch_type
  deployment_type               = var.deployment_type
  target_group_arn              = module.alb.target_group_arn[var.lb_target_group_name]
  load_balancer                 = var.load_balancer
  availability_zone_rebalancing = var.availability_zone_rebalancing
  subnets                       = [data.aws_ssm_parameter.subnet_id2.value]
  security_groups               = [module.security_group_ecs.sg_id]
  desired_count                 = var.desired_count
  tags                          = merge(module.tags.tags, local.optional_tags)
  depends_on = [
    module.alb, module.ecs_fargate, module.ecs_task_definition
  ]
}

#Secret Manager
module "secretsmanager" {
  source                     = "app.terraform.io/pgetech/secretsmanager/aws"
  version                    = "0.1.3"
  secretsmanager_name        = join("-", [var.service_name, "secretsmanager"])
  secretsmanager_description = var.secretsmanager_description
  kms_key_id                 = null                        # replace with module.secretsmanager_kms_key.key_arn, after key creation
  recovery_window_in_days    = var.recovery_window_in_days #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
  secret_string              = data.aws_secretsmanager_secret_version.jfrog_credential.secret_string
  secret_version_enabled     = var.secret_version_enabled
  tags                       = merge(module.tags.tags, local.optional_tags)
}

module "ecs_account_setting_default" {
  source = "../../modules/ecs_account_setting_default"

  ecs_account_name          = var.ecs_account_name
  ecs_account_setting_value = var.ecs_account_setting_value
}

#security group for ecs
module "security_group_ecs" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = join("-", [var.service_name, "ecs-security-group"])
  description        = var.ecs_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.ecs_cidr_ingress_rules
  cidr_egress_rules  = var.ecs_cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}




#iam for ecs
module "ecs_iam_role" {
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.1"
  name        = join("-", [var.service_name, "iam-role"])
  aws_service = var.ecs_iam_aws_service
  tags        = merge(module.tags.tags, local.optional_tags)

  #inline_policy
  inline_policy = [templatefile("${path.module}/inline_policy.json",
    {
      jfrog_secret_arn = data.aws_secretsmanager_secret.jfrog_credential.arn
      kms_key_arn      = module.secretsmanager_kms_key.key_arn
  })]
  policy_arns = var.ecs_iam_policy_arns
}

module "alb" {
  source  = "app.terraform.io/pgetech/alb/aws//modules/internal_alb_bluegreen"
  version = "0.1.2"

  alb_name    = join("-", [var.service_name, "alb"])
  bucket_name = join("-", [var.service_name, "s3-bucket"])

  security_groups  = [module.security_group_alb.sg_id]
  subnets          = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  lb_listener_http = var.lb_listener_http
  tags             = merge(module.tags.tags, local.optional_tags)
  lb_listener_https = [
    {
      port              = var.https_port
      protocol          = var.https_protocol
      certificate_arn   = module.acm_public_certificate.acm_certificate_arn
      target_group_name = var.lb_target_group_name
      type              = var.https_type
    },
    {
      port              = var.https_port1
      protocol          = var.https_protocol
      certificate_arn   = module.acm_public_certificate.acm_certificate_arn
      target_group_name = var.lb_target_group_name_test
      type              = var.https_type
    }
  ]
  certificate_arn = [

    {

      lb_listener_https_port = var.https_port
      certificate_arn        = module.acm_public_certificate.acm_certificate_arn

  }]

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
        enabled         = false
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
        enabled         = false
        type            = "lb_cookie"
      }]
    }
  ]
  vpc_id = data.aws_ssm_parameter.vpc_id.value
}

# S3 bucket for ALB access logs
module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = join("-", [var.service_name, "s3-bucket"])
  policy = templatefile("${path.module}/${var.policy}", {
    bucket_name = join("-", [var.service_name, "s3-bucket"])
    account_num = data.aws_caller_identity.current.account_id
    aws_role    = local.aws_role
  })
  tags = merge(module.tags.tags, local.optional_tags)

}

#security group for alb
module "security_group_alb" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = join("-", [var.service_name, "alb-sg"])
  description        = var.alb_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.alb_cidr_ingress_rules
  cidr_egress_rules  = var.alb_cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}

#cloudwatch for ecs
module "log_group" {
  source            = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version           = "0.1.3"
  name_prefix       = local.LogGroupNamePrefix
  kms_key_id        = null # replace with module.secretsmanager_kms_key.key_arn, after key creation
  retention_in_days = var.retention_in_days
  tags              = merge(module.tags.tags, local.optional_tags)
}

module "acm_public_certificate" {
  source  = "app.terraform.io/pgetech/acm/aws"
  version = "0.1.2"

  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }

  acm_domain_name = local.custom_domain_name
  tags            = merge(module.tags.tags, local.optional_tags)
}

resource "aws_route53_record" "private_cname_dns" {
  provider        = aws.r53
  allow_overwrite = true
  name            = var.custom_domain_name
  records         = [module.alb.lb_dns_name]
  ttl             = 300
  type            = "CNAME"
  zone_id         = data.aws_route53_zone.private_zone.zone_id # private zone id
}



# Create Application and Deployment group for CodeDeploy for Bluegreen deployment
module "ecs_codedeploy_app" {
  source  = "app.terraform.io/pgetech/codedeploy/aws"
  version = "0.1.2"

  depends_on                      = [module.alb, module.ecs_service]
  codedeploy_app_name             = join("-", [var.service_name, "deploy-app"])
  codedeploy_app_compute_platform = var.codedeploy_app_compute_platform
  tags                            = merge(module.tags.tags, local.optional_tags)
}

module "ecs_codedeploy_deployment_group" {
  source  = "app.terraform.io/pgetech/codedeploy/aws//modules/deployment_group"
  version = "0.1.2"

  depends_on                        = [module.ecs_codedeploy_app, module.ecs_service, module.alb]
  deployment_group_app_name         = join("-", [var.service_name, "deploy-app"])
  deployment_group_name             = join("-", [var.service_name, "deploy-group"])
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
      action                           = var.terminate_blue_instances_on_deployment_success_action
      termination_wait_time_in_minutes = var.terminate_blue_instances_on_deployment_success_termination_wait_time_in_minutes
    }]
  }]
  deployment_style = [{
    deployment_option = var.deployment_style_deployment_option
    deployment_type   = var.deployment_style_deployment_type
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

module "ecs_fargate_appautoscaling" {
  source                                       = "../../modules/ecs_fargate_appautoscaling"
  resource_id                                  = "service/${var.cluster_name}/${var.service_name}"
  max_capacity                                 = 5
  min_capacity                                 = 1
  create_autoscaling                           = var.create_autoscaling
  use_target_tracking_scaling                  = var.use_target_tracking_scaling
  step_scaling_policy_name                     = var.step_scaling_policy_name
  target_tracking_scaling_policy_name          = var.target_tracking_scaling_policy_name
  step_scaling_policy_configuration            = var.step_scaling_policy_configuration
  target_tracking_scaling_policy_configuration = var.target_tracking_scaling_policy_configuration
  tags                                         = merge(module.tags.tags, local.optional_tags)
}


