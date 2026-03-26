variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_r53_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "account_num_r53" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
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

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
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

variable "optional_tags" {
  description = "A map of optional tags to add to all resources."
  type        = map(string)
  default     = {}
}

# ASG
variable "asg_name" {
  description = "The name of the Auto Scaling Group"
  type        = string
  default     = null
}

variable "instance_type" {
  type = string
}

variable "autoscaling_policy_name" {
  description = "The name of the Policy."
  type        = string
}

variable "scaling_adjustment" {
  description = "The number of instances by which to scale."
  type        = number
}

variable "adjustment_type" {
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity."
  type        = string
  default     = null
}

# ALB
variable "alb_name" {
  description = "Name of the alb on AWS"
  type        = string
}

variable "alb_target_group_name" {
  description = "Name of the target group on AWS"
  type        = string
}

variable "launch_template_name" {
  description = "Name of the launch template."
  type        = string
}

variable "alb_log_bucket_name" {
  description = "Name of the s3 bucket to store alb logs on AWS"
  type        = string
}

variable "custom_domain_name" {
  description = "The domain name for which the certificate should be issued."
  type        = string
}

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

variable "ec2_cidr_ingress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default     = []
  description = "Configuration block for ingress rules. Can be specified multiple times for each ingress rule."
}

variable "ec2_cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default     = []
  description = "Configuration block for egress rules. Can be specified multiple times for each egress rule."
}

variable "alb_cidr_ingress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default     = []
  description = "Configuration block for ingress rules. Can be specified multiple times for each ingress rule."
}

variable "alb_cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default     = []
  description = "Configuration block for egress rules. Can be specified multiple times for each egress rule."
}

variable "ec2_security_groups_name" {
  description = "The common name for all the name arguments in resources."
  type        = string
}

variable "alb_security_groups_name" {
  description = "The common name for all the name arguments in resources."
  type        = string
}

variable "block_device_mappings" {
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI"
  type        = list(any)
  default     = []
}

variable "lb_listener_http" {
  description = "A list of maps describing HTTP listeners for ALB."
  type        = any
  default     = []
}

variable "https_port" {
  description = " https Port on which targets receive traffic, unless overridden when registering a specific target"
  type        = number
}

variable "https_protocol" {
  description = "https Protocol to use for routing traffic to the targets"
  type        = string
}


variable "https_type" {
  description = "Type of target that you must specify when registering targets with this target group"
  type        = string
}

variable "https_ssl_policy" {
  description = "https SSL Policy for the LB Listener HTTPS"
  type        = string
}

variable "lb_health_check" {
  description = "Health Check for LB target group"
  type        = any
}

variable "lb_stickiness" {
  description = "Stickiness for LB target group"
  type        = any
}

variable "target_type" {
  description = "Target Type for LB target group"
  type        = string
}

variable "target_port" {
  description = "Port for LB target group"
  type        = number
}

variable "target_protocol" {
  description = "Protocol for LB target group"
  type        = string
}

# Scheduler
variable "schedules" {
  description = "List of schedules with start and stop times"
  type        = list(any)
}
