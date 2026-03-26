
############################
# TAGS (PGE STANDARD)
############################
AppID              = "2102"
Environment        = "Dev"
DataClassification = "Internal"
CRIS               = "Low"
Notify             = ["atcv@pge.com"]
Owner              = ["atcv", "s3kv", "a2vb"]
Compliance         = ["None"]
Order              = 8115205

optional_tags = {}

############################
# CORE
############################
aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"
############################
# NETWORK
############################
vpc_id              = "vpc-02dc1b83805ba69d4"
subnet_ids          = ["subnet-0ce9bc280b58f1c60", "subnet-0fcaeb67c4d490357"]
security_group_name = "nonbg-alb-sg"
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

# Allow HTTP 80 between members of this SG (ALB <-> Instances)
security_group_ingress_rules = [
  {
    from                     = 80
    to                       = 80
    protocol                 = "tcp"
    source_security_group_id = "" # self-reference
    description              = "Allow HTTP between ALB and instances"
  }
]

# Outbound all (default)
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


############################
# ALB
############################
alb_name = "sample-rolling-alb-nonbg"
lb_listener_https = [
  {
    port              = 443
    protocol          = "HTTPS"
    type              = "forward"
    target_group_name = "nonbg-tg-a"
    certificate_arn   = "arn:aws:acm:us-west-2:750713712981:certificate/630af583-3512-4456-94dd-989e3a5348ee"
  }
]

lb_target_group = [
  {
    name        = "nonbg-tg-a"
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
lambda_bucket_name   = "nonbluegreen-alb-bucket-a"
lambda_function_name = "ami-triggered-nonbg"

############################
# ASG (ROLLING UPDATE)
############################
asg_name         = "sample-app-asg-bg"
instance_type    = "t3.micro"
min_size         = 1
max_size         = 2
desired_capacity = 2
release_version  = "latest"

############################
# AMI
############################
latest_ami_param_name  = "/app/migration_testing/latest_ami"
ami_catalog_param_name = "/app/nonbg/ami_catalog"

############################
# AUTOMATION FLAGS
############################
enable_ami_automation  = true
auto_apply_ami_updates = false
