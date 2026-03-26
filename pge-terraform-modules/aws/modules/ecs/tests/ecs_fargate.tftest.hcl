run "ecs_fargate" {
  command = apply

  module {
    source = "./examples/ecs_fargate"
  }
}

variables {
  account_num        = "750713712981"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  account_num_r53    = "514712703977"
  custom_domain_name = "ecs-fargate-wiz.nonprod.pge.com"
  cluster_name       = "ecstwl2-fargate"
  cpu                = 1024
  memory             = 3072
  container_name     = "springapp-container"
  service_name       = "ecstwlsv1"
  container_image    = "ccoe-cicd-docker-virtual.jfrog.nonprod.pge.com/spring-petclinic:pge-latest"
  container_cpu      = 512
  container_memory   = 2048
  port_mappings = [{
    containerPort = 8081
    hostPort      = 8081
    protocol      = "tcp"
  }]
  entrypoint      = ["/opt/wiz/sensor/wiz-sensor", "daemon", "--", "java", "-jar", "/spring-petclinic/spring-petclinic.jar", "--server.port=8081"]
  command         = null
  docker_registry = "JFROG"
  runtime_platform = {
    "cpuArchitecture"       = "X86_64"
    "operatingSystemFamily" = "LINUX"
  }
  desired_count = 1
  load_balancer = [{
    container_name = "springapp-container"
    container_port = 8081
  }]
  http_port                = 80
  sample_application_port1 = 8081
  lb_listener_http = [{
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
  }]
  lb_target_group_name  = "ecs-fargate-target-blue-D"
  target_group_port     = 8081
  jfrog_credential      = "jfrog/credentials"
  https_port            = 443
  https_protocol        = "HTTPS"
  https_type            = "forward"
  wiz_secret_credential = "shared-wiz-access"
}
