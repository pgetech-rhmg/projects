aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

#Tag variables

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205 #Order must be between 7 and 9 digits" 
optional_tags = {
  Name = "test_end"
}


#Autoscaling group variables

asg_name             = "asg-lt-ccoe-examples"
asg_max_size         = 2
asg_min_size         = 0
asg_desired_capacity = 1
asg_force_delete     = true

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

#Autoscaling schedule variables
scheduled_action_name = "schedule-ccoe-instance-example"
min_size              = 0
max_size              = 2
desired_capacity      = 1
start_time            = "2025-10-02T12:00:00Z"
end_time              = "2025-10-02T15:00:00Z"

#Autoscaling attachment variables
target_group_name = "asg-lb-ccoe-instance-example"
port              = 80
protocol          = "HTTP"

lb_target_group_name = "asg-lb-ccoe-instance"
lb_port              = 80
lb_protocol          = "HTTP"

#Lifecycle hook variables
lifecycle_hook_name   = "lifecycle-ccoe-instance-example"
default_result        = "CONTINUE"
heartbeat_timeout     = 2000
lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
notification_metadata = <<EOF
{
  "foo": "bar"
}
EOF

#snstopic variables
snstopic_name         = "sns-topic-ccoe-instance-example" # Name of the SNS topic
snstopic_display_name = "CloudCOE_snstopic12"             # Display name of the SNS topic
endpoint              = ["test-email@pge.com"]            #Endpoint to send data to. The contents vary with the protocol. 
sns_protocol          = "email"                           #Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application. Protocols email, email-json, http and https are also valid but partially supported.


#IAM variables

iam_name        = "ASG-role-ccoe-instance-example"
iam_aws_service = ["autoscaling.amazonaws.com"]
iam_policy_arns = ["arn:aws:iam::aws:policy/AmazonSNSFullAccess", "arn:aws:iam::aws:policy/service-role/AutoScalingNotificationAccessRole"]

#Kms variables

kms_name           = "cmk-key-ccoe-instance-example"
kms_description    = "CMK for encrypting sns"
template_file_name = "kms-custom.json"
