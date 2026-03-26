run "ecs_fargate_multiple_containers" {
  command = apply

  module {
    source = "./examples/ecs_fargate_multiple_containers"
  }
}

variables {
  account_num               = "750713712981"
  aws_region                = "us-west-2"
  aws_role                  = "CloudAdmin"
  AppID                     = "1001"
  Environment               = "Dev"
  DataClassification        = "Internal"
  CRIS                      = "Low"
  Notify                    = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                     = ["abc1", "def2", "ghi3"]
  Compliance                = ["None"]
  Order                     = 8115205
  cluster_name              = "ecs-fargate-fb1-oxdi"
  cpu                       = 1024
  memory                    = 2048
  container_name            = "springapp-container"
  container_image           = "ccoe-cicd-docker-virtual.jfrog.nonprod.pge.com/spring-petclinic:pge-latest"
  fluentbit_container_name  = "custom_fluentbit_logrouter"
  fluentbit_container_image = "750713712981.dkr.ecr.us-west-2.amazonaws.com/fluentbit:custom"
  docker_registry           = "JFROG"
  container_cpu             = 512
  container_memory          = 2048
  port_mappings_for_fluentbit = [{
    containerPort = 24224
    hostPort      = 24224
    protocol      = "tcp"
  }]
  port_mappings = [{
    containerPort = 8081
    hostPort      = 8081
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
  lb_listener_http = [{
    port              = 8081
    protocol          = "HTTP"
    type              = "forward"
    target_group_name = "ecs-fargate-target-blue-b"
    },
    {
      port              = 8082
      protocol          = "HTTP"
      type              = "forward"
      target_group_name = "ecs-fargate-target-green-g"
  }]
  lb_listener_https = [{
    port              = 443
    protocol          = "HTTPS"
    certificate_arn   = "arn:aws:acm:us-west-2:750713712981:certificate/4e1e9dc7-2f17-435f-a95e-804b8d863569"
    target_group_name = "ecs-fargate-target-blue-b"
    type              = "forward"
    },
    {
      port              = 444
      protocol          = "HTTPS"
      certificate_arn   = "arn:aws:acm:us-west-2:750713712981:certificate/4e1e9dc7-2f17-435f-a95e-804b8d863569"
      target_group_name = "ecs-fargate-target-green-g"
      type              = "forward"
  }]
  certificate_arn = [{
    lb_listener_https_port = 443
    certificate_arn        = "arn:aws:acm:us-west-2:750713712981:certificate/4e1e9dc7-2f17-435f-a95e-804b8d863569"
  }]
  lb_target_group_name           = "ecs-fargate-target-blue-b"
  lb_target_group_name2          = "ecs-fargate-target-green-g"
  target_group_port              = 8081
  target_group_port1             = 8082
  log_group_name_prefix          = "my-app-ecs-fargate-petclinic"
  sns_topic_cloudwatch_alarm_arn = "arn:aws:sns:us-west-2:514712703977:eks-alarm"
  runtime_platform = {
    "cpuArchitecture"       = "X86_64"
    "operatingSystemFamily" = "LINUX"
  }
  entrypoint               = ["/opt/wiz/sensor/wiz-sensor", "daemon", "--", "java", "-jar", "/spring-petclinic/spring-petclinic.jar", "--server.port=8081"]
  command                  = null
  wiz_secret_credential    = "shared-wiz-access"
  wiz_registry_credentials = "wiz_registry_credentials"
  jfrog_password           = "jfrog/credentials"
}
