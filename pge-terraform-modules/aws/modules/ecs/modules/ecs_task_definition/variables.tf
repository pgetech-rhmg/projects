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

# Variables for ecs task definition

variable "family_service" {
  description = "A unique name for your task definition."
  type        = string
}

variable "requires_compatibilities" {
  description = "Set of launch types required by the task. The valid values are EC2 and FARGATE."
  type        = list(string)
}

variable "cpu" {
  description = "Number of cpu units used by the task. If the requires_compatibilities is FARGATE this field is required."
  type        = number
  default     = null
}

variable "execution_role_arn" {
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume."
  type        = string
}

variable "memory" {
  description = "Amount (in MiB) of memory used by the task. If the requires_compatibilities is FARGATE this field is required."
  type        = number
  default     = null
}

variable "ipc_mode" {
  description = "The IPC resource namespace to be used for the containers in the task The valid values are host, task, and none."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.ipc_mode == null,
      var.ipc_mode == "host",
      var.ipc_mode == "task",
    var.ipc_mode == "none"])
    error_message = "Error! values for ipc mode should be host, task and none."
  }
}

variable "network_mode" {
  description = "The IPC resource namespace to be used for the containers in the task The valid values are host, task, and none."
  type        = string
  default     = "awsvpc"
  validation {
    condition = anytrue([
      var.network_mode == "none",
      var.network_mode == "bridge",
      var.network_mode == "awsvpc",
    var.network_mode == "host"])
    error_message = "Error! values for network mode should be host, awsvpc, bridge and none."
  }
}

variable "pid_mode" {
  description = "The process namespace to use for the containers in the task. The valid values are host and task."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.pid_mode == null,
      var.pid_mode == "host",
    var.pid_mode == "task"])
    error_message = "Error! values for pid mode should be host and task."
  }
}

variable "docker_volume_configuration" {
  description = "Configuration block to configure a docker volume."
  type        = map(string)
  default     = null
}
variable "volumes" {
  description = "A set of volumes blocks that containers in your task may use."
  #type        = list(any)
  type = list(object({
    host_path = string
    name      = string
  }))
  default = []
}

variable "efs_volume_configuration" {
  description = "Configuration block for an EFS volume."
  type        = map(string)
  default     = null
}

variable "authorization_config" {
  description = "Configuration block for authorization for the Amazon EFS file system."
  type        = map(string)
  default     = null
}

variable "fsx_windows_file_server_volume_configuration" {
  description = "Configuration block for an FSX Windows File Server volume."
  type        = map(string)
  default     = null
}

variable "placement_constraints" {
  description = "Configuration block for rules that are taken into consideration during task placement. Maximum number of placement_constraints is 10."
  type        = map(string)
  default     = null
}

variable "proxy_configuration" {
  description = "Configuration block for the App Mesh proxy."
  type        = map(string)
  default     = null
}

variable "runtime_platform" {
  description = "Configuration block for runtime_platform that containers in your task may use."
  type        = map(string)
  default     = null
}

variable "ephemeral_storage" {
  description = "The amount of ephemeral storage to allocate for the task. This parameter is used to expand the total amount of ephemeral storage available, beyond the default amount, for tasks hosted on AWS Fargate."
  type        = map(string)
  default     = null
}

variable "task_role_arn" {
  description = "ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services."
  type        = string
}

variable "credentials_parameter" {
  description = "The authorization credential option to use. The authorization credential options can be provided using either the Amazon Resource Name (ARN) of an AWS Secrets Manager secret or AWS Systems Manager Parameter Store parameter. The ARNs refer to the stored credentials."
  type        = string
  default     = null
}

variable "domain" {
  description = "A fully qualified domain name hosted by an AWS Directory Service Managed Microsoft AD (Active Directory) or self-hosted AD on Amazon EC2."
  type        = string
  default     = null
}

variable "container_definition" {
  type        = any
  description = "Container definition overrides which allows for extra keys or overriding existing keys."
  default     = {}
}