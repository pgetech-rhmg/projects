/*
* # AWS ECS with FARGATE usage example
* Terraform module which creates SAF2.0 ECS with FARGATE WITH WIZ in AWS.
*/
#
# Filename    : modules/ecs/examples/ecs_fargate_rollingupdate_wiz/main.tf
# Date        : 23/01/2023
# Author      : (Tekyantra)
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
  LogGroupNamePrefix    = join("/", ["/aws/ecs", var.service_name])
  custom_domain_name    = var.custom_domain_name
  base_domain_name      = regex("(.*).(alerts.pge.com|ccare.pge.com|cloudapi.pge.com|dc.pge.com|dcs.pge.com|digitalcatalyst.pge.com|io.pge.com|ss-dev.pge.com|ss.pge.com|pgepspsmap.com|pgepspsmaps.com|pgecloud.net|nonprod.pge.com|np-dev.pge.com|nonprod.pge.com|np-dev-api.pge.com|np-dev.pge.com)", var.custom_domain_name)[1]

}



module "secretsmanager_kms_key" {
  source      = "app.terraform.io/pgetech/kms/aws"
  version     = "0.1.2"
  name        = join("-", [var.service_name, "kms-secretsmanager"])
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
  kms_key_id                            = null # replace with module.secretsmanager_kms_key.key_arn, after key creation
  log_execute_command                   = "OVERRIDE"

  tags = merge(module.tags.tags, local.optional_tags)
}

module "ecs_task_definition" {
  source                   = "../../modules/ecs_task_definition"
  family_service           = join("-", [var.service_name, "ecs-task-definition"])
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  execution_role_arn       = module.ecs_iam_role.arn
  task_role_arn            = module.ecs_iam_role.arn
  container_definition     = jsonencode([module.app_container.json_map_object, module.ecs_fargate.wiz_container_definition_json])
  tags                     = merge(module.tags.tags, local.optional_tags)
  runtime_platform         = var.runtime_platform
  volumes                  = var.volumes
}


module "app_container" {
  source                       = "../../modules/ecs_container_definition"
  container_name               = var.container_name
  container_image              = var.container_image
  container_memory             = var.container_memory
  container_cpu                = var.container_cpu
  command                      = var.command
  mount_points                 = var.mount_points
  container_memory_reservation = var.container_memory_reservation
  essential                    = var.essential
  readonly_root_filesystem     = var.readonly_root_filesystem
  privileged                   = var.privileged
  extra_hosts                  = var.extra_hosts
  hostname                     = var.hostname
  entrypoint                   = var.entrypoint
  pseudo_terminal              = var.pseudo_terminal
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
  container_depends_on = [{
    "containerName" : "wiz-sensor",
    "condition" : "COMPLETE"
  }]
  volumes_from = [
    {
      "sourceContainer" : "wiz-sensor"
      "readOnly" : false
    }
  ]
  interactive   = var.interactive
  port_mappings = var.port_mappings
  log_configuration = {
    logDriver = var.logDriver
    options = {
      awslogs-region        = var.aws_region
      awslogs-group         = module.log_group.cloudwatch_log_group_name
      awslogs-stream-prefix = join("-", [var.service_name, "logs-stream"])
      awslogs-create-group  = "true"
    }
  }
  repository_Credentials = var.docker_registry == "JFROG" ? { credentialsParameter = module.secretsmanager.arn } : null
}

module "ecs_service" {
  source                          = "../../modules/ecs_service"
  service_name                    = join("-", [var.service_name, "ecs-fargate-svc"])
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

module "security_group_ecs_service" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = join("-", [var.service_name, "ecs-service-security-group"])
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


#security group for ecs
module "security_group_ecs" {
  source      = "app.terraform.io/pgetech/security-group/aws"
  version     = "0.1.2"
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

#iam for ecs
module "ecs_iam_role" {
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.1"
  name        = join("-", [var.service_name, "iam-role"])
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
  alb_name    = join("-", [var.service_name, "alb"])
  bucket_name = join("-", [var.service_name, "s3-bucket"])

  security_groups  = [module.security_group_alb.sg_id]
  subnets          = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  lb_listener_http = var.lb_listener_http
  tags             = merge(module.tags.tags, local.optional_tags)
  lb_listener_https = [
    {
      port              = var.https_port
      protocol          = var.https_protocol
      certificate_arn   = module.acm_public_certificate.acm_certificate_arn
      target_group_name = var.lb_target_group_name
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
    aws_role    = var.aws_role
  })
  tags = merge(module.tags.tags, local.optional_tags)
}

#security group for alb
module "security_group_alb" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = join("-", [var.service_name, "alb-secueirt-group"])
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



data "template_file" "kms_policy" {
  template = templatefile("${path.module}/${var.template_file_name}",
    {
      account_num = data.aws_caller_identity.current.account_id
      ecs_iam     = module.ecs_iam_role.name
      aws_region  = var.aws_region
  }, )
}

#ACM

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