run "http_https_app" {
  command = apply

  module {
    source = "./examples/http_https_app"
  }
}

variables {
  aws_region               = "us-west-2"
  account_num              = "750713712981"
  account_num_r53          = "514712703977"
  aws_role                 = "CloudAdmin"
  AppID                    = "1001"
  Environment              = "Dev"
  DataClassification       = "Internal"
  CRIS                     = "Low"
  Notify                   = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                    = ["abc1", "def2", "ghi3"]
  Compliance               = ["None"]
  Order                    = 8115205
  iam_name                 = "ccoe-iam-role-tf"
  iam_aws_service          = ["ec2.amazonaws.com"]
  iam_policy_arns          = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  alb_name                 = "ccoe-alb-name"
  alb_log_bucket_name      = "ccoe-alb-accesslogs-spoke-us-west-2-750713712981-qa"
  alb_target_group_name    = "ccoe-target-group-1"
  ec2_security_groups_name = "ec2_sg_web"
  alb_security_groups_name = "alb_sg_web"
  ec2_cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  ec2_cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["10.0.0.0/8"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "ec2 ingress rules for http"
    },
    {
      from             = 80,
      to               = 80,
      protocol         = "tcp",
      cidr_blocks      = ["172.16.0.0/12"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "sample ec2 ingress rule - 2"
    },
    {
      from             = 80,
      to               = 80,
      protocol         = "tcp",
      cidr_blocks      = ["192.168.0.0/16"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "sample ec2 ingress rule- 3"
  }]
  alb_cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  alb_cidr_ingress_rules = [{
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["10.0.0.0/8"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "ec2 ingress rules for https - 1"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = ["172.16.0.0/12"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "ec2 ingress rules for https - 2"
      }, {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = ["192.168.0.0/16"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "ec2 ingress rules for https - 3"
      }, {
      from             = 80,
      to               = 80,
      protocol         = "tcp",
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "ec2 ingress rules  for http"
      }, {
      from             = 80,
      to               = 80,
      protocol         = "tcp",
      cidr_blocks      = ["172.16.0.0/12"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "sample ec2 ingress rule - 2"
      }, {
      from             = 80,
      to               = 80,
      protocol         = "tcp",
      cidr_blocks      = ["192.168.0.0/16"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "sample ec2 ingress rule- 3"
  }]
  custom_domain_name        = "ccoe-asg-ec2-alb.nonprod.pge.com"
  subject_alternative_names = ["*.ccoe-asg-ec2-alb.nonprod.pge.com"]
  allow_overwrite           = true
  asg_name                  = "ccoe-asg-name"
  launch_template_name      = "ccoe-demo-lt-name"
  autoscaling_policy_name   = "ccoe-asg-scaling-policy"
  instance_type             = "t2.micro"
  policy_type               = "SimpleScaling"
  scaling_adjustment        = 1
  adjustment_type           = "ChangeInCapacity"
  asg_health_check_type     = "ELB"
}
