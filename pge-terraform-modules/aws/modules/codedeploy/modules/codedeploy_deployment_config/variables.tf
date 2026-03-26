# Variable for aws_codedeploy_app
variable "deployment_config_name" {
  description = "The name of the deployment config."
  type        = string
}

# The variable deployment_config_compute_platform can only take ECS, Lambda, or Server as the valid input values.
# The default value is Server.
variable "deployment_config_compute_platform" {
  description = "The compute platform can either be ECS, Lambda, or Server."
  type        = string
  default     = "Server"
  validation {
    condition     = contains(["ECS", "Lambda", "Server"], var.deployment_config_compute_platform)
    error_message = "Error! Please enter a valid value for deployment_config_compute_platform. Valid values are ECS, Lambda, or Server ."
  }
}

# minimum_healthy_hosts block. Required for Server compute platform.
variable "minimum_healthy_hosts" {
  description = <<-DOC
    type:
      The type can either be `FLEET_PERCENT` or `HOST_COUNT`.
    value:
      The value when the type is `FLEET_PERCENT` represents the minimum number of healthy instances 
      as a percentage of the total number of instances in the deployment.
      When the type is `HOST_COUNT`, the value represents the minimum number of healthy instances as an absolute value.
  DOC
  type = object({
    type  = string
    value = number
  })
  default = null
}

# traffic_routing_config block. Required for ECS and Lambda compute platform.
variable "traffic_routing_config" {
  description = <<-DOC
    type:
      Type of traffic routing config. One of `TimeBasedCanary`, `TimeBasedLinear`, `AllAtOnce`.
    interval:
      The number of minutes between the first and second traffic shifts of a deployment.
    percentage:
      The percentage of traffic to shift in the first increment of a deployment.
  DOC
  type = object({
    type       = string
    interval   = number
    percentage = number
  })
  default = null
}

