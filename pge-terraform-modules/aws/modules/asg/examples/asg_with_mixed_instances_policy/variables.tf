variable "aws_region" {
  type        = string
  description = "AWS Region"
}

# Variables for assume_role used in terraform.tf

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_role" {
  description = "AWS role"
  type        = string
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

# Variables for tags 

variable "optional_tags" {
  description = "Optional tags"
  type        = map(string)
  default     = {}
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}


variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}
# Variables for autoscaling group

variable "asg_name" {
  description = "The name of the Auto Scaling Group"
  type        = string
}

variable "asg_max_size" {
  description = "The maximum size of the Auto Scaling Group"
  type        = number
}

variable "asg_min_size" {
  description = "The minimum size of the Auto Scaling Group"
  type        = number
}

variable "asg_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  type        = number
}

variable "asg_force_delete" {
  description = "Allows deleting the Auto Scaling Group without waiting for all instances in the pool to terminate"
  type        = bool
}

variable "on_demand_allocation_strategy" {
  description = "Strategy to use when launching on-demand instances"
  type        = string
}

variable "on_demand_base_capacity" {
  description = " Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
  type        = number
}

variable "on_demand_percentage_above_base_capacity" {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity"
  type        = number
}

variable "spot_allocation_strategy" {
  description = "How to allocate capacity across the Spot pools"
  type        = string
}

variable "spot_instance_pools" {
  description = "Number of Spot pools per availability zone to allocate capacity"
  type        = number
}

variable "spot_max_price" {
  description = "Maximum price per unit hour that the user is willing to pay for the Spot instances"
  type        = string
}

variable "launch_template_specification_id" {
  description = "The ID of the launch template."
  type        = string
}

variable "launch_template_specification_version" {
  description = "Template version"
  type        = string
}

variable "instance_type" {
  description = "Override the instance type in the Launch Template."
  type        = string
}

variable "weighted_capacity" {
  description = "The number of capacity units, which gives the instance type a proportional weight to other instance types."
  type        = number
}

# Variables for Autoscaling policy

variable "autoscaling_policy_name" {
  description = "The name of the Policy."
  type        = string
}

variable "policy_type" {
  description = "The policy type, either 'SimpleScaling' , 'StepScaling' or 'TargetTrackingScaling'. If this value isn't provided, AWS will default to 'SimpleScaling'."
  type        = string
}

variable "scaling_adjustment" {
  description = "The number of instances by which to scale. adjustment_type determines the interpretation of this number (e.g., as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity."
  type        = number
}

variable "adjustment_type" {
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity."
  type        = string
}

variable "cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start."
  type        = number
}

# Variables for autoscaling schedule

variable "scheduled_action_name" {
  description = "The name of this scaling action."
  type        = string
}

variable "min_size" {
  description = "The minimum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
  type        = number
}

variable "max_size" {
  description = "The maximum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the maximum size at the scheduled time."
  type        = number
}

variable "desired_capacity" {
  description = "The number of EC2 instances that should be running in the group. Default 0. Set to -1 if you don't want to change the desired capacity at the scheduled time."
  type        = number
}

variable "start_time" {
  description = "The time for this action to start, in YYYY-MM-DDThh:mm:ssZ format in UTC/GMT only (for example, 2014-06-01T00:00:00Z ). If you try to schedule your action in the past, Auto Scaling returns an error message."
  type        = string
}

variable "end_time" {
  description = "The time for this action to end, in YYYY-MM-DDThh:mm:ssZ format in UTC/GMT only (for example, 2014-06-01T00:00:00Z ). If you try to schedule your action in the past, Auto Scaling returns an error message."
  type        = string
}

# Variables for autoscaling attachment

variable "target_group_name" {
  description = "Name of the target group. If omitted, Terraform will assign a random, unique name."
  type        = string
}

variable "port" {
  description = "Port on which targets receive traffic, unless overridden when registering a specific target. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda."
  type        = number
}

variable "protocol" {
  description = "Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda."
  type        = string
}

variable "lb_target_group_name" {
  description = "Name of the target group. If omitted, Terraform will assign a random, unique name."
  type        = string
}

variable "lb_port" {
  description = "Port on which targets receive traffic, unless overridden when registering a specific target. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda."
  type        = number
}

variable "lb_protocol" {
  description = "Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda."
  type        = string
}

# Variables for lifecycle hook

variable "lifecycle_hook_name" {
  description = "The name of the lifecycle hook"
  type        = string
}

variable "default_result" {
  description = "Defines the action the Auto Scaling group should take when the lifecycle hook timeout elapses or if an unexpected failure occurs"
  type        = string
}

variable "heartbeat_timeout" {
  description = "Defines the amount of time, in seconds, that can elapse before the lifecycle hook times out"
  type        = number
}

variable "lifecycle_transition" {
  description = "The instance state to which you want to attach the lifecycle hook."
  type        = string
}

variable "notification_metadata" {
  description = "Contains additional information that you want to include any time Auto Scaling sends a message to the notification target."
  type        = string
}

# Variables for sns

variable "snstopic_name" {
  description = "name of the SNS topic"
  type        = string
}

variable "snstopic_display_name" {
  description = "The display name of the SNS topic"
  type        = string
}

variable "endpoint" {
  description = "Endpoint to send data to. The contents vary with the protocol"
  type        = list(string)
  default     = null
}

variable "sns_protocol" {
  description = "Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application"
  type        = string
  default     = null
}

# Variables for IAM role

variable "iam_name" {
  description = "Name of the iam role"
  type        = string
}

variable "iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}

# Variables for Kms

variable "kms_name" {
  type        = string
  description = "Unique name"
}

variable "kms_description" {
  type        = string
  description = "The description of the key as viewed in AWS console"
}

variable "template_file_name" {
  description = "Policy template file in json format "
  type        = string
}

