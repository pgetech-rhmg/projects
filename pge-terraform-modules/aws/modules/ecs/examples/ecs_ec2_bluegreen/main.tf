/*
* # AWS ECS with EC2 Bluegreen usage example
* Terraform module which creates SAF2.0 ECS with EC2 in AWS.
*/
#
# Filename    : modules/ecs/examples/ecs_ec2_bluegreen/main.tf
# Date        : 03 January 2023
# Author      : Tekyantra
# Description : The Terraform usage example creates AWS ECS with EC2 Bluegreen


locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.optional_tags
  LogGroupNamePrefix = join("/", ["/aws/ecs", var.service_name])
  aws_role           = var.aws_role
  custom_domain_name = var.custom_domain_name
  base_domain_name   = regex("(.*).(alerts.pge.com|ccare.pge.com|cloudapi.pge.com|dc.pge.com|dcs.pge.com|digitalcatalyst.pge.com|io.pge.com|ss-dev.pge.com|ss.pge.com|pgepspsmap.com|pgepspsmaps.com|pgecloud.net|nonprod.pge.com|np-dev.pge.com|nonprod.pge.com|np-dev-api.pge.com|np-dev.pge.com)", var.custom_domain_name)[1]
  user_data          = <<-EOT
  #!/bin/bash
  echo ECS_CLUSTER="${var.cluster_name}" >> /etc/ecs/ecs.config;echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;
  EOT
}


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

module "ecs_ec2" {
  source = "../../"

  cluster_name                   = var.cluster_name
  log_cloud_watch_log_group_name = module.log_group.cloudwatch_log_group_name
  setting_value                  = var.setting_value
  ecs_cluster_capacity_providers = [module.ecs_capacity_provider.ecs_capacity_provider_name]
  ecs_default_capacity_provider  = module.ecs_capacity_provider.ecs_capacity_provider_name
  tags                           = merge(module.tags.tags, local.optional_tags)
  kms_key_id                     = null # replace with module.secretsmanager_kms_key.key_arn, after key creation
  log_execute_command            = "OVERRIDE"

  daemon_desired_count   = var.asg_desired_capacity
  execution_role_arn_wiz = module.ecs_iam_role.arn
  subnets                = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  task_role_arn_wiz      = module.ecs_iam_role.arn
  security_groups        = [module.security_group_asg.sg_id]
}

module "ecs_capacity_provider" {
  source = "../../modules/ecs_capacity_provider"

  ecs_capacity_provider_name = join("-", ["cp", var.service_name])
  autoscaling_group_arn      = module.aws_autoscaling_group.arn
  tags                       = merge(module.tags.tags, local.optional_tags)
}



module "ecs_task_definition" {
  source = "../../modules/ecs_task_definition"

  family_service           = join("-", [var.service_name, "ecs-task-definition"])
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  volumes                  = var.volumes
  execution_role_arn       = module.ecs_iam_role.arn
  task_role_arn            = module.ecs_iam_role.arn
  container_definition     = jsonencode([module.ecs_container_definition.json_map_object])
  tags                     = merge(module.tags.tags, local.optional_tags)
}


module "ecs_container_definition" {
  source = "../../modules/ecs_container_definition"


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
  entrypoint                   = var.entrypoint
  pseudo_terminal              = var.pseudo_terminal
  interactive                  = var.interactive
  port_mappings                = var.port_mappings
  log_configuration = {
    logDriver = var.logDriver
    options = {
      awslogs-region        = var.aws_region
      awslogs-group         = module.log_group.cloudwatch_log_group_name
      awslogs-stream-prefix = join("-", [var.container_name, "logs-stream"])
      awslogs-create-group  = "true"
    }
  }
  repository_Credentials = var.docker_registry == "JFROG" ? { credentialsParameter = data.aws_secretsmanager_secret.jfrog_credentials.arn } : null
}

data "aws_ecs_task_definition" "ecs_task_definition" {
  task_definition = module.ecs_task_definition.ecs_task_definition_family
  depends_on      = [module.ecs_task_definition]
}


module "ecs_service" {
  source = "../../modules/ecs_service_bluegreen"

  service_name           = var.service_name
  ecs_service_cluster_id = module.ecs_ec2.ecs_cluster_id

  # The task-definition revision changes outside of the terraform code(manually or by CICD). This will prevent the task-definition revision version change back to the original value.
  ecs_service_task_definition_arn = "${module.ecs_task_definition.ecs_task_definition_family}:${max(module.ecs_task_definition.ecs_task_definition_revision, data.aws_ecs_task_definition.ecs_task_definition.revision)}"

  ecs_service_launch_type       = var.ecs_service_launch_type
  deployment_type               = var.deployment_type
  target_group_arn              = module.alb.target_group_arn[var.lb_target_group_name]
  load_balancer                 = var.load_balancer
  availability_zone_rebalancing = var.availability_zone_rebalancing
  subnets                       = [data.aws_ssm_parameter.subnet_id2.value]
  security_groups               = [module.security_group_asg.sg_id]
  desired_count                 = var.desired_count
  service_platform_version      = null
  tags                          = merge(module.tags.tags, local.optional_tags)
  depends_on = [
    module.alb, module.ecs_ec2, module.ecs_task_definition
  ]
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

  name        = join("-", [var.service_name, "ecs-security-group"])
  description = var.ecs_sg_description
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = var.http_port,
    to               = var.http_port,
    protocol         = "tcp",
    cidr_blocks      = [nonsensitive(data.aws_ssm_parameter.subnet_cidr1.value), nonsensitive(data.aws_ssm_parameter.subnet_cidr2.value), nonsensitive(data.aws_ssm_parameter.subnet_cidr3.value)]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = var.https_port,
      to               = var.https_port,
      protocol         = "tcp",
      cidr_blocks      = [nonsensitive(data.aws_ssm_parameter.subnet_cidr1.value), nonsensitive(data.aws_ssm_parameter.subnet_cidr2.value), nonsensitive(data.aws_ssm_parameter.subnet_cidr3.value)]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
    },
    {
      from             = var.sample_application_port1,
      to               = var.sample_application_port1,
      protocol         = "tcp",
      cidr_blocks      = [nonsensitive(data.aws_ssm_parameter.subnet_cidr1.value), nonsensitive(data.aws_ssm_parameter.subnet_cidr2.value), nonsensitive(data.aws_ssm_parameter.subnet_cidr3.value)]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  tags = merge(module.tags.tags, local.optional_tags)
}


#iam module for ecs
module "ecs_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = join("-", [var.service_name, "iam-role"])
  aws_service = var.ecs_iam_aws_service
  tags        = merge(module.tags.tags, local.optional_tags)

  #inline_policy
  inline_policy = [templatefile("${path.module}/inline_policy.json",
    {
      jfrog_secret_arn = data.aws_secretsmanager_secret.jfrog_credentials.arn
      kms_key_arn      = module.secretsmanager_kms_key.key_arn
  })]
  policy_arns = var.ecs_iam_policy_arns
}

#Instance Profile
resource "aws_iam_instance_profile" "ecsinstancerole" {
  role = module.ecs_iam_role.name
  depends_on = [
    module.ecs_iam_role,
  ]
  tags = merge(module.tags.tags, local.optional_tags)
}

module "alb" {
  source  = "app.terraform.io/pgetech/alb/aws//modules/internal_alb_bluegreen"
  version = "0.1.2"

  alb_name         = join("-", [var.service_name, "alb"])
  bucket_name      = join("-", [var.service_name, "s3-bucket"])
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
      name         = var.lb_target_group_name
      target_type  = var.target_group_target_type
      port         = var.target_group_port
      protocol     = var.target_group_protocol
      health_check = var.target_group_healthcheck
      stickiness   = var.target_group_stickiness
    },
    {
      name         = var.lb_target_group_name_test
      target_type  = var.target_group_target_type
      port         = var.target_group_port_test
      protocol     = var.target_group_protocol
      health_check = var.target_group_healthcheck
      stickiness   = var.target_group_stickiness
    }
  ]
  vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name   = join("-", [var.service_name, "s3-bucket"])
  force_destroy = true
  policy = templatefile("${path.module}/${var.policy}", {
    bucket_name = join("-", [var.service_name, "s3-bucket"])
    account_num = data.aws_caller_identity.current.account_id
    aws_role    = local.aws_role
  })
  tags = merge(module.tags.tags, local.optional_tags)
}

module "security_group_alb" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = join("-", [var.service_name, "alb-security-group"])
  description = var.alb_sg_description
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = var.https_port,
    to               = var.https_port,
    protocol         = "tcp",
    cidr_blocks      = [nonsensitive(data.aws_ssm_parameter.alb_cidr1.value), nonsensitive(data.aws_ssm_parameter.alb_cidr2.value), nonsensitive(data.aws_ssm_parameter.alb_cidr3.value)]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, local.optional_tags)
}

#cloudwatch for ecs
module "log_group" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.1.3"

  name_prefix       = local.LogGroupNamePrefix
  kms_key_id        = null # replace with module.secretsmanager_kms_key.key_arn, after key creation
  retention_in_days = var.retention_in_days
  tags              = merge(module.tags.tags, local.optional_tags)
}

#asg for ecs
module "aws_autoscaling_group" {
  source  = "app.terraform.io/pgetech/asg/aws"
  version = "0.1.2"

  asg_name                  = join("-", [var.service_name, "asg-ecs-ec2"])
  launch_template_name      = var.launch_template_name
  asg_max_size              = var.asg_max_size
  asg_min_size              = var.asg_min_size
  asg_desired_capacity      = var.asg_desired_capacity
  image_id                  = data.aws_ssm_parameter.golden_ami.value
  instance_type             = var.instance_type
  iam_instance_profile      = aws_iam_instance_profile.ecsinstancerole.name
  user_data                 = base64encode(local.user_data)
  security_groups           = [module.security_group_asg.sg_id]
  autoscaling_policy_name   = var.autoscaling_policy_name
  scaling_adjustment        = var.scaling_adjustment
  adjustment_type           = var.adjustment_type
  asg_vpc_zone_identifier   = [data.aws_ssm_parameter.subnet_id2.value]
  asg_protect_from_scale_in = true

  tags = merge(module.tags.tags, local.optional_tags, { AmazonECSManaged = "true" })
}


module "security_group_asg" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = join("-", [var.service_name, "asg-security-group"])
  description = var.asg_sg_description
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = var.from_port,
    to               = var.to_port,
    protocol         = "tcp",
    cidr_blocks      = [nonsensitive(data.aws_ssm_parameter.alb_cidr1.value), nonsensitive(data.aws_ssm_parameter.alb_cidr2.value), nonsensitive(data.aws_ssm_parameter.alb_cidr3.value)]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, local.optional_tags)
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
