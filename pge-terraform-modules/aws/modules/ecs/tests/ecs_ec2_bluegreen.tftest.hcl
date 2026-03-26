run "ecs_ec2_bluegreen" {
  command = apply

  module {
    source = "./examples/ecs_ec2_bluegreen"
  }
}

variables {
  account_num               = "750713712981"
  aws_region                = "us-west-2"
  aws_role                  = "CloudAdmin"
  aws_r53_role              = "CloudAdmin"
  account_num_r53           = "514712703977"
  custom_domain_name        = "oxdi-test-ecs-petclinic-bg-new.nonprod.pge.com"
  AppID                     = "1001"
  Environment               = "Dev"
  DataClassification        = "Internal"
  CRIS                      = "Low"
  Notify                    = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                     = ["abc1", "def2", "ghi3"]
  Compliance                = ["None"]
  Order                     = 8115205
  parameter_golden_ami_name = "/ami/linux/ecs-optimized"
  parameter_subnet_id1_name = "/vpc/2/privatesubnet1/id"
  parameter_subnet_id2_name = "/vpc/2/privatesubnet3/id"
  jfrog_credentials         = "jfrog/credentials"
  cluster_name              = "ecs-ec2-bg-java-cluster-oxdi"
  cpu                       = 256
  memory                    = 1048
  volumes                   = []
  docker_registry           = "JFROG"
  container_name            = "springapp-container"
  container_image           = "ccoe-cicd-docker-virtual.jfrog.nonprod.pge.com/spring-petclinic:pge-latest"
  container_cpu             = 256
  container_memory          = 1048
  entrypoint                = null
  port_mappings = [
    {
      containerPort = 8081
      hostPort      = 8081
      protocol      = "tcp"
    }
  ]
  service_name           = "springapp-oxdi-test-new"
  deployment_type        = "CODE_DEPLOY"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  desired_count          = 2
  load_balancer = [{
    container_name = "springapp-container"
    container_port = 8081
  }]
  http_port                = 80
  https_port               = 443
  sample_application_port1 = 8081
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
  https_protocol            = "HTTPS"
  https_type                = "forward"
  https_port1               = 444
  lb_target_group_name      = "ecs-ec2-tg-oxdi-test-wiz"
  lb_target_group_name_test = "ecs-ec2-tg-aicg-oxdi-test-wiz"
  target_group_port         = 443
  target_group_port_test    = 444
  target_group_protocol     = "HTTP"
  launch_template_name      = "oxdi-test-wiz"
  asg_max_size              = 3
  asg_min_size              = 2
  asg_desired_capacity      = 2
  instance_type             = "t3.large"
  scaling_adjustment        = 3
}
