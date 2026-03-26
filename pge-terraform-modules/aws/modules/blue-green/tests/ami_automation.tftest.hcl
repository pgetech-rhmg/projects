run "ami_automation" {
  command = apply

  module {
    source = "./examples/ami_automation"
  }
}

variables {
  aws_region             = "us-west-2"
  account_num            = "750713712981"
  aws_role               = "CloudAdmin"
  vpc_id                 = "vpc-02dc1b83805ba69d4"
  subnet_ids             = ["subnet-0ce9bc280b58f1c60", "subnet-0fcaeb67c4d490357"]
  security_group_name    = "bg-alb-sg-a"
  instance_type          = "t3.micro"
  lambda_function_name   = "ami-triggered-bluegreen-a"
  lambda_bucket_name     = "bluegreen-amiupgrade-bucket"
  latest_ami_param_name  = "/app/migration_testing/latest_ami"
  ami_catalog_param_name = "/app/bluegreen/ami_catalog"
  AppID                  = "2102"
  Environment            = "Dev"
  DataClassification     = "Internal"
  CRIS                   = "Low"
  Notify                 = ["atcv@pge.com"]
  Owner                  = ["atcv", "s3kv", "a2vb"]
  Compliance             = ["None"]
  Order                  = 8115205
  optional_tags          = {}
  cidr_ingress_rules = [
    {
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = ["10.90.112.128/25", "10.91.128.0/22", "100.64.0.0/16"]
      description      = "Allow HTTPS to ALB"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    }
  ]
  security_group_ingress_rules = [
    {
      from                     = 80
      to                       = 80
      protocol                 = "tcp"
      source_security_group_id = ""
      description              = "Allow HTTP between ALB and instances"
    }
  ]
  cidr_egress_rules = [
    {
      from             = 0
      to               = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow all outbound"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    }
  ]
  alb_name = "bg-alb"
  lb_listener_https = [
    {
      port              = 443
      protocol          = "HTTPS"
      type              = "forward"
      target_group_name = "blue-tg"
      certificate_arn   = "arn:aws:acm:us-west-2:750713712981:certificate/630af583-3512-4456-94dd-989e3a5348ee"
    }
  ]
  lb_target_group = [
    {
      name        = "blue-tg"
      target_type = "instance"
      port        = 80
      protocol    = "HTTP"
      health_check = [{
        enabled             = true
        healthy_threshold   = 2
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }]
      stickiness = [{
        enabled         = false
        type            = "lb_cookie"
        cookie_duration = 86400
      }]
    },
    {
      name        = "green-tg"
      target_type = "instance"
      port        = 80
      protocol    = "HTTP"
      health_check = [{
        enabled             = true
        healthy_threshold   = 2
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }]
      stickiness = [{
        enabled         = false
        type            = "lb_cookie"
        cookie_duration = 86400
      }]
    }
  ]
  green_percent          = 100
  release_version        = "latest"
  blue_mode              = "relative_to_selected"
  blue_pinned_ami_id     = ""
  blue_min_size          = 0
  blue_max_size          = 0
  blue_desired_capacity  = 0
  green_min_size         = 1
  green_max_size         = 2
  green_desired_capacity = 2
  blue_asg_name          = "blue_asg"
  green_asg_name         = "green_asg"
  enable_ami_automation  = true
  auto_apply_ami_updates = false
}
