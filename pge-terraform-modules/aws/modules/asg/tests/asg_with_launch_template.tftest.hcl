run "asg_with_launch_template" {
  command = apply

  module {
    source = "./examples/asg_with_launch_template"
  }
}

variables {
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  kms_role           = "CloudAdmin"
  account_num        = "750713712981"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags = {
  }
  create_launch_template    = true
  launch_template_name      = "template-lt-ccoe-examples"
  parameter_golden_ami_name = "/ami/linux/ecs-optimized"
  instance_type             = "t3.small"
  instance_name             = "example-ccoe-ec2-linux"
  block_device_mappings = [{
    device_name = "/dev/sda1"
    ebs = {
      volume_size = 20
      volume_type = "gp3"
      throughput  = 500
    }
  }]
  asg_name                = "asg-lt-ccoe-example1"
  asg_max_size            = 1
  asg_min_size            = 1
  asg_desired_capacity    = 1
  asg_force_delete        = true
  launch_template_version = "$Latest"
  policy_file_name        = "test_policy.json"
  autoscaling_policy_name = "asg-policy-lt-ccoe-example"
  policy_type             = "SimpleScaling"
  scaling_adjustment      = 4
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  lifecycle_hook_name     = "lifecycle-lt-ccoe-example"
  default_result          = "CONTINUE"
  heartbeat_timeout       = 2000
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
  notification_metadata   = <<EOF
{
  "foo": "bar"
}
EOF
  snstopic_name           = "sns-topic-lt-ccoe-example"
  snstopic_display_name   = "CloudCOE_snstopic"
  endpoint                = ["test-email@pge.com"]
  protocol                = "email"
  scheduled_action_name   = "asg-schedule-lt-ccoe-example"
  min_size                = 0
  max_size                = 2
  desired_capacity        = 2
  start_time              = "2025-10-02T12:00:00Z"
  end_time                = "2025-10-02T15:00:00Z"
  kms_name                = "sns-cmk-lt-ccoe-examples"
  kms_description         = "CMK for encrypting sns"
  template_file_name      = "kms-custom.json"
  iam_name                = "asg-role-lt-ccoe-example"
  iam_aws_service         = ["autoscaling.amazonaws.com"]
  iam_policy_arns         = ["arn:aws:iam::aws:policy/AmazonSNSFullAccess", "arn:aws:iam::aws:policy/service-role/AutoScalingNotificationAccessRole"]
  sg_name                 = "efs-sg-lt-ccoe-examples"
  sg_description          = "Security group of example usage with ASG using custom policy"
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["10.0.0.0/8"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample ec2 ingress rules 1"
    }, {
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["172.16.0.0/12"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample ec2 ingress rules 2"
    }, {
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["192.168.0.0/16"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample ec2 ingress rules 3"
    }, {
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["10.0.0.0/8"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample ec2 ingress rules 4"
    }, {
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["172.16.0.0/12"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample ec2 ingress rules 5"
    }, {
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["192.168.0.0/16"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample ec2 ingress rules 6"
  }]
  cidr_egress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample ec2 egress rules 7"
  }]
}
