#####################################
# CORE / PROVIDER
#####################################
variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "account_num" {
  type        = string
  description = "AWS account number"
}

variable "aws_role" {
  type        = string
  description = "IAM role name for assuming into app account."
}


#####################################
# NETWORKING
#####################################
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for ALB and ASG"
}


#####################################
# TAGS (PGE STANDARD)
#####################################
variable "AppID" {
  type        = number
  description = "AMPS App ID"
}

variable "Environment" {
  type        = string
  description = "Environment (Dev/Test/Prod)"
}

variable "DataClassification" {
  type        = string
  description = "Data classification"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score"
}

variable "Notify" {
  type        = list(string)
  description = "Notification emails"
}

variable "Owner" {
  type        = list(string)
  description = "Application owners"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance tags"
}

variable "Order" {
  type        = number
  description = "Order tag"
}

variable "optional_tags" {
  type        = map(string)
  default     = {}
  description = "Optional tags"
}


#######################################
#### Security Group
#######################################
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


#####################################
# ALB
#####################################
variable "alb_name" {
  type        = string
  description = "ALB name"
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

#####################################
# ASG
#####################################
variable "asg_name" {
  type        = string
  description = "Auto Scaling Group name"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "min_size" {
  type        = number
  description = "ASG minimum size"
}

variable "max_size" {
  type        = number
  description = "ASG maximum size"
}

variable "desired_capacity" {
  type        = number
  description = "ASG desired capacity"
}

#####################################
# AMI
#####################################
variable "latest_ami_param_name" {
  type        = string
  description = "SSM parameter for latest AMI"
}

variable "ami_catalog_param_name" {
  type        = string
  default     = "/app/nonbluegreen/ami_catalog"
  description = "SSM parameter name for AMI catalog JSON."
}

variable "release_version" {
  type        = string
  description = "AMI version to deploy (latest or version number)"
  default     = "latest"

  validation {
    condition     = var.release_version == "latest" || can(tonumber(var.release_version))
    error_message = "release_version must be 'latest' or a number"
  }
}

#####################################
# S3 / LOGS
#####################################
variable "lambda_bucket_name" {
  type        = string
  description = "S3 bucket for ALB logs and lambda artifacts"
}

variable "lambda_function_name" {
  type        = string
  description = "Lambda function name for AMI automation"
  default     = null
}


#####################################
# AUTOMATION FLAGS (FUTURE SAFE)
#####################################
variable "enable_ami_automation" {
  type        = bool
  default     = false
  description = "Enable AMI automation via Lambda"
}

variable "auto_apply_ami_updates" {
  type        = bool
  default     = false
  description = "Allow Lambda to auto-apply Terraform runs"
}