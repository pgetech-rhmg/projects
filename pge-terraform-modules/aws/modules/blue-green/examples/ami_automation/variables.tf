variable "aws_region" {
  type        = string
  description = "AWS region."
}

variable "account_num" {
  type        = string
  description = "AWS account ID for app infra."
}

variable "aws_role" {
  type        = string
  description = "IAM role name for assuming into app account."
}


variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for ALB and ASG."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
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

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
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
  description = "Optional tags"
  type        = map(string)
  default     = {}
}

variable "lambda_bucket_name" {
  description = "S3 bucket to store the lambda function"
  type        = string
  default     = null
}

variable "latest_ami_param_name" {
  type        = string
  default     = "/app/bluegreen/latest_ami"
  description = "SSM parameter name holding latest AMI ID."
}

variable "ami_catalog_param_name" {
  type        = string
  default     = "/app/bluegreen/ami_catalog"
  description = "SSM parameter name for AMI catalog JSON."
}

variable "green_percent" {
  type        = number
  default     = 100
  description = "Traffic percentage to send to green TG (0–100)."
}

variable "release_version" {
  type        = string
  default     = "latest"
  description = "AMI version to treat as N. Use 'latest' or specific version number."
}

variable "blue_mode" {
  type        = string
  default     = "relative_to_selected"
  description = "How blue AMI is selected: 'relative_to_selected', 'relative_to_latest', or 'pinned'."
}

variable "blue_pinned_ami_id" {
  type        = string
  default     = ""
  description = "If blue_mode = 'pinned', use this AMI ID for blue."
}

variable "blue_min_size" {
  type    = number
  default = 0
}

variable "blue_max_size" {
  type    = number
  default = 2
}

variable "blue_desired_capacity" {
  type    = number
  default = 0
}

variable "green_min_size" {
  type    = number
  default = 1
}

variable "green_max_size" {
  type    = number
  default = 2
}

variable "green_desired_capacity" {
  type    = number
  default = 2
}

variable "blue_asg_name" {
  type    = string
  default = "blue_asg"
}
variable "green_asg_name" {
  type    = string
  default = "green_asg"
}

variable "lambda_function_name" {
  description = "The AWS Lambda action you want to allow in this statement"
  type        = string
  default     = null
}
variable "alb_name" {
  type        = string
  description = "Name of the alb"
}
variable "security_group_name" {
  type        = string
  description = "Security group name"
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
  default     = []
  description = "Configuration block for ingress rules. Can be specified multiple times for each ingress rule."
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
  default     = []
  description = "Configuration block for egress rules. Can be specified multiple times for each egress rule."
}

variable "security_group_ingress_rules" {
  type = list(object({
    from                     = number
    to                       = number
    protocol                 = string
    source_security_group_id = string
    description              = string
  }))
  default     = []
  description = "Configuration block for nested security groups ingress rules. Can be specified multiple times for each ingress rule."
}


variable "lb_target_group" {
  type = list(object({
    name        = string
    target_type = string
    port        = number
    protocol    = string
    health_check = list(object({
      enabled             = bool
      healthy_threshold   = number
      interval            = number
      matcher             = string
      path                = string
      port                = string
      protocol            = string
      timeout             = number
      unhealthy_threshold = number
    }))
    stickiness = list(object({
      enabled         = bool
      type            = string
      cookie_duration = number
    }))
  }))
}

variable "lb_listener_https" {
  type = list(object({
    port              = number
    protocol          = string
    type              = string
    target_group_name = string
    certificate_arn   = string
  }))
}



#######################################
#### AMI AUTOMATION FLAGS (ASHOK)
#######################################
variable "enable_ami_automation" {
  type        = bool
  description = "Enable AMI automation via Lambda"
  default     = false
}

variable "auto_apply_ami_updates" {
  type        = bool
  description = "Auto-apply Terraform runs triggered by AMI updates"
  default     = false
}