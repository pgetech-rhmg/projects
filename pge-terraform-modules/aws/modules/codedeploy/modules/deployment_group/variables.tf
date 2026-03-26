# Variable for aws_codedeploy_deployment_group
variable "deployment_group_app_name" {
  description = "The name of the application."
  type        = string
}

variable "deployment_group_name" {
  description = "The name of the deployment group."
  type        = string
}

variable "deployment_group_service_role_arn" {
  description = "The service role ARN that allows deployments."
  type        = string
}

variable "deployment_config_name" {
  description = "The name of the group's deployment config."
  type        = string
  default     = "CodeDeployDefault.OneAtATime"
}

variable "autoscaling_groups" {
  description = "Autoscaling groups associated with the deployment group."
  type        = list(string)
  default     = []
}

# Variable for dynamic block - alarm_configuration
variable "alarm_configuration_alarms" {
  description = "A list of alarms configured for the deployment group."
  type        = list(string)
  default     = []
  # validation will confirm whether the alarm_configuration_alarms is less than or equal to 10.
  # A maximum of 10 alarms can be added to a deployment group.
  validation {
    condition = (var.alarm_configuration_alarms == [] ? true : (
    "${length(var.alarm_configuration_alarms)}" <= 10))
    error_message = "Error! Only a maximum of 10 alarms can be added to a deployment group."
  }
}

variable "alarm_configuration_enabled" {
  description = "Indicates whether the alarm configuration is enabled. This option is useful when you want to temporarily deactivate alarm monitoring for a deployment group without having to add the same alarms again later."
  type        = bool
  default     = false
}

variable "alarm_configuration_ignore_poll_alarm_failure" {
  description = "Indicates whether a deployment should continue if information about the current state of alarms cannot be retrieved from CloudWatch."
  type        = bool
  default     = false
}

# Variable for dynamic block - auto_rollback_configuration
variable "auto_rollback_configuration_enabled" {
  description = "Indicates whether a defined automatic rollback configuration is currently enabled for this Deployment Group. If you enable automatic rollback, you must specify at least one event type."
  type        = bool
  default     = false
}

# The validation will confirm that the auto_rollback_configuration_events is getting the valid values.
# It accepts both valid values at a time.
variable "auto_rollback_configuration_events" {
  description = "The event type or types that trigger a rollback. Supported types are DEPLOYMENT_FAILURE and DEPLOYMENT_STOP_ON_ALARM."
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for arce in var.auto_rollback_configuration_events : contains(["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"], arce)
    ])
    error_message = "Error! Valid values for auto_rollback_configuration_events are DEPLOYMENT_FAILURE and DEPLOYMENT_STOP_ON_ALARM."
  }
}

# Variable for dynamic block - blue_green_deployment_config
variable "blue_green_deployment_config" {
  type        = any
  description = <<-DOC
      action_on_timeout:
      When to reroute traffic from an original environment to a replacement environment in a blue/green deployment.
      Valid values are CONTINUE_DEPLOYMENT and STOP_DEPLOYMENT.
      wait_time_in_minutes:
      The number of minutes to wait before the status of a blue/green deployment changed to Stopped if rerouting is not started manually.
      action:
      The method used to add instances to a replacement environment.
      Valid values are DISCOVER_EXISTING and COPY_AUTO_SCALING_GROUP.
      action:
      The action to take on instances in the original environment after a successful blue/green deployment.
      Valid values are TERMINATE and KEEP_ALIVE.
      termination_wait_time_in_minutes:  
      The number of minutes to wait after a successful blue/green deployment before terminating instances from the original environment.
  DOC
  default     = []
}

# Variable for dynamic block - deployment_style
variable "deployment_style" {
  type        = any
  description = <<-DOC
    Configuration of the type of deployment, either in-place or blue/green, 
    you want to run and whether to route deployment traffic behind a load balancer.
    deployment_option:
      Indicates whether to route deployment traffic behind a load balancer. 
      Possible values: `WITH_TRAFFIC_CONTROL`, `WITHOUT_TRAFFIC_CONTROL`.
      Default is WITHOUT_TRAFFIC_CONTROL.
    deployment_type:
      Indicates whether to run an in-place deployment or a blue/green deployment.
      Possible values: `IN_PLACE`, `BLUE_GREEN`.
      Default is IN_PLACE.
  DOC
  default     = []
  # These  validations will confirm that both deployment_option and deployment_type are getting the valid values.
  # Both deployment_option and deployment_type have default vales set in the module.
  validation {
    condition     = alltrue([for va in var.deployment_style : (contains(keys(va), "deployment_option")) ? contains(values(va), "WITH_TRAFFIC_CONTROL") || contains(values(va), "WITHOUT_TRAFFIC_CONTROL") : true])
    error_message = "Error! enter a valid value for deployment_option."
  }

  validation {
    condition     = alltrue([for va in var.deployment_style : (contains(keys(va), "deployment_type")) ? contains(values(va), "IN_PLACE") || contains(values(va), "BLUE_GREEN") : true])
    error_message = "Error! enter a valid value for deployment_type."
  }
}

# Variable for dynamic block - ec2_tag_filter
variable "ec2_tag_filter" {
  type        = any
  description = <<-DOC
  Tag filters associated with the deployment group.Cannot be used in the same call as ec2TagSet.
  key:
   The key of the tag filter.
  type:
   The type of the tag filter, either KEY_ONLY, VALUE_ONLY, or KEY_AND_VALUE.
  value:
   The value of the tag filter.
  DOC
  default     = []
}

# Variable for dynamic block - ec2_tag_set
variable "ec2_tag_set" {
  type        = any
  description = <<-DOC
  Tag filters associated with the deployment group.Cannot be used in the same call as ec2TagSet.
  key:
   The key of the tag filter.
  type:
   The type of the tag filter, either KEY_ONLY, VALUE_ONLY, or KEY_AND_VALUE.
  value:
   The value of the tag filter.
  DOC
  default     = []
}

# Variable for dynamic block - ecs_service
variable "ecs_service" {
  type        = any
  description = <<-DOC
    Configuration block(s) of the ECS services for a deployment group.
    cluster_name:
      The name of the ECS cluster. 
    service_name:
      The name of the ECS service.
  DOC
  default     = []
}

# Variable for dynamic block - load_balancer_info
variable "load_balancer_info" {
  type        = any
  description = "Single configuration block of the load balancer to use in a blue/green deployment."
  default     = []
}

# Variable for dynamic block - on_premises_instance_tag_filter
variable "on_premises_instance_tag_filter" {
  type        = any
  description = <<-DOC
    On premise tag filters associated with the group.
    key:
      The key of the tag filter.
    type:
       The type of the tag filter, either KEY_ONLY, VALUE_ONLY, or KEY_AND_VALUE.
    value:
       The value of the tag filter. 
  DOC
  default     = []
}

# Variable for dynamic block - trigger_configuration
variable "trigger_configuration" {
  type        = any
  description = <<-DOC
    Add triggers to a Deployment Group to receive notifications about events related to deployments or instances in the group.
    trigger_events:
      The event type or types for which notifications are triggered. 
    trigger_name:
       The name of the notification trigger.
    trigger_target_arn:
        The ARN of the SNS topic through which notifications are sent.
  DOC
  default     = []
}

#Variable for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}