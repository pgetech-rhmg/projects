aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"
account_num = "750713712981"
AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"                        #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205 #Order must be between 7 and 9 digits" 
optional_tags = {

}


# ASG with launch template
create_launch_template    = true # default value is true
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

#Autoscaling group
asg_name                = "asg-lt-ccoe-example1"
asg_max_size            = 1
asg_min_size            = 1
asg_desired_capacity    = 1
asg_force_delete        = true
launch_template_version = "$Latest"

# Values for iam role
policy_file_name = "test_policy.json"

#Autoscaling policy
autoscaling_policy_name = "asg-policy-lt-ccoe-example"
policy_type             = "SimpleScaling"
scaling_adjustment      = 4
adjustment_type         = "ChangeInCapacity"
cooldown                = 300

#autoscaling lifecycle hook
lifecycle_hook_name   = "lifecycle-lt-ccoe-example"
default_result        = "CONTINUE"
heartbeat_timeout     = 2000
lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
notification_metadata = <<EOF
{
  "foo": "bar"
}
EOF

#SNS
snstopic_name         = "sns-topic-lt-ccoe-example" # Name of the SNS topic
snstopic_display_name = "CloudCOE_snstopic"         # Display name of the SNS topic
endpoint              = ["test-email@pge.com"]      #Endpoint to send data to. The contents vary with the protocol. 
protocol              = "email"                     #Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application. Protocols email, email-json, http and https are also valid but partially supported.


#Autoscaling schedule
scheduled_action_name = "asg-schedule-lt-ccoe-example"
min_size              = 0
max_size              = 2
desired_capacity      = 2
start_time            = "2025-10-02T12:00:00Z"
end_time              = "2025-10-02T15:00:00Z"

#Kms
kms_name           = "sns-cmk-lt-ccoe-examples"
kms_description    = "CMK for encrypting sns"
template_file_name = "kms-custom.json"

#Iam_role 
iam_name        = "asg-role-lt-ccoe-example"
iam_aws_service = ["autoscaling.amazonaws.com"]
iam_policy_arns = ["arn:aws:iam::aws:policy/AmazonSNSFullAccess", "arn:aws:iam::aws:policy/service-role/AutoScalingNotificationAccessRole"]


#Security-group variables
sg_name        = "efs-sg-lt-ccoe-examples"
sg_description = "Security group of example usage with ASG using custom policy"
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