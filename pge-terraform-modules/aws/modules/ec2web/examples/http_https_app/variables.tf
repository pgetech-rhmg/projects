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

variable "asg_health_check_type" {
  description = "Controls how health checking is done."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.asg_health_check_type == null,
      var.asg_health_check_type == "EC2",
    var.asg_health_check_type == "ELB"])
    error_message = "Error! values for asg health check type should be EC2 and ELB."
  }
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

variable "policy_type" {
  description = "The policy type, either 'SimpleScaling' , 'StepScaling' or 'TargetTrackingScaling'. If this value isn't provided, AWS will default to 'SimpleScaling'."
  type        = string
  default     = "SimpleScaling"
  validation {
    condition     = contains(["SimpleScaling", "StepScaling", "TargetTrackingScaling"], var.policy_type)
    error_message = "Valid values for policy type are SimpleScaling, StepScaling and TargetTrackingScaling."
  }
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

variable "subject_alternative_names" {
  description = "A set of domains the should be SANs in the issued certificate."
  type        = list(string)
  default     = []
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


variable "allow_overwrite" {
  description = "Allow creation of this record in Terraform to overwrite an existing record."
  type        = bool
  default     = false
}
