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

# Variables for ecs task set

variable "ecs_service_id" {
  description = "The short name or ARN of the ECS service."
  type        = string
}

variable "ecs_cluster_id" {
  description = "The short name or ARN of the cluster that hosts the service to create the task set in."
  type        = string
}

variable "ecs_task_definition_arn" {
  description = "The family and revision (family:revision) or full ARN of the task definition that you want to run in your service."
  type        = string
}

variable "ecs_task_set_capacity_provider_strategy" {
  description = "The capacity provider strategy to use for the service."
  type        = map(string)
  default     = null
}

variable "external_id" {
  description = "The external ID associated with the task set."
  type        = string
  default     = null
}

variable "force_delete" {
  description = "Whether to allow deleting the task set without waiting for scaling down to 0. You can force a task set to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the tasks before deleting the task set. This bypasses that behavior and potentially leaves resources dangling."
  type        = bool
  default     = false
}

variable "ecs_task_launch_type" {
  description = "The launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2."
  type        = string
  default     = "EC2"
  validation {
    condition     = contains(["EC2", "FARGATE", "EXTERNAL"], var.ecs_task_launch_type)
    error_message = "Valid values for ecs task launch type are  EC2, FARGATE and EXTERNAL."
  }
}

variable "task_load_balancer" {
  description = "Details on load balancers that are used with a task set."
  type        = list(map(string))
}

variable "task_target_group_arn" {
  description = "The ARN of the Load Balancer target group to associate with the service."
  type        = string
}

variable "task_set_platform_version" {
  description = "The platform version on which to run your service. Only applicable for launch_type set to FARGATE. Defaults to LATEST."
  type        = string
  default     = "LATEST"
}

variable "task_subnets" {
  description = "The subnets associated with the task or service. Maximum of 16."
  type        = list(string)
}

variable "task_security_groups" {
  description = "The security groups associated with the task or service. If you do not specify a security group, the default security group for the VPC is used. Maximum of 5."
  type        = list(string)
}

variable "task_set_scale_unit" {
  description = "The unit of measure for the scale value. Default: PERCENT."
  type        = string
  default     = "PERCENT"
}

variable "task_set_scale_value" {
  description = "The value, specified as a percent total of a service's desiredCount, to scale the task set. Defaults to 0 if not specified. Accepted values are numbers between 0.0 and 100.0."
  type        = number
  default     = 0
}

variable "task_service_registries" {
  description = "The service discovery registries for the service. The maximum number of service_registries blocks is 1."
  type        = map(string)
  default     = null
}

variable "wait_until_stable" {
  description = "Whether terraform should wait until the task set has reached STEADY_STATE."
  type        = bool
  default     = false
}

variable "wait_until_stable_timeout" {
  description = "Wait timeout for task set to reach STEADY_STATE. Valid time units include ns, us (or µs), ms, s, m, and h. Default 10m."
  type        = string
  default     = "10m"
}