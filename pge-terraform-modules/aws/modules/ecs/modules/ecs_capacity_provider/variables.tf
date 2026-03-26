# Variables for tags
variable "tags" {
  description = "A map of tags to add to ECS Cluster"
  type        = map(string)
  default     = {}
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# Variables for ecs capacity provider
variable "ecs_capacity_provider_name" {
  description = "Name of the capacity provider."
  type        = string
}

variable "autoscaling_group_arn" {
  description = "The Amazon Resource Name (ARN) of the associated auto scaling group."
  type        = string
  validation {
    condition = anytrue([
      can(regex("^arn:aws:autoscaling:\\w+(?:-\\w+)+:[[:digit:]]{12}:autoScalingGroup:([a-zA-Z0-9])+(.*)$", var.autoscaling_group_arn))
    ])
    error_message = "Error! enter a valid asg arn."
  }
}

variable "asg_instance_warmup_period" {
  description = "Period of time, in seconds, after a newly launched Amazon EC2 instance can contribute to CloudWatch metrics for Auto Scaling group. If this parameter is omitted, the default value of 300 seconds is used."
  type        = number
  default     = null
}

variable "asg_status" {
  description = "Whether auto scaling is managed by ECS. Valid values are ENABLED and DISABLED."
  type        = string
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.asg_status)
    error_message = "Valid values for asg status are ENABLED and DISABLED."
  }
}

variable "asg_target_capacity" {
  description = "Target utilization for the capacity provider. A number between 1 and 100."
  type        = number
  default     = null
}

variable "asg_maximum_scaling_step_size" {
  description = "Maximum step adjustment size. A number between 1 and 10,000."
  type        = number
  default     = null
}

variable "asg_minimum_scaling_step_size" {
  description = "Minimum step adjustment size. A number between 1 and 10,000."
  type        = number
  default     = null
}

variable "managed_termination_protection" {
  description = "Enables or disables container-aware termination of instances in the auto scaling group when scale-in happens. Valid values are ENABLED and DISABLED."
  type        = string
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.managed_termination_protection)
    error_message = "Valid values for managed termination protection are ENABLED and DISABLED."
  }
}