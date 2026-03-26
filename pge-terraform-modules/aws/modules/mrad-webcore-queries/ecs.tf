resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.prefix}-${local.short_name}-cluster-${var.suffix}"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

resource "aws_ecs_task_definition" "ecs_task" {
  family = "${var.prefix}-${local.short_name}-${var.suffix}"
  container_definitions = templatefile("${path.module}/templates/task_template.json", {
    repository_url    = aws_ecr_repository.ecr_repository.repository_url
    container_name    = "${var.prefix}-${local.short_name}-${var.suffix}"
    log_group         = module.queries_logs.cloudwatch_log_group_name
    port              = var.application_port
    region            = var.region
    git_hash          = local.queries_repo_commit
    node_env          = var.node_env
    health_check_host = local.healthcheck_url
    stream_prefix     = "${local.short_name}"
  })
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.task_cpu
  memory                   = local.task_memory
  execution_role_arn       = data.aws_iam_role.ecs_exe_role.arn
  task_role_arn            = data.aws_iam_role.ecs_task_role.arn
  tags                     = var.tags
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.prefix}-${local.short_name}-${var.suffix}"
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = local.task_count
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.ecs_cluster.id

  network_configuration {
    security_groups = [data.aws_security_group.ecs_security_group.id]

    subnets = [
      data.aws_subnet.private1.id,
      data.aws_subnet.private2.id,
      data.aws_subnet.private3.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.id
    container_name   = "${var.prefix}-${local.short_name}-${var.suffix}"
    container_port   = var.application_port
  }

  tags = var.tags
}
