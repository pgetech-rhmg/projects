run "ecs_fargate_bluegreen" {
  command = apply

  module {
    source = "./examples/ecs_fargate_bluegreen"
  }
}

variables {
  account_num               = "750713712981"
  aws_region                = "us-west-2"
  aws_role                  = "CloudAdmin"
  aws_r53_role              = "CloudAdmin"
  account_num_r53           = "514712703977"
  custom_domain_name        = "oxdi.ecs-far-bg.nonprod.pge.com"
  AppID                     = "1001"
  Environment               = "Dev"
  DataClassification        = "Internal"
  CRIS                      = "Low"
  Notify                    = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                     = ["abc1", "def2", "ghi3"]
  Compliance                = ["None"]
  Order                     = 8115205
  parameter_subnet_id1_name = "/vpc/2/privatesubnet1/id"
  parameter_subnet_id2_name = "/vpc/2/privatesubnet3/id"
  jfrog_credentials         = "jfrog/credentials"
  cluster_name              = "ecs-fargate-bg-python-cluster-oxdi"
  cpu                       = 512
  memory                    = 2048
  docker_registry           = "JFROG"
  container_name            = "springapp-container"
  container_image           = "ccoe-cicd-docker-virtual.jfrog.nonprod.pge.com/spring-petclinic:pge-latest"
  container_cpu             = 512
  container_memory          = 2048
  port_mappings = [
    {
      containerPort = 8081
      hostPort      = 8081
      protocol      = "tcp"
    }
  ]
  service_name            = "ecs-fargate-bg-service-aicg"
  desired_count           = 2
  ecs_service_launch_type = "FARGATE"
  deployment_type         = "CODE_DEPLOY"
  deployment_config_name  = "CodeDeployDefault.ECSAllAtOnce"
  load_balancer = [{
    container_name = "springapp-container"
    container_port = 8081
  }]
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
      description      = "CCOE Ingress rules for port 8081 - 1"
    },
    {
      from             = 8081,
      to               = 8081,
      protocol         = "tcp",
      cidr_blocks      = ["10.91.128.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules for port 8081 - 2"
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
  https_port                = 443
  https_protocol            = "HTTPS"
  https_type                = "forward"
  lb_target_group_name      = "ecs-fe-tgf-py-oxdi"
  https_port1               = 444
  lb_target_group_name_test = "ecs-fe-tgf-py-oxdi-test"
  target_group_target_type  = "ip"
  target_group_port         = 443
  target_group_port_test    = 444
  target_group_protocol     = "HTTP"
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
  create_autoscaling          = false
  use_target_tracking_scaling = true
  step_scaling_policy_name    = ""
  step_scaling_policy_configuration = {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"
    step_adjustment = [{
      metric_interval_lower_bound = 2.0
      metric_interval_upper_bound = 3.0
      scaling_adjustment          = 1
      }
    ]
  }
  target_tracking_scaling_policy_name = "Target-scaling-test"
  target_tracking_scaling_policy_configuration = {
    target_value       = 50.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    disable_scale_in   = false
    predefined_metric_specification = [
      {
        predefined_metric_type = "ECSServiceAverageMemoryUtilization"
      }
    ]
  }
  runtime_platform = {
    "cpuArchitecture"       = "X86_64"
    "operatingSystemFamily" = "LINUX"
  }
  entrypoint            = ["/opt/wiz/sensor/wiz-sensor", "daemon", "--", "java", "-jar", "/spring-petclinic/spring-petclinic.jar", "--server.port=8081"]
  command               = null
  wiz_secret_credential = "shared-wiz-access"
}
