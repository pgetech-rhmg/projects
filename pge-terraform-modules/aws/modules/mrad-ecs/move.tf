moved {
  from = aws_ecr_repository.ecr_repository["ECS"]
  to   = module.ecr["ECS"].aws_ecr_repository.ecr
}

moved {
  from = aws_ecr_lifecycle_policy.ecr_repository_policy["ECS"]
  to   = module.ecr["ECS"].aws_ecr_lifecycle_policy.lifecycle_policy[0]
}

moved {
  from = aws_ecs_cluster.ecs_cluster
  to   = module.ecs_fargate.aws_ecs_cluster.ecs_cluster
}

moved {
  from = aws_ecs_service.ecs_service["ECS"]
  to   = module.ecs_service["ECS"].aws_ecs_service.ecs_service
}

moved {
  from = aws_ecs_task_definition.ecs_task["ECS"]
  to   = module.ecs_task_definition["ECS"].aws_ecs_task_definition.ecs_task_definition
}

moved {
  from = module.iam.aws_iam_role.task_role
  to   = module.ecs_task_role.aws_iam_role.default
}

moved {
  from = aws_cloudwatch_log_group.log_group
  to   = module.log_group.aws_cloudwatch_log_group.this
}

moved {
  from = module.iam.aws_iam_role.execution_role
  to   = module.ecs_execution_role.aws_iam_role.default
}

moved {
  from = aws_s3_bucket.load_balancer_access_logs[0]
  to   = module.lb_access_logs_s3_bucket[0].aws_s3_bucket.default
}

moved {
  from = aws_s3_bucket_public_access_block.load_balancer_access_logs_blocked[0]
  to   = module.lb_access_logs_s3_bucket[0].aws_s3_bucket_public_access_block.default
}

moved {
  from = aws_lb.load_balancer[0]
  to   = module.load_balancer[0].aws_lb.lb
}

moved {
  from = aws_lb_listener.alb_listener[0]
  to   = module.load_balancer[0].aws_lb_listener.lb_listener_https["443"]
}

moved {
  from = aws_acm_certificate.alb_cert[0]
  to   = module.alb_cert[0].aws_acm_certificate.acm_certificate
}
