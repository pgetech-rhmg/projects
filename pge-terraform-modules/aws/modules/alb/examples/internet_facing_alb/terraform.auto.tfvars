account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

#Tags
AppID              = "1001"                                           # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment        = "Dev"                                            # Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205
#alb
alb_name = "tf-lb-test"
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
  }
]
lb_listener_https = [
  {
    port              = 443
    protocol          = "HTTPS"
    certificate_arn   = "arn:aws:acm:us-west-2:750713712981:certificate/94bee8ed-1fe1-44b3-9506-456ac855bb3d"
    target_group_name = "target-alb"
    type              = "forward"
  }
]
certificate_arn = [
  {
    lb_listener_https_port = 443
    certificate_arn        = "arn:aws:acm:us-west-2:750713712981:certificate/94bee8ed-1fe1-44b3-9506-456ac855bb3d"
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
    priority               = 140
    lb_listener_https_port = 443
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


#s3
bucket_name = "ccoe-alb-accesslogs-spoke-oxdi"   ### Please use your bucket if you already have a bucket created  
policy      = "s3_access_log_policy.json"

#Ec2 variables
ec2_name          = "test-01"
ec2_instance_type = "t2.micro"
ec2_az            = "us-west-2a"

#Security group variables
alb_sg_name        = "test-alb-sg-oxdi-test"
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

alb_cidr_egress_rules = [{
  from             = 0,
  to               = 0,
  protocol         = "-1",
  cidr_blocks      = ["10.90.195.0/25"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
}]

sg_name        = "alb-sg-oxdi-test"
sg_description = "Security group for example usage with EBS"

cidr_egress_rules = [{
  from             = 0,
  to               = 0,
  protocol         = "-1",
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
}]