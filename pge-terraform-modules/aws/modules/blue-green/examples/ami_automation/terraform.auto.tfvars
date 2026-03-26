aws_region      = "us-west-2"
account_num     = "750713712981"
aws_role        = "CloudAdmin"
vpc_id          = "vpc-02dc1b83805ba69d4"
subnet_ids      = ["subnet-0ce9bc280b58f1c60", "subnet-0fcaeb67c4d490357"]
security_group_name = "bg-alb-test-sg"

instance_type          = "t3.micro"
lambda_function_name   = "bluegreen-amiupgrade-lambda"
lambda_bucket_name     = "bluegreen-amiupgrade-buckets3"
latest_ami_param_name  = "/app/migration_testing/latest_ami"
ami_catalog_param_name = "/app/bluegreen/ami_catalog"

AppID              = "2102"
Environment        = "Dev"
DataClassification = "Internal"
CRIS               = "Low"
Notify             = ["atcv@pge.com"]
Owner              = ["atcv", "s3kv", "a2vb"]
Compliance         = ["None"]
Order              = 8115205
optional_tags = {}

#### INITIAL ROLLOUT SETTINGS ####

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

################## ------------------
######### ALB
# ############------------------
alb_name            = "bg-alb-test"

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

  
# 100% traffic to green initially
green_percent = 100

# Always deploy newest AMI from catalog as "green"
release_version = "latest"

# Blue = previous AMI (N-1)
blue_mode          = "relative_to_selected"
blue_pinned_ami_id = ""

# Blue ASG (start with zero)
blue_min_size         = 0
blue_max_size         = 0
blue_desired_capacity = 0

# Green ASG (active)
green_min_size         = 1
green_max_size         = 2
green_desired_capacity = 2
blue_asg_name          = "blue_asg"
green_asg_name         = "green_asg"

enable_ami_automation = true
auto_apply_ami_updates = false