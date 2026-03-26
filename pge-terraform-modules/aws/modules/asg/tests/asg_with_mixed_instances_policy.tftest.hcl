run "asg_with_mixed_instances_policy" {
  command = apply

  module {
    source = "./examples/asg_with_mixed_instances_policy"
  }
}

variables {
  aws_region         = "us-west-2"
  account_num        = "750713712981"
  aws_role           = "CloudAdmin"
  kms_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags = {
    Name = "test_end"
  }
  asg_name                                 = "asg-lt-ccoe-examples"
  asg_max_size                             = 2
  asg_min_size                             = 0
  asg_desired_capacity                     = 1
  asg_force_delete                         = true
  on_demand_allocation_strategy            = "prioritized"
  on_demand_base_capacity                  = 0
  on_demand_percentage_above_base_capacity = 25
  spot_allocation_strategy                 = "lowest-price"
  spot_instance_pools                      = 2
  spot_max_price                           = ""
  launch_template_specification_id         = "lt-0089d4e3dd1a9d6fd"
  launch_template_specification_version    = "$Default"
  instance_type                            = "c5.large"
  weighted_capacity                        = 2
  autoscaling_policy_name                  = "asg_policy5"
  policy_type                              = "SimpleScaling"
  scaling_adjustment                       = 4
  adjustment_type                          = "ChangeInCapacity"
  cooldown                                 = 300
  scheduled_action_name                    = "schedule-ccoe-instance-example"
  min_size                                 = 0
  max_size                                 = 2
  desired_capacity                         = 1
  start_time                               = "2025-10-02T12:00:00Z"
  end_time                                 = "2025-10-02T15:00:00Z"
  target_group_name                        = "asg-lb-ccoe-instance-example"
  port                                     = 80
  protocol                                 = "HTTP"
  lb_target_group_name                     = "asg-lb-ccoe-instance"
  lb_port                                  = 80
  lb_protocol                              = "HTTP"
  lifecycle_hook_name                      = "lifecycle-ccoe-instance-example"
  default_result                           = "CONTINUE"
  heartbeat_timeout                        = 2000
  lifecycle_transition                     = "autoscaling:EC2_INSTANCE_LAUNCHING"
  notification_metadata                    = <<EOF
{
  "foo": "bar"
}
EOF
  snstopic_name                            = "sns-topic-ccoe-instance-example"
  snstopic_display_name                    = "CloudCOE_snstopic12"
  endpoint                                 = ["test-email@pge.com"]
  sns_protocol                             = "email"
  iam_name                                 = "ASG-role-ccoe-instance-example"
  iam_aws_service                          = ["autoscaling.amazonaws.com"]
  iam_policy_arns                          = ["arn:aws:iam::aws:policy/AmazonSNSFullAccess", "arn:aws:iam::aws:policy/service-role/AutoScalingNotificationAccessRole"]
  kms_name                                 = "cmk-key-ccoe-instance-example"
  kms_description                          = "CMK for encrypting sns"
  template_file_name                       = "kms-custom.json"
}
