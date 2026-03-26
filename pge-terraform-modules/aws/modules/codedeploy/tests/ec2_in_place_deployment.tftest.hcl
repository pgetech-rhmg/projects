run "ec2_in_place_deployment" {
  command = apply

  module {
    source = "./examples/ec2_in_place_deployment"
  }
}

variables {
  account_num              = "750713712981"
  aws_region               = "us-west-2"
  aws_role                 = "CloudAdmin"
  AppID                    = "1001"
  Environment              = "Dev"
  DataClassification       = "Internal"
  CRIS                     = "Low"
  Notify                   = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                    = ["abc1", "def2", "ghi3"]
  Compliance               = ["None"]
  ssm_parameter_vpc_id     = "/vpc/id"
  ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
  ssm_parameter_golden_ami = "/ami/linux/golden"
  codedeploy_app_name      = "test_app_ec2"
  deployment_config_name   = "test_config_ec2"
  minimum_healthy_hosts = {
    type  = "HOST_COUNT"
    value = "1"
  }
  deployment_group_name = "test_deploy_group"
  deployment_option     = "WITH_TRAFFIC_CONTROL"
  ec2_tag_filter_key    = "managed_by"
  ec2_tag_filter_type   = "KEY_AND_VALUE"
  ec2_tag_filter_value  = "terraform"
  optional_tags         = { managed_by = "terraform" }
  alb_name              = "tf-lb-test"
  alb_s3_bucket_name    = "alb-s3-logs-codedeploy-example"
  Order                 = 8115205
  lb_listener_http = [
    {
      port              = 80
      protocol          = "HTTP"
      type              = "forward"
      target_group_name = "target-alb"
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
    },
    {
      port     = 82
      protocol = "HTTP"
      type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed response content"
        status_code  = "200"
      }
    }
  ]
  lb_listener_https = [
    {
      port              = 443
      protocol          = "HTTPS"
      certificate_arn   = "arn:aws:acm:us-west-2:750713712981:certificate/90080268-184f-4d7e-8980-d0668820765c"
      target_group_name = "target-alb"
      type              = "forward"
    },
    {
      port            = 444
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:acm:us-west-2:750713712981:certificate/90080268-184f-4d7e-8980-d0668820765c"
      type            = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_302"
      }
    },
    {
      port            = 445
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:acm:us-west-2:750713712981:certificate/90080268-184f-4d7e-8980-d0668820765c"
      type            = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed response content"
        status_code  = "200"
      }
    }
  ]
  certificate_arn = [
    {
      lb_listener_https_port = 443
      certificate_arn        = "arn:aws:acm:us-west-2:750713712981:certificate/90080268-184f-4d7e-8980-d0668820765c"
    }
  ]
  lb_listener_rule_http = [
    {
      priority              = 100
      lb_listener_http_port = 80
      actions = [{
        type         = "fixed-response"
        content_type = "text/plain"
        message_body = "HEALTHY"
        status_code  = "200"
      }]
      conditions = [{
        path_pattern = ["/some/auth/required/route"]
      }]
    }
  ]
  lb_listener_rule_https = [
    {
      lb_listener_https_port = 444
      priority               = 4000
      actions = [{
        type              = "forward"
        target_group_name = "target-alb"
      }]
      conditions = [
        {
          host_header = ["test.com"]
        }
      ]
    }
  ]
  lb_target_group_name             = "target-alb"
  lb_target_group_target_type      = "instance"
  lb_target_group_port             = 80
  lb_target_group_protocol         = "HTTP"
  health_check_enabled             = true
  health_check_interval            = 5
  health_check_matcher             = 200
  health_check_path                = "/phpinfo.php"
  health_check_port                = "traffic-port"
  health_check_protocol            = "HTTP"
  health_check_timeout             = 2
  health_check_unhealthy_threshold = 3
  targets_ec2_port                 = 80
  role_name                        = "test_deploy_role"
  aws_service                      = ["codedeploy.amazonaws.com"]
  policy_arns                      = ["arn:aws:iam::aws:policy/AWSCodeDeployFullAccess", "arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
  ec2_name                         = "ccoe-test-example"
  ec2_instance_type                = "t2.micro"
  ec2_az                           = "us-west-2a"
  alb_sg_name                      = "test-alb-sg"
  alb_sg_description               = "Security group for example usage with ec2"
  alb_cidr_ingress_rules = [{
    from             = 80,
    to               = 82,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 443,
      to               = 445,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.195.0/25"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  alb_cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["10.90.195.0/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  ec2_sg_name        = "test-ec2-alb-sg"
  ec2_sg_description = "Security group for example usage with ec2"
  ec2_cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  vpc_endpoint_sg_name        = "vpc_endpont_sg"
  vpc_endpoint_sg_description = "Security group for vpc endpoint"
  vpc_endpoint_cidr_ingress_rules = [{
    from             = 5701,
    to               = 5703,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  vpc_endpoint_cidr_egress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  api_service_name   = "com.amazonaws.us-west-2.codedeploy"
  agent_service_name = "com.amazonaws.us-west-2.codedeploy-commands-secure"
}
