/*
 * # PG&E Mrad ECS Module
 *  MRAD specific composite Terraform ECS module to provision SAF compliant resources
*/
#
# Filename    : modules/mrad-codepipeline/main.tf
# Date        : 2 May 2023
# Author      : MRAD (mrad@pge.com)
# Description : This terraform module provisions MRAD compatible ECR, ECS and CodePipeline
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws, aws.r53, aws.ccoe_dns]
    }
    sumologic = {
      source  = "SumoLogic/sumologic"
      version = ">= 2.1.2"
    }
  }
}

locals {
  cluster_name = "${var.project_name}-Cluster-${var.branch}"
}

# ECR
module "ecr" {
  for_each = toset(var.task_names)
  source   = "app.terraform.io/pgetech/ecr/aws"
  version  = "0.0.7"

  ecr_name                = "${lower(var.project_name)}-${lower(each.value)}-${lower(var.branch)}"
  lifecycle_policy_enable = true
  lifecycle_policy        = var.lifecycle_policy
  tags                    = var.tags
}

# ECS
module "ecs_fargate" {
  source  = "app.terraform.io/pgetech/ecs/aws//modules/ecs_fargate"
  version = "0.0.40"

  cluster_name = local.cluster_name

  log_cloud_watch_log_group_name        = module.log_group.cloudwatch_log_group_name
  setting_value                         = "enabled"
  ecs_default_cluster_capacity_provider = "FARGATE"

  tags = var.tags
}

module "ecs_task_definition" {
  source  = "app.terraform.io/pgetech/ecs/aws//modules/ecs_task_definition"
  version = "0.0.40"

  for_each = toset(var.task_names)

  family_service           = "${var.project_name}-${each.value}-${var.branch}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = module.ecs_execution_role.arn
  task_role_arn            = module.ecs_task_role.arn
  container_definition = jsonencode([
    module.app_container[each.value].json_map_object,
  ])
  tags = var.tags
}

module "app_container" {
  source  = "app.terraform.io/pgetech/ecs/aws//modules/ecs_container_definition"
  version = "0.0.40"

  for_each = toset(var.task_names)

  container_name               = "${var.project_name}-${each.value}-${var.branch}"
  container_image              = "${module.ecr[each.value].ecr_repository_url}:latest"
  command                      = null
  container_memory_reservation = null
  essential                    = true
  readonly_root_filesystem     = false
  environment = [
    {
      "name" : "NODE_ENV",
      "value" : lower(var.aws_account) == "prod" ? "production" : lower(var.aws_account)
    }
  ]
  secrets         = var.secrets
  privileged      = null
  extra_hosts     = null
  hostname        = null
  entrypoint      = var.entry_point
  pseudo_terminal = null
  interactive     = null
  port_mappings = [{
    containerPort = var.port
    hostPort      = var.port
    protocol      = "tcp"
  }]
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-region        = var.aws_region
      awslogs-group         = module.log_group.cloudwatch_log_group_name
      awslogs-stream-prefix = join("-", [lower("${var.project_name}-${var.branch}"), "logs-stream"])
      awslogs-create-group  = "true"
    }
  }
  ulimits = [{
    name      = "nofile"
    softLimit = var.ulimit_nofile_soft
    hardLimit = var.ulimit_nofile_hard
  }]
  healthcheck = var.healthcheck_enabled ? local.healthcheck : null
}

locals {
  healthcheck = {
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definition_healthcheck
    command     = ["CMD-SHELL", "curl -f http://localhost:${var.port}${var.health_check_path} || exit 1"]
    retries     = 3
    timeout     = 5
    interval    = 30
    startPeriod = 1
  }

  validated_desired_count = var.enable_autoscaling ? var.autoscaling_min_capacity : var.desired_count
}

#cloudwatch for ecs
module "log_group" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.0.9"

  name              = "ecs/${var.project_name}-${var.branch}"
  retention_in_days = "90"
  tags              = var.tags
}

module "ecs_task_role" {
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.0.10"
  name        = "${var.project_name}-Task-Role-${var.branch}"
  aws_service = ["ecs-tasks.amazonaws.com"]
  tags        = var.tags

  #inline_policy
  inline_policy = compact([
    data.aws_iam_policy_document.task.json,
    var.additional_task_iam_policy
  ])
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
}

data "aws_iam_policy_document" "task" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      "arn:aws:secretsmanager:us-west-2:*:secret:swap-pass*",
    ]
  }
  statement {
    actions   = ["kms:Decrypt"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "execution_secrets" {
  count = length(var.secrets) > 0 ? 1 : 0

  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = distinct([for s in var.secrets : regex("^(arn:aws[^:]*:secretsmanager:[a-z0-9-]+:[0-9]{12}:secret:[^:]+)", s.valueFrom)[0]])
  }
  statement {
    actions   = ["kms:Decrypt"]
    resources = ["*"]
  }
}

module "ecs_execution_role" {
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.0.10"
  name        = "${var.project_name}-Execution-Role-${var.branch}"
  aws_service = ["ecs-tasks.amazonaws.com"]
  tags        = var.tags

  inline_policy = length(var.secrets) > 0 ? [data.aws_iam_policy_document.execution_secrets[0].json] : []
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
}

module "ecs_service" {
  source  = "app.terraform.io/pgetech/ecs/aws//modules/ecs_service"
  version = "0.1.4"

  for_each = toset(var.task_names)

  service_name           = "${var.project_name}-${each.value}-${var.branch}"
  ecs_service_cluster_id = module.ecs_fargate.ecs_cluster_id
  ecs_service_task_definition_arn = join(":", [
    module.ecs_task_definition[each.value].ecs_task_definition_family,
    module.ecs_task_definition[each.value].ecs_task_definition_revision
  ])
  ecs_service_launch_type = "FARGATE"
  target_group_arn        = var.lb ? module.load_balancer[0].target_group_id[local.lb_name] : null
  load_balancer = var.lb ? [
    {
      container_name = "${var.project_name}-${each.key}-${var.branch}"
      container_port = var.port
    }
  ] : []
  subnets = [
    data.aws_subnet.ecs_private1.id,
    data.aws_subnet.ecs_private2.id,
    data.aws_subnet.ecs_private3.id
  ]
  propagate_tags                     = "SERVICE"
  security_groups                    = [aws_security_group.ecs_security_group.id]
  desired_count                      = local.validated_desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  availability_zone_rebalancing      = var.availability_zone_rebalancing
  tags                               = var.tags
}

data "aws_route53_zone" "private_zone" {
  provider     = aws.r53
  name         = var.domain
  private_zone = true
}

module "sumo_logger" {
  source  = "app.terraform.io/pgetech/mrad-sumo/aws"
  version = "0.0.11"

  providers = {
    sumologic = sumologic
  }

  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.branch

  http_source_name = "Sumo-${var.project_name}-${var.branch}"
  aws_account      = var.aws_account
  aws_role         = var.aws_role
  tags             = var.tags
  filter_pattern   = var.filter_pattern
  log_group_name   = module.log_group.cloudwatch_log_group_name
  disambiguator    = var.project_name
}


# Old stuff

/*
LB and TG names are limited to 32 characters.
Name format: ProjectName-Branch-abcd
where:
    abcd: a unique hash of full name+port (prevents collisions even when truncated)

Length math: [name: <= 27] + [hash "-abcd": 5] = 32
*/

locals {
  name      = "${var.project_name}-${var.branch}"
  lb_prefix = substr(local.name, 0, 27)                         # 27
  lb_suffix = substr(sha256("${local.name}-${var.port}"), 0, 4) #  4
  lb_name   = "${local.lb_prefix}-${local.lb_suffix}"           # 32
}

module "load_balancer" {
  source  = "app.terraform.io/pgetech/alb/aws"
  version = "0.1.4"
  count   = var.lb ? 1 : 0

  alb_name    = local.lb_name
  bucket_name = module.lb_access_logs_s3_bucket[count.index].id

  security_groups = compact(concat([aws_security_group.ecs_security_group.id], var.additional_security_groups))

  subnets = [
    data.aws_subnet.private1.id,
    data.aws_subnet.private2.id,
    data.aws_subnet.private3.id
  ]

  tags = var.tags

  ###############listener###################
  # lb_listener_http       = var.lb_listener_http
  lb_listener_https = [
    {
      protocol          = "HTTPS"
      port              = var.balancer_port
      certificate_arn   = module.alb_cert[0].acm_certificate_arn
      type              = "forward"
      target_group_name = local.lb_name
    }
  ]
  # lb_listener_rule_http  = var.lb_listener_rule_http
  # lb_listener_rule_https = var.lb_listener_rule_https
  # certificate_arn        = var.certificate_arn

  ###############target###################

  lb_target_group = [
    {
      name        = local.lb_name
      target_type = "ip"
      port        = var.port
      protocol    = "HTTP"
      health_check = [{
        enabled           = true
        interval          = 30
        matcher           = "200-299"
        path              = var.health_check_path
        port              = var.port
        protocol          = "HTTP"
        timeout           = var.health_check_timeout
        healthy_threshold = 3
      }]
      stickiness = [{
        cookie_duration = 86400
        enabled         = false
        type            = "lb_cookie"
      }]
      targets = {}
    }
  ]

  vpc_id = data.aws_vpc.mrad_vpc.id
}

data "aws_s3_bucket" "logging_bucket" {
  bucket = "ccoe-s3-accesslogs-spoke-us-west-2-${data.aws_caller_identity.current.account_id}"
}

module "lb_access_logs_s3_bucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.0.14"
  count   = var.lb == false ? 0 : 1

  bucket_name             = "${lower(var.project_name)}-${lower(var.branch)}-lb-access-logs"
  target_bucket           = data.aws_s3_bucket.logging_bucket.id
  target_prefix           = "${lower(var.project_name)}-${lower(var.branch)}-lb-access-logs/"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  policy                  = data.aws_iam_policy_document.bucket_policy_document[count.index].json

  tags = var.tags
}

data "aws_iam_policy_document" "bucket_policy_document" {
  count = var.lb == false ? 0 : 1

  # Permit logs to be sent from the load balancer to the relevant S3 bucket
  statement {
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${lower(var.project_name)}-${lower(var.branch)}-lb-access-logs/*"]

    principals {
      type        = "AWS"
      identifiers = ["797873946194"] # This is AWS's account for Load Balancers, not one of ours
    }
  }

  # Force SSL-only access, courtesy of binaryalert on Github
  statement {
    sid    = "ForceSSLOnlyAccess"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${lower(var.project_name)}-${lower(var.branch)}-lb-access-logs",
      "arn:aws:s3:::${lower(var.project_name)}-${lower(var.branch)}-lb-access-logs/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_security_group" "ecs_security_group" {
  name        = "${local.name}-ecs-security"
  description = "Allow ECS to ECS"
  vpc_id      = data.aws_vpc.mrad_vpc.id

  ingress {
    description = "https ingress from private networks"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp" # https only
    cidr_blocks = ["172.16.0.0/12", "192.168.0.0/16", "100.64.0.0/10", "198.19.0.0/16", "10.0.0.0/8"]

    self = true
  }

  ingress {
    description = "http ingress from private networks"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp" # http only
    cidr_blocks = ["172.16.0.0/12", "192.168.0.0/16", "100.64.0.0/10", "198.19.0.0/16", "10.0.0.0/8"]

    self = true
  }

  # allow communication over app port within local sg
  ingress {
    description = "allow communication over app port within local sg"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp" # http only

    self = true
  }

  ingress {
    description = "allow icmp from private networks"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["172.16.0.0/12", "192.168.0.0/16", "100.64.0.0/10", "198.19.0.0/16", "10.0.0.0/8"]

    self = true
  }

  egress {
    description = "allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

module "alb_cert" {
  count = var.lb ? 1 : 0

  source  = "app.terraform.io/pgetech/acm/aws"
  version = "0.0.7"

  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }

  acm_domain_name = "${lower(var.project_name)}.${lower(var.aws_account)}.${var.domain}"
  allow_overwrite = true
  tags            = var.tags
}

# Load balancer DNS - external ccoe aws account

resource "aws_route53_record" "service_dns" {
  allow_overwrite = true
  count           = (var.force_lb || (contains(["development", "master", "main", "production"], var.branch) && var.lb == true)) ? 1 : 0
  provider        = aws.ccoe_dns
  zone_id         = data.aws_route53_zone.private_zone.zone_id
  name            = "${lower(var.project_name)}.${lower(var.aws_account)}.${var.domain}"
  type            = "A"

  alias {
    name                   = module.load_balancer[0].alb.dns_name
    zone_id                = module.load_balancer[0].alb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  for_each = var.enable_autoscaling ? toset(var.task_names) : toset([])

  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "service/${local.cluster_name}/${module.ecs_service[each.key].ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = var.tags
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  for_each = var.enable_autoscaling ? toset(var.task_names) : toset([])

  name               = "${var.project_name}-${each.key}-${var.branch}-cpu-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.autoscaling_target_cpu
    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
    disable_scale_in   = false

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
