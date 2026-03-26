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

# Variables for ecs cluster

variable "cluster_name" {
  description = "Enter the name of the cluster."
  type        = string
}

variable "log_cloud_watch_log_group_name" {
  description = "The name of the CloudWatch log group to send logs to."
  type        = string
}

variable "log_s3_bucket_name" {
  description = "The name of the S3 bucket to send logs to."
  type        = string
  default     = null
}

variable "log_s3_key_prefix" {
  description = "An optional folder in the S3 bucket to place logs in."
  type        = string
  default     = null
}

variable "log_execute_command" {
  description = "The log setting to use for redirecting logs for your execute command results. Valid values are NONE, DEFAULT, and OVERRIDE."
  type        = string
  default     = "OVERRIDE"
  validation {
    condition     = contains(["NONE", "DEFAULT", "OVERRIDE"], var.log_execute_command)
    error_message = "Valid values for logging are NONE, DEFAULT and OVERRIDE."
  }
}

variable "setting_value" {
  description = "The value to assign to the setting. Value values are enabled and disabled."
  type        = string
  validation {
    condition     = contains(["enabled", "disbled"], var.setting_value)
    error_message = "Valid values for setting value are enabled and disabled."
  }
}

# Variables for ecs cluster capacity providers

variable "ecs_cluster_capacity_providers" {
  description = "Set of names of one or more capacity providers to associate with the cluster."
  type        = list(string)
  default     = []
}

variable "ecs_default_capacity_provider" {
  description = "The short name of the capacity provider."
  type        = string
  default     = null
}

variable "ecs_cluster_capacity_weight" {
  description = "The relative percentage of the total number of launched tasks that should use the specified capacity provider."
  type        = number
  default     = 0
}

variable "ecs_cluster_capacity_base" {
  description = "The number of tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined."
  type        = number
  default     = 0
}
variable "kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting logs"
  type        = string
  default     = null
}

# Variables for ecs task defnition wiz

variable "requires_compatibilities" {
  description = "Set of launch types required by the task. The valid values are EC2 and FARGATE."
  type        = list(string)
  default     = ["EC2"]
}

variable "wiz_volumes" {
  description = "A set of volumes blocks that containers in your task may use."
  default = [
    {
      name      = "wiz-host-cache"
      host_path = "/opt/wiz/sensor/host-store"
    },
    {
      name      = "sys-kernel-debug"
      host_path = "/sys/kernel/debug"
    }
  ]
  #type        = list(any)
  type = list(object({
    host_path = string
    name      = string
  }))
}

variable "execution_role_arn_wiz" {
  description = "ARN of the execution role for the ECS task"
  type        = string
}


variable "task_role_arn_wiz" {
  description = "ARN of the task role for the ECS task"
  type        = string
}

# Variables for ecs task daemon set wiz

variable "ecs_service_launch_type" {
  description = "Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2."
  type        = string
  default     = "EC2"
}


variable "daemon_deployment_type" {
  description = "Type of deployment controller. Valid values: CODE_DEPLOY, ECS, EXTERNAL. Default: ECS."
  type        = string
  default     = "ECS"
}


variable "daemon_desired_count" {
  description = "Number of instances of the task definition to place and keep running. Defaults to 0."
  type        = number
  default     = 2
}

variable "scheduling_strategy" {
  description = "Scheduling strategy to use for the service. The valid values are REPLICA and DAEMON. Defaults to REPLICA."
  type        = string
  default     = "DAEMON"
}

variable "subnets" {
  description = "List of subnet IDs for the ECS service"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for the ECS service"
  type        = list(string)
}

# Variables for ecs container definition set for wiz

variable "wiz_registry_credentials" {
  type        = string
  description = "The name given in the parameter store for the wiz_registry_credentials"
  default     = "wiz_registry_credentials"
}

variable "wiz_secret_credential" {
  type        = string
  description = "The name given in the parameter store for the golden wiz_secret_credential"
  default     = "shared-wiz-access"
}