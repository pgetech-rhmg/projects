/*
* # AWS ECS with FARGATE usage example
* Terraform module which creates SAF2.0 ECS with FARGATE in AWS.
*/
#
# Filename    : modules/ecs/examples/ecs_fargate_fluentbit/main.tf
# Date        : 29/11/2022
# Author      : TekYantra
# Description : The Terraform usage example creates AWS ECS with FARGATE


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
  LogGroupNamePrefix    = var.log_group_name_prefix
}



module "secretsmanager_kms_key" {
  source      = "app.terraform.io/pgetech/kms/aws"
  version     = "0.1.2"
  name        = join("-", [var.cluster_name, "kms-secretsmanager"])
  description = var.kms_description_for_secretsmanager
  policy      = data.template_file.kms_policy.rendered
  tags        = module.tags.tags
  aws_role    = local.aws_role
  kms_role    = module.ecs_iam_role.name
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

module "ecs_fargate" {
  source = "../../modules/ecs_fargate"

  cluster_name                          = var.cluster_name
  log_cloud_watch_log_group_name        = module.log_group.cloudwatch_log_group_name
  setting_value                         = var.setting_value
  ecs_cluster_capacity_providers        = var.ecs_cluster_capacity_providers
  ecs_default_cluster_capacity_provider = var.ecs_default_cluster_capacity_provider

  tags = merge(module.tags.tags, local.optional_tags)
}

module "ecs_task_definition" {
  source                   = "../../modules/ecs_task_definition"
  family_service           = join("-", [var.cluster_name, "ecs-task-definition"])
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = module.ecs_iam_role.arn
  task_role_arn            = module.ecs_iam_role.arn
  container_definition     = jsonencode([module.container.json_map_object, module.fluentbit_container.json_map_object, module.ecs_fargate.wiz_container_definition_json])
  tags                     = merge(module.tags.tags, local.optional_tags)
  runtime_platform         = var.runtime_platform
  volumes                  = var.volumes
}

module "container" {
  source                       = "../../modules/ecs_container_definition"
  container_name               = var.container_name
  container_image              = var.container_image
  container_memory             = var.container_memory
  container_cpu                = var.container_cpu
  command                      = var.command
  container_memory_reservation = var.container_memory_reservation
  essential                    = var.essential
  readonly_root_filesystem     = var.readonly_root_filesystem
  privileged                   = var.privileged
  volumes_from = [
    {
      "sourceContainer" : module.ecs_fargate.wiz_container_name
      "readOnly" : false
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
  container_depends_on = [{
    "containerName" : "wiz-sensor",
    "condition" : "COMPLETE"
  }]
  extra_hosts     = var.extra_hosts
  hostname        = var.hostname
  entrypoint      = var.entrypoint
  pseudo_terminal = var.pseudo_terminal
  interactive     = var.interactive
  port_mappings   = var.port_mappings
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
  log_configuration = {
    logDriver = var.logDriver
  }
  repository_Credentials = var.docker_registry == "JFROG" ? { credentialsParameter = module.secretsmanager.arn } : null
}


module "fluentbit_container" {
  source                       = "../../modules/ecs_container_definition"
  container_name               = var.fluentbit_container_name
  container_image              = var.fluentbit_container_image
  container_memory             = var.container_memory
  container_cpu                = var.container_cpu
  command                      = var.command
  container_memory_reservation = var.fluentbit_container_memory_reservation
  essential                    = var.essential
  readonly_root_filesystem     = var.readonly_root_filesystem
  environment                  = var.container_environment
  privileged                   = var.privileged
  extra_hosts                  = var.extra_hosts
  hostname                     = var.hostname
  entrypoint                   = var.fluentbit_entrypoint
  pseudo_terminal              = var.pseudo_terminal
  interactive                  = var.interactive
  port_mappings                = var.port_mappings_for_fluentbit
  firelens_configuration = {
    type = "fluentbit",
    options = {
      config-file-type  = "file",
      config-file-value = "/logDestinations.conf"
    }
  }
  log_configuration = {
    logDriver = var.fluentbit_logDriver
    options = {
      awslogs-region        = var.fluentbit_awslogs_region
      awslogs-group         = var.fluentbit_awslogs_group
      awslogs-stream-prefix = var.fluentbit_awslogs_stream_prefix
      awslogs-create-group  = "true"
    }
  }
  #wiz container definition
}

module "ecs_service" {
  source                          = "../../modules/ecs_service"
  service_name                    = join("-", [var.cluster_name, "ecs-fargate-svc"])
  ecs_service_cluster_id          = module.ecs_fargate.ecs_cluster_id
  ecs_service_task_definition_arn = module.ecs_task_definition.ecs_task_definition_family
  ecs_service_launch_type         = var.ecs_service_launch_type
  deployment_type                 = var.deployment_type
  target_group_arn                = module.alb.target_group_arn[var.lb_target_group_name]
  load_balancer                   = var.load_balancer
  availability_zone_rebalancing   = var.availability_zone_rebalancing
  subnets                         = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  security_groups                 = [module.security_group_ecs_service.sg_id]
  desired_count                   = var.desired_count
  tags                            = merge(module.tags.tags, local.optional_tags)
  depends_on = [
    module.alb,
  ]
}

module "ecs_account_setting_default" {
  source                    = "../../modules/ecs_account_setting_default"
  ecs_account_name          = var.ecs_account_name
  ecs_account_setting_value = var.ecs_account_setting_value
}

#security group for ecs
module "security_group_ecs" {
  source      = "app.terraform.io/pgetech/security-group/aws"
  version     = "0.1.2"
  name        = join("-", [var.cluster_name, "ecs-security-group"])
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

module "security_group_ecs_service" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = join("-", [var.cluster_name, "ecs-service-security-group"])
  description = var.ecs_sg_description
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

#iam for ecs
module "ecs_iam_role" {
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.1"
  name        = join("-", [var.cluster_name, "iam-role"])
  aws_service = var.ecs_iam_aws_service
  tags        = merge(module.tags.tags, local.optional_tags)

  #inline_policy
  inline_policy = [data.template_file.fargate_ecs.rendered]
  policy_arns   = var.ecs_iam_policy_arns
}

#aws_iam_role Inline policy
data "template_file" "fargate_ecs" {
  template = templatefile("${path.module}/inline_policy.json",
    {
      secretmanager_kms_key = module.secretsmanager_kms_key.key_arn
      secretmanager_arn     = module.secretsmanager.arn
  }, )
}

module "alb" {
  source      = "app.terraform.io/pgetech/alb/aws"
  version     = "0.1.2"
  alb_name    = join("-", [var.cluster_name, "alb"])
  bucket_name = join("-", [var.cluster_name, "s3-bucket-new"])

  security_groups   = [module.security_group_alb.sg_id]
  subnets           = [data.aws_ssm_parameter.subnet_id1.value, "subnet-0ce9bc280b58f1c60", "subnet-0fcaeb67c4d490357"]
  lb_listener_http  = var.lb_listener_http
  tags              = merge(module.tags.tags, local.optional_tags)
  lb_listener_https = var.lb_listener_https
  certificate_arn   = var.certificate_arn
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
      name         = var.lb_target_group_name2
      target_type  = var.target_group_target_type
      port         = var.target_group_port1
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

  bucket_name   = join("-", [var.cluster_name, "s3-bucket-new"])
  force_destroy = true
  policy = templatefile("${path.module}/${var.policy}", {
    bucket_name = join("-", [var.cluster_name, "s3-bucket-new"])
    account_num = data.aws_caller_identity.current.account_id
    aws_role    = var.aws_role
  })
  tags = merge(module.tags.tags, local.optional_tags)
}



#security group for alb
module "security_group_alb" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = join("-", [var.cluster_name, "alb-secueirt-group"])
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

  name_prefix = local.LogGroupNamePrefix
  tags        = merge(module.tags.tags, local.optional_tags)
}

#Secret Manager
module "secretsmanager" {
  source                     = "app.terraform.io/pgetech/secretsmanager/aws"
  version                    = "0.1.3"
  secretsmanager_name        = join("-", [var.cluster_name, "secretsmanager"])
  secretsmanager_description = var.secretsmanager_description
  kms_key_id                 = null                        # replace with module.secretsmanager_kms_key.key_arn, after key creation
  recovery_window_in_days    = var.recovery_window_in_days #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
  secret_string              = data.aws_secretsmanager_secret_version.latest_version.secret_string
  secret_version_enabled     = var.secret_version_enabled
  tags                       = merge(module.tags.tags, local.optional_tags)
}



data "template_file" "kms_policy" {
  template = templatefile("${path.module}/${var.template_file_name}",
    {
      account_num = data.aws_caller_identity.current.account_id
      #ecs_iam     = var.ecs_iam_name
      ecs_iam = module.ecs_iam_role.name
  }, )
}

module "ecs_dashboard" {
  source         = "../../modules/ecs_cloudwatch"
  dashboard_name = join("-", [var.cluster_name, "cloudwatch-dashboard"])
  aws_region     = var.aws_region
  services = [{
    cluster_name  = var.cluster_name
    service_name  = module.ecs_service.ecs_service_name
    widget_prefix = var.cluster_name
    lb_arn_suffix = module.alb.lb_arn_suffix
  }, ]
}

module "ecs_fargate_alarms" {
  source                     = "../../modules/ecs_fargate_alarms"
  cluster_name               = var.cluster_name
  service_name               = module.ecs_service.ecs_service_name
  alert_actions              = [var.sns_topic_cloudwatch_alarm_arn]
  cpu_alert_threshold        = var.cpu_alert_threshold
  memory_alert_threshold     = var.memory_alert_threshold
  HTTPCode_ELB_5XX_threshold = var.HTTPCode_ELB_5XX_threshold
  lb_arn_suffix              = module.alb.lb_arn_suffix
  tags                       = merge(module.tags.tags, local.optional_tags)
}