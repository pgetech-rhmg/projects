run "ecs_bluegreen" {
  command = apply

  module {
    source = "./examples/ecs_bluegreen"
  }
}

variables {
  account_num                           = "750713712981"
  aws_region                            = "us-west-2"
  aws_role                              = "CloudAdmin"
  kms_role                              = "CloudAdmin"
  AppID                                 = "1001"
  Environment                           = "Dev"
  DataClassification                    = "Internal"
  CRIS                                  = "Low"
  Notify                                = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                                 = ["abc1", "def2", "ghi3"]
  Compliance                            = ["None"]
  parameter_vpc_id_name                 = "/vpc/id"
  parameter_subnet_id1_name             = "/vpc/privatesubnet4/id"
  parameter_subnet_id2_name             = "/vpc/privatesubnet5/id"
  cluster_name                          = "ecs-fargate-cluster-bg-aicg"
  setting_value                         = "enabled"
  ecs_cluster_capacity_providers        = ["FARGATE", "FARGATE_SPOT"]
  ecs_default_cluster_capacity_provider = "FARGATE"
  family_service                        = "ecs-fargate-task-def-bluegreen"
  requires_compatibilities              = ["FARGATE"]
  cpu                                   = 512
  memory                                = 2048
  container_name                        = "spring-petclinic"
  container_image                       = "tekyantra-np-docker-virtual.jfrog.nonprod.pge.com/spring-petclinic:latest"
  wiz_container_image                   = "tekyantra-np-docker-virtual.jfrog.nonprod.pge.com/spring-petclinic:latest"
  container_cpu                         = 512
  container_memory                      = 2048
  logDriver                             = "awslogs"
  awslogs_region                        = "us-west-2"
  awslogs_group                         = "spring-petclinic"
  awslogs_stream_prefix                 = "ecs_fargate"
  Order                                 = 8115205
  wiz_container_name                    = "tekyantra-np-docker-virtual.jfrog.nonprod.pge.com/spring-petclinic:latest"
  port_mappings = [
    {
      containerPort = 8081
      hostPort      = 8081
      protocol      = "tcp"
    }
  ]
  service_name            = "ecs_fargate_service_bluegreen"
  desired_count           = 2
  ecs_service_launch_type = "FARGATE"
  deployment_type         = "CODE_DEPLOY"
  load_balancer = [{
    container_name = "spring-petclinic"
    container_port = 8081
  }]
  ecs_account_name          = "taskLongArnFormat"
  ecs_account_setting_value = "enabled"
  ecs_sg_name               = "ecs_fargate_sg_bluegreen"
  ecs_sg_description        = "Security group for example usage with ecs"
  ecs_cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.232.128/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = ["10.91.129.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
    },
    {
      from             = 8081,
      to               = 8081,
      protocol         = "tcp",
      cidr_blocks      = ["10.91.129.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules 1"
    },
    {
      from             = 8081,
      to               = 8081,
      protocol         = "tcp",
      cidr_blocks      = ["10.91.128.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules 2"
  }]
  ecs_cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.232.128/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
    },
    {
      from             = 0,
      to               = 0,
      protocol         = "-1",
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  ecs_iam_name        = "ecs_iam_bluegreen"
  ecs_iam_aws_service = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
  ecs_iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy", "arn:aws:iam::aws:policy/AmazonECS_FullAccess"]
  alb_name            = "ecs-alb-bluegreen"
  lb_listener_http = [
    {
      port     = 80
      protocol = "HTTP"
      type     = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
    {
      port     = 81
      protocol = "HTTP"
      type     = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
  lb_listener_https = [
    {
      port              = 443
      protocol          = "HTTPS"
      certificate_arn   = "arn:aws:acm:us-west-2:750713712981:certificate/90080268-184f-4d7e-8980-d0668820765c"
      target_group_name = "ecs-fargate-target-bg"
      type              = "forward"
    },
    {
      port              = 444
      protocol          = "HTTPS"
      certificate_arn   = "arn:aws:acm:us-west-2:750713712981:certificate/90080268-184f-4d7e-8980-d0668820765c"
      target_group_name = "ecs-fargate-target-bg-test"
      type              = "forward"
    }
  ]
  certificate_arn = [
    {
      lb_listener_https_port = 443
      certificate_arn        = "arn:aws:acm:us-west-2:750713712981:certificate/90080268-184f-4d7e-8980-d0668820765c"
    }
  ]
  lb_target_group_name      = "ecs-fargate-target-bg"
  lb_target_group_name_test = "ecs-fargate-target-bg-test"
  target_group_target_type  = "ip"
  target_group_port         = 443
  target_group_port_test    = 444
  target_group_protocol     = "HTTP"
  alb_s3_bucket_name        = "ecs-fargate-alb-s3-logs-bluegreen-a8tq3"
  policy                    = "s3_policy.json"
  alb_sg_name               = "alb_sg_ecs_bluegreen"
  alb_sg_description        = "Security group for example usage with ecs"
  alb_cidr_ingress_rules = [{
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["10.91.0.0/16", "10.90.0.0/16", "192.168.0.0/16", "172.16.0.0/12", "10.0.0.0/8"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 80,
      to               = 80,
      protocol         = "tcp",
      cidr_blocks      = ["10.91.0.0/16", "10.90.0.0/16", "192.168.0.0/16", "172.16.0.0/12", "10.0.0.0/8"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
    }
  ]
  alb_cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.232.0/25", "10.90.232.128/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
    },
    {
      from             = 0,
      to               = 0,
      protocol         = "-1",
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
  }]
  sg_name        = "ecs-fargate-vpc_endpoint_bluegreen"
  sg_description = "Security group for example usage with ecs"
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = ["10.91.129.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
    },
    {
      from             = 0,
      to               = 0,
      protocol         = "-1",
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
    }
  ]
  cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.232.128/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = ["10.91.129.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
    },
    {
      from             = 0,
      to               = 0,
      protocol         = "-1",
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
  }]
  log_group_name_prefix               = "petclinic-ecs-fargate"
  jfrog_credentials                   = "jfrog_credentials"
  auto_rollback_configuration_enabled = true
  auto_rollback_configuration_events  = ["DEPLOYMENT_FAILURE"]
  action_on_timeout                   = "CONTINUE_DEPLOYMENT"
  wait_time_in_minutes                = "0"
  action                              = "TERMINATE"
  termination_wait_time_in_minutes    = 5
  deployment_option                   = "WITH_TRAFFIC_CONTROL"
  codedeploy_deployment_type          = "BLUE_GREEN"
  deployment_config_name              = "CodeDeployDefault.ECSAllAtOnce"
  codedeploy_application_name         = "test-bluegreen-app"
  codedeploy_deployment_groupname     = "test-bluegreen-app-deployment-group"
  codedeploy_app_compute_platform     = "ECS"
  deployment_group_service_role_arn   = "arn:aws:iam::750713712981:role/AWSCodeDeployRoleForECS"
}
