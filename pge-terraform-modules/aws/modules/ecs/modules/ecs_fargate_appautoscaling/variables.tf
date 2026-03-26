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

#Autoscalling

variable "resource_id" {
  description = "The identifier of the resource to scale"
  type        = string
  default     = ""
}

variable "use_target_tracking_scaling" {
  description = "Whether to use target tracking scaling policy or step scaling policy"
  type        = bool
  default     = true
}

variable "max_capacity" {
  description = "The maximum number of tasks that can be running at any one time"
  type        = number
  default     = 5
}

variable "min_capacity" {
  description = "The minimum number of tasks that can be running at any one time"
  type        = number
  default     = 1
}

variable "step_scaling_policy_configuration" {
  description = "Configuration for step scaling policy"
  type = object({
    adjustment_type         = string
    cooldown                = number
    metric_aggregation_type = string
    step_adjustment = list(object({
      metric_interval_lower_bound = number
      metric_interval_upper_bound = number
      scaling_adjustment          = number
    }))
  })
  default = {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"
    step_adjustment = [
      {
        metric_interval_lower_bound = 2.0
        metric_interval_upper_bound = 3.0
        scaling_adjustment          = 1
      }
    ]
  }
}


variable "target_tracking_scaling_policy_configuration" {
  description = "Configuration for target tracking scaling policy"
  type = object({
    target_value       = number
    scale_in_cooldown  = number
    scale_out_cooldown = number
    disable_scale_in   = bool
    predefined_metric_specification = list(object({
      predefined_metric_type = string
    }))
  })
  default = {
    target_value       = 50.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    disable_scale_in   = false
    predefined_metric_specification = [
      {
        predefined_metric_type = "ECSServiceAverageCPUUtilization"
      }
    ]
  }
}


variable "step_scaling_policy_name" {
  description = "The name of the step scaling policy"
  type        = string
  default     = ""
}


variable "target_tracking_scaling_policy_name" {
  description = "The name of the target tracking scaling policy"
  type        = string
  default     = ""
}


variable "create_autoscaling" {
  description = "Whether to create autoscaling"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting logs"
  type        = string
  default     = null
}
