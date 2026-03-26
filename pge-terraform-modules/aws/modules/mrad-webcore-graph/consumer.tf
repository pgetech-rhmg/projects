resource "aws_ecs_service" "graph_consumer" {
  name                   = "${var.prefix}-graph-consumer-${lower(var.suffix)}"
  cluster                = aws_ecs_cluster.neptune_service_ecs_cluster.arn
  task_definition        = aws_ecs_task_definition.graph_consumer.arn
  launch_type            = "FARGATE"
  desired_count          = 0
  enable_execute_command = true

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 0

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.consumer_service.id]
    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]
  }

  propagate_tags = "SERVICE"
  tags           = var.tags

  depends_on = [
    aws_cloudwatch_log_group.graph_consumer,
    aws_neptune_cluster.neptune_db_cluster
  ]
}

resource "aws_ecs_task_definition" "graph_consumer" {
  family                   = "${var.prefix}-graph-consumer-${lower(var.suffix)}"
  execution_role_arn       = aws_iam_role.neptune_svc_taskdef_role.arn
  task_role_arn            = aws_iam_role.neptune_svc_taskdef_role.arn
  network_mode             = "awsvpc"
  cpu                      = "8192"
  memory                   = "16384"
  requires_compatibilities = ["FARGATE"]

  container_definitions = templatefile("${path.module}/taskdefs/graph_consumer.json.tmpl",
    {
      suffix                      = lower(var.suffix)
      node_env                    = var.node_env
      neptune_db_cluster_endpoint = aws_neptune_cluster.neptune_db_cluster.endpoint
      consumer_log_group            = aws_cloudwatch_log_group.graph_consumer.id
      account_number              = data.aws_caller_identity.current.account_id
      account_name                = lower(local.environment_name)
      health_check_host           = local.healthcheck_url
      source_hash                 = local.graph_repo_commit
      prefix                      = var.prefix
    }
  )

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.graph_consumer,
    aws_neptune_cluster.neptune_db_cluster
  ]
}

resource "aws_cloudwatch_log_group" "graph_consumer" {
  name              = "/ecs/${var.prefix}-graph-consumer-${lower(var.suffix)}"
  retention_in_days = 90
  tags              = var.tags
}

module "sumo_consumer" {
  source  = "app.terraform.io/pgetech/mrad-sumo/aws"
  version = "~> 0.0.11"

  aws_account = local.environment_name
  aws_role    = var.aws_role

  http_source_name = "${var.prefix}-graph-consumer-${local.environment_name}-${lower(var.suffix)}"
  log_group_name   = aws_cloudwatch_log_group.graph_consumer.name
  filter_pattern   = ""
  disambiguator    = "${var.prefix}-graph-consumer-${lower(var.suffix)}"

  tags = var.tags

  TFC_CONFIGURATION_VERSION_GIT_BRANCH = lower(local.environment_name)
}
