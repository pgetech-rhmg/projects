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

# Varaibles for ecs service

variable "service_name" {
  description = "Provide name for the service"
  type        = string
}

variable "capacity_provider_strategy" {
  description = "Capacity provider strategies to use for the service. Can be one or more. These can be updated without destroying and recreating the service only if force_new_deployment = true and not changing from 0 capacity_provider_strategy blocks to greater than 0, or vice versa."
  type        = map(string)
  default     = null
}

variable "deployment_circuit_breaker" {
  description = "Configuration block for deployment circuit breaker."
  type        = map(string)
  default     = null
}

variable "availability_zone_rebalancing" {
  description = "Automatically redistributes tasks within a service across Availability Zones Valid values: ENABLED, DISABLED. Default: DISABLED."
  type        = string
  default     = "DISABLED"
}


variable "deployment_type" {
  description = "Type of deployment controller. Valid values: CODE_DEPLOY, ECS, EXTERNAL. Default: ECS."
  type        = string
  default     = "ECS"
  validation {
    condition     = contains(["CODE_DEPLOY", "ECS", "EXTERNAL"], var.deployment_type)
    error_message = "Valid values for deployment type are  CODE_DEPLOY, ECS and EXTERNAL."
  }
}

variable "deployment_maximum_percent" {
  description = "Upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment. Not valid when using the DAEMON scheduling strategy."
  type        = number
  default     = null
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment."
  type        = number
  default     = null
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running. Defaults to 0."
  type        = number
  default     = 0
}

variable "ecs_service_launch_type" {
  description = "Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2."
  type        = string
  default     = "EC2"
  validation {
    condition     = contains(["EC2", "FARGATE", "EXTERNAL"], var.ecs_service_launch_type)
    error_message = "Valid values for ecs service launch type are  EC2, FARGATE and EXTERNAL."
  }
}
variable "ordered_placement_strategy" {
  description = "Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence. Updates to this configuration will take effect next task deployment unless force_new_deployment is enabled. The maximum number of ordered_placement_strategy blocks is 5."
  type        = map(string)
  default     = null
}

variable "ecs_service_placement_constraints" {
  description = "Rules that are taken into consideration during task placement. Updates to this configuration will take effect next task deployment unless force_new_deployment is enabled. Maximum number of placement_constraints is 10."
  type        = map(string)
  default     = null
}

variable "enable_ecs_managed_tags" {
  description = "Specifies whether to enable Amazon ECS managed tags for the tasks within the service."
  type        = bool
  default     = true
}

variable "enable_execute_command" {
  description = "Specifies whether to enable Amazon ECS Exec for the tasks within the service."
  type        = bool
  default     = false
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination (e.g., myimage:latest), roll Fargate tasks onto a newer platform version, or immediately deploy ordered_placement_strategy and placement_constraints updates."
  type        = bool
  default     = false
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers."
  type        = number
  default     = null
}

variable "iam_role" {
  description = "ARN of the IAM role that allows Amazon ECS to make calls to your load balancer on your behalf. This parameter is required if you are using a load balancer with your service, but only if your task definition does not use the awsvpc network mode. If using awsvpc network mode, do not specify this role. If your account has already created the Amazon ECS service-linked role, that role is used by default for your service unless you specify a role here."
  type        = string
  default     = null
}

variable "target_group_arn" {
  description = "ARN of the Load Balancer target group to associate with the service."
  type        = string
}

variable "load_balancer" {
  description = "Configuration block for load balancers."
  type        = any
}

variable "subnets" {
  description = "Subnets associated with the task or service."
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups associated with the task or service. If you do not specify a security group, the default security group for the VPC is used."
  type        = list(string)
}

variable "ecs_service_cluster_id" {
  description = "ARN of an ECS cluster."
  type        = string
}

variable "ecs_service_task_definition_arn" {
  description = "Family and revision (family:revision) or full ARN of the task definition that you want to run in your service. Required unless using the EXTERNAL deployment controller. If a revision is not specified, the latest ACTIVE revision is used."
  type        = string
}

variable "service_platform_version" {
  description = "Platform version on which to run your service. Only applicable for launch_type set to FARGATE. Defaults to LATEST."
  type        = string
  default     = "LATEST"
}

variable "propagate_tags" {
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK_DEFINITION."
  type        = string
  default     = null
}

variable "scheduling_strategy" {
  description = "Scheduling strategy to use for the service. The valid values are REPLICA and DAEMON. Defaults to REPLICA."
  type        = string
  default     = "REPLICA"
  validation {
    condition     = contains(["REPLICA", "DAEMON"], var.scheduling_strategy)
    error_message = "Valid values for scheduling strategy are  REPLICA and DAEMON."
  }
}

variable "service_registries" {
  description = "Service discovery registries for the service. The maximum number of service_registries blocks is 1."
  type        = map(string)
  default     = null
}

variable "wait_for_steady_state" {
  description = "If true, Terraform will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing. Default false."
  type        = bool
  default     = false
}