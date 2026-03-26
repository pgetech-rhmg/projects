# Variables for tags

variable "tags" {
  description = "A map of tags to add to ECS Cluster"
  type        = map(string)
  default     = {}
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.0"
  tags    = var.tags
}

# Variables for ecs cluster

variable "cluster_name" {
  description = "Enter the name of the cluster"
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
  description = "Set of names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE_SPOT."
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for providers in var.ecs_cluster_capacity_providers : contains(["FARGATE", "FARGATE_SPOT"], providers)
    ])
    error_message = "Error! values for ecs_cluster_capacity_providers are FARGATE, FARGATE_SPOT."
  }
}

variable "ecs_default_cluster_capacity_provider" {
  description = "The short name of the capacity provider."
  type        = string
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


##wiz

variable "wiz_logDriver" {
  description = "identify the logDriver"
  type        = string
  default     = "awslogs"
}

variable "wiz_container_cpu" {
  type        = number
  default     = "0"
  description = "The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container_cpu of all containers in a task will need to be lower than the task-level cpu value"
}

variable "wiz_container_memory_reservation" {
  type        = number
  default     = "50"
  description = "The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container_memory hard limit"
}

variable "wiz_essential" {
  type        = bool
  default     = false
  description = "Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value"
}


variable "wiz_privileged" {
  type        = bool
  description = "When this variable is `true`, the container is given elevated privileges on the host container instance (similar to the root user). This parameter is not supported for Windows containers or tasks using the Fargate launch type."
  default     = false
}

variable "wiz_port_mappings" {
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))

  description = "The port mappings to configure for the container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort"

  default = []
}


variable "wiz_mount_points" {
  type = list(object({
    containerPath = string
    sourceVolume  = string
    readOnly      = bool
  }))
  default     = []
  description = "Container mount points. This is a list of maps, where each map should contain `containerPath`, `sourceVolume` and `readOnly`"
}


variable "wiz_container_name" {
  type        = string
  default     = "wiz-sensor"
  description = "The name of the container. Up to 255 characters ([a-z], [A-Z], [0-9], -, _ allowed)"
}

variable "wiz_container_image" {
  type        = string
  default     = "wizio.azurecr.io/sensor-serverless:v1"
  description = "The image used to start the container. Images in the Docker Hub registry available by default"
}

variable "wiz_environment" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "The environment variables to pass to the container. This is a list of maps. map_environment overrides environment"
}

variable "wiz_readonly_root_filesystem" {
  type        = bool
  description = "Determines whether a container is given read-only access to its root filesystem. Due to how Terraform type casts booleans in json it is required to double quote this value"
  default     = true
}



variable "wiz_linux_parameters" {
  type = object({
    capabilities = object({
      add  = list(string)
      drop = list(string)
    })
    devices = list(object({
      containerPath = string
      hostPath      = string
      permissions   = list(string)
    }))
    initProcessEnabled = bool
    maxSwap            = number
    sharedMemorySize   = number
    swappiness         = number
    tmpfs = list(object({
      containerPath = string
      mountOptions  = list(string)
      size          = number
    }))
  })
  description = "Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html"
  default = {
    capabilities = {
      add  = []
      drop = []
    }
    devices            = []
    initProcessEnabled = false
    maxSwap            = null
    sharedMemorySize   = null
    swappiness         = null
    tmpfs              = []
  }
}


variable "wiz_volumes_from" {
  type = list(object({
    sourceContainer = string
    readOnly        = bool
  }))
  description = "A list of VolumesFrom maps which contain \"sourceContainer\" (name of the container that has the volumes to mount) and \"readOnly\" (whether the container can write to the volume)"
  default     = []
}

variable "wiz_volumes" {
  description = "A set of volumes blocks that containers in your task may use."
  default     = []
  #type        = list(any)
  type = list(object({
    host_path = string
    name      = string
  }))
}


variable "wiz_registry_credentials" {
  type        = string
  description = "The name given in the parameter store for the wiz_registry_credentials"
  default     = "wiz_registry_credentials"
}

