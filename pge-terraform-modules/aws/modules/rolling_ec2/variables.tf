#####################################
# CORE / PROVIDER
#####################################

variable "account_num" {
  type        = string
  description = "AWS account number"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

#########################################
#### IAM – BLUE/GREEN ####
#######################################

variable "bluegreen_iam_role_name" {
  type        = string
  description = "IAM role name for Blue-Green AMI automation"
  default     = "ami_nonbg_testing"
}

variable "bluegreen_iam_services" {
  type        = list(string)
  description = "AWS services allowed to assume the Blue-Green IAM role"
  default = [
    "ec2.amazonaws.com",
    "lambda.amazonaws.com"
  ]
}

#### IAM INSTANCE PROFILE ####

variable "bluegreen_instance_profile_name" {
  type        = string
  description = "IAM instance profile name used by blue/green ASGs"
  default     = "instance_profile"
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



#######################################
#### KMS
#######################################

variable "kms_key_arn" {
  type        = string
  description = "Optional KMS key ARN"
  default     = null
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
variable "alb_log_prefix" {
  type        = string
  description = "S3 prefix for ALB access logs"
  default     = "alb-logs"
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

variable "asg_policy_type" {
  type    = string
  default = "SimpleScaling"
}

variable "asg_scaling_adjustment" {
  type    = number
  default = 1
}

variable "asg_adjustment_type" {
  type    = string
  default = "ChangeInCapacity"
}

variable "asg_cooldown" {
  type    = number
  default = 200
}

variable "create_launch_template" {
  type    = bool
  default = true
}

variable "launch_template_version" {
  type    = string
  default = "$Latest"
}

variable "autoscaling_policy_name" {
  type    = string
  default = "nonbg-scale-a"
}

variable "launch_template_name" {
  type    = string
  default = "nonbg-lt-a"
}

variable "update_default_version" {
  type        = bool
  default     = true
}

#### NETWORK INTERFACE ####

variable "nic_device_index" {
  type    = number
  default = 0
}

variable "associate_public_ip_address" {
  type    = bool
  default = true
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

variable "lambda_runtime" {
  type        = string
  description = "Lambda runtime"
  default     = "python3.9"
}

variable "lambda_timeout" {
  type        = number
  description = "Lambda timeout in seconds"
  default     = 900
}

variable "lambda_publish" {
  type        = bool
  description = "Whether to publish a new Lambda version"
  default     = true
}

variable "lambda_handler" {
  type        = string
  description = "Lambda handler"
  default     = "lambda.lambda_handler"
}

#### LAMBDA ENV VARS ####

variable "tfc_org_name" {
  type        = string
  description = "Terraform Cloud organization name"
  default     = "pgetech"
}

variable "lambda_alias_name" {
  type        = string
  default     = "dev"
  description = "Lambda alias name"
}

variable "lambda_max_retry_attempts" {
  type        = number
  default     = 2
  description = "Maximum Lambda retry attempts"
}

variable "lambda_max_event_age_seconds" {
  type        = number
  default     = 3600
  description = "Maximum event age for Lambda invocation"
}

variable "parameter_store_event_description" {
  type    = string
  default = "Trigger lambda when the golden ami parameter is updated"
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

##########################
#########Cloudwatch
################

variable "retention_in_days" {
  type        = number
  description = "cloud watch retention_in_days"
  default     = 90
}
####################################
######  Secretsmanager  
#################################

variable "secretsmanager_name" {
  description = "Name of the new secret"
  type        = string
  default = "TFC_API_TOKEN"
}

variable "secretsmanager_description" {
  description = "Description of the secret"
  type        = string
  default = "add your Terraform token in secret_string value"
}

variable "secret_version_enabled" {
  description = "Specifies if versioning is set or not"
  type        = bool
  default = true
}

variable "secret_string" {
  type        = string
  description = "Specifies text data that you want to encrypt and store in this version of the secret"
  default = "aaaa"
}