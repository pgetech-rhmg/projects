run "ecs_ec2_multiple_containers" {
  command = apply

  module {
    source = "./examples/ecs_ec2_multiple_containers"
  }
}

variables {
  account_num                = "750713712981"
  aws_region                 = "us-west-2"
  aws_role                   = "CloudAdmin"
  account_num_r53            = "514712703977"
  aws_r53_role               = "CloudAdmin"
  custom_domain_name         = "oxdi.ecs-nodeapp.nonprod.pge.com"
  AppID                      = "1001"
  Environment                = "Dev"
  DataClassification         = "Internal"
  CRIS                       = "Low"
  Notify                     = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                      = ["abc1", "def2", "ghi3"]
  Compliance                 = ["None"]
  Order                      = 8115205
  parameter_golden_ami_name  = "/ami/linux/ecs-optimized"
  cluster_name               = "ecs-ec2-fb-oxdi"
  setting_value              = "enabled"
  memory                     = 1048
  ecs_capacity_provider_name = "capacity_provider_ecsec2_test"
  jfrog_credentials          = "jfrog/credentials"
  docker_registry            = "JFROG"
  container_name             = "springapp-container"
  fluentbit_container_name   = "custom_fluentbit_logrouter"
  container_image            = "ccoe-cicd-docker-virtual.jfrog.nonprod.pge.com/spring-petclinic:pge-latest"
  fluentbit_container_image  = "750713712981.dkr.ecr.us-west-2.amazonaws.com/fluentbit:custom"
  container_cpu              = 256
  container_memory           = 1048
  entrypoint                 = null
  port_mappings = [{
    containerPort = 8081
    hostPort      = 8081
    protocol      = "tcp"
  }]
  fluentbit_port_mappings = [{
    containerPort = 24224
    hostPort      = 24224
    protocol      = "tcp"
  }]
  desired_count = 2
  load_balancer = [{
    container_name = "springapp-container"
    container_port = 8081
  }]
  http_port                = 80
  https_port               = 443
  sample_application_port1 = 8081
  ecs_iam_aws_service      = ["ec2.amazonaws.com", "ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
  ecs_iam_policy_arns      = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy", "arn:aws:iam::aws:policy/AmazonECS_FullAccess", "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess", "arn:aws:iam::aws:policy/AmazonSSMFullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"]
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
  https_protocol                 = "HTTPS"
  https_type                     = "forward"
  lb_target_group_name           = "ecs-ec2-svc-tg"
  target_group_port              = 8081
  target_group_protocol          = "HTTP"
  lb_listener_https_port         = 443
  policy                         = "s3_policy.json"
  log_group_name_prefix          = "ecs_ec2_service"
  launch_template_name           = "oxdi-test-new"
  asg_max_size                   = 4
  asg_min_size                   = 2
  asg_desired_capacity           = 3
  instance_type                  = "m6id.large"
  scaling_adjustment             = 4
  port                           = 8081
  sns_topic_cloudwatch_alarm_arn = "arn:aws:sns:us-west-2:514712703977:eks-alarm"
}
