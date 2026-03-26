########################################
##Variables for IAM roles
########################################

#####Variables for IAM



variable "iam_role_start_stop" {
  type        = string
  description = "Aws service of the iam role"
}
########################################
## Variables for RDS Auto Start Stop
########################################

variable "rds_auto_control_service_name" {
  type        = string
  description = "RDS auto control service name"
}

variable "rds_auto_start_tag" {
  type        = string
  description = "Set it to yes if auto start needs to be enabled"
  default     = "no"
}

variable "rds_auto_stop_tag" {
  type        = string
  description = "Set it to yes if auto stop needs to be enabled"
  default     = "no"
}



variable "lambda_runtime" {
  description = "Identifier of the function's runtime"
  type        = string
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
}

variable "schedule_rds_auto_start" {
  description = "Cron schedule to trigger lambda function"
  type        = string
}

variable "schedule_rds_auto_stop" {
  description = "Cron schedule to trigger lambda function"
  type        = string
}

# validate the tags passed
module "validate-pge-tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
}


variable "vpc_config_security_group_ids" {
  description = "List of security group IDs associated with the Lambda function"
  type        = list(string)
}

variable "vpc_config_subnet_ids" {
  description = "List of subnet IDs associated with the Lambda function"
  type        = list(string)
}
