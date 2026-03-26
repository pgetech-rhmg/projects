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
  description = "AWS role to assume"
  type        = string
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

#variable for tags

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
  description = "Allows deleting the Auto Scaling Group without waiting for all instances in the pool to terminate."
  type        = bool
}

#Variables for lifecycle hook

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

variable "protocol" {
  description = "Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application"
  type        = string
  default     = null
}

variable "policy_file_name" {
  description = "Valid JSON document representing a resource policy"
  type        = string
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

#Variables for autoscaling_schedule

variable "scheduled_action_name" {
  description = "The name of this scaling action."
  type        = string
}

variable "start_time" {
  description = "The time for this action to start, in YYYY-MM-DDThh:mm:ssZ format in UTC/GMT only (for example, 2014-06-01T00:00:00Z ). If you try to schedule your action in the past, Auto Scaling returns an error message."
  type        = string
}

variable "end_time" {
  description = "The time for this action to end, in YYYY-MM-DDThh:mm:ssZ format in UTC/GMT only (for example, 2014-06-01T00:00:00Z ). If you try to schedule your action in the past, Auto Scaling returns an error message."
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
  description = "The number of Amazon EC2 instances that should be running in the group"
  type        = number
}
#variables for aws_lambda_iam_role

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

variable "template_file_name" {
  description = "Policy template file in json format "
  type        = string
  default     = ""
}

#variables for kms_key

variable "kms_name" {
  type        = string
  description = "Unique name"
}

variable "kms_description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console"
}

#variables for security groups

variable "sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "sg_description" {
  description = "Description for the security group"
  type        = string
}

variable "cidr_ingress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

# asg with launch template

variable "create_launch_template" {
  description = "Determines whether to create launch template or not"
  type        = bool
  default     = true
}

variable "launch_template_name" {
  description = "Creates a unique name beginning with the specified prefix."
  type        = string
}

variable "launch_template_version" {
  description = "Version of the launch template, values for launch_template_version should be $Latest or $Default."
  type        = string
  default     = "$Default"

}

variable "instance_type" {
  type        = string
  description = "The size of instance to launch"
  default     = null
}

variable "parameter_golden_ami_name" {
  type        = string
  description = "The name given in the parameter store for the golden ami"
}

variable "instance_name" {
  description = "Name to be used on EC2 instance created"
  type        = string
}

variable "block_device_mappings" {
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI"
  type        = list(any)
  default     = []
}
