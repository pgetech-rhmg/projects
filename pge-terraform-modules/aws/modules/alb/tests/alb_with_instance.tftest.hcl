run "alb_with_instance" {
  command = apply

  module {
    source = "./examples/alb_with_instance"
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
  alb_name           = "tf-lb-test-oxdi"
  lb_listener_http = [
    {
      port              = 80
      protocol          = "HTTP"
      type              = "forward"
      target_group_name = "target-alb-1"
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
      target_group_name = "target-alb-2"
      type              = "fixed-response"
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
        target_group_name = "target-alb-1"
      }]
      conditions = [
        {
          host_header = ["test.com"]
        }
      ]
    }
  ]
  bucket_name        = "ccoe-alb-accesslogs-spoke-oxdi"
  policy             = "s3_access_log_policy.json"
  ec2_name_1         = "ccoe-test-example"
  ec2_name_2         = "ccoe-test-example-2"
  ec2_instance_type  = "t2.micro"
  ec2_az             = "us-west-2a"
  alb_sg_name        = "test-alb-sg-oxdi-test-new"
  alb_sg_description = "Security group for example usage with ec2"
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
  sg_name_1      = "test-ec2-alb-sg-1-oxdi-test"
  sg_name_2      = "test-ec2-alb-sg-2-oxdi-test"
  sg_description = "Security group for example usage with ec2"
  Order          = 8115205
  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
}
