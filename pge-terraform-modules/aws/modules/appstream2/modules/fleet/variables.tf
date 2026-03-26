variable "instance_type" {
  description = "Instance type to use when launching fleet instances."
  type        = string
  validation {
    condition = contains(["stream.standard.small",
      "stream.standard.medium",
      "stream.standard.large",
      "stream.standard.xlarge",
      "stream.standard.2xlarge",
      "stream.compute.large",
      "stream.compute.xlarge",
      "stream.compute.2xlarge",
      "stream.compute.4xlarge",
      "stream.compute.8xlarge",
      "stream.memory.large",
      "stream.memory.xlarge",
      "stream.memory.2xlarge",
      "stream.memory.4xlarge",
      "stream.memory.8xlarge",
      "stream.memory.z1d.large",
      "stream.memory.z1d.xlarge",
      "stream.memory.z1d.2xlarge",
      "stream.memory.z1d.3xlarge",
      "stream.memory.z1d.6xlarge",
      "stream.memory.z1d.12xlarge",
      "stream.graphics-desktop.2xlarge",
      "stream.graphics-desktop.2xlarge",
      "stream.graphics-design.large",
      "stream.graphics-design.xlarge",
      "stream.graphics-design.2xlarge",
      "stream.graphics-design.4xlarge",
      "Graphics Prostream.graphics-pro.4xlarge16122",
      "Graphics Prostream.graphics-pro.8xlarge32244",
      "Graphics Prostream.graphics-pro.16xlarge64488",
      "stream.graphics.g4dn.xlarge",
      "stream.graphics.g4dn.2xlarge",
      "stream.graphics.g4dn.4xlarge",
      "stream.graphics.g4dn.8xlarge",
      "stream.graphics.g4dn.12xlarge",
      "stream.graphics.g4dn.16xlarge",
      "stream.graphics.g5.xlarge",
      "stream.graphics.g5.2xlarge",
      "stream.graphics.g5.4xlarge",
      "stream.graphics.g5.8xlarge",
      "stream.graphics.g5.12xlarge",
      "stream.graphics.g5.16xlarge",
      "stream.graphics.g5.24xlarge",
      "stream.graphics.g6.xlarge",
      "stream.graphics.g6.2xlarge",
      "stream.graphics.g6.4xlarge",
      "stream.graphics.g6.8xlarge",
      "stream.graphics.g6.12xlarge",
      "stream.graphics.g6.16xlarge",
      "stream.graphics.g6.24xlarge",
      "stream.graphics.g6.48xlarge",
      "stream.graphics.g6e.xlarge",
      "stream.graphics.g6e.2xlarge",
      "stream.graphics.g6e.4xlarge",
      "stream.graphics.g6e.8xlarge",
      "stream.graphics.g6e.12xlarge",
      "stream.graphics.g6e.16xlarge",
      "stream.graphics.g6e.24xlarge",
      "stream.graphics.g6e.48xlarge",
      "stream.graphics.g6f.large",
      "stream.graphics.g6f.xlarge",
      "stream.graphics.g6f.2xlarge",
      "stream.graphics.g6f.4xlarge"
    ], var.instance_type)
    error_message = "Invalid instance type."
  }
}

variable "name" {
  description = "Unique name for the fleet."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,100}$", var.name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ - (hyphen)."
  }
}

variable "description" {
  description = "Description to display."
  type        = string
  default     = null
}

variable "disconnect_timeout_in_seconds" {
  description = "Amount of time that a streaming session remains active after users disconnect."
  type        = number
  default     = null
}

variable "display_name" {
  description = "Human-readable friendly name for the AppStream fleet."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{0,100}$", var.display_name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ - (hyphen)."
  }
}

variable "fleet_type" {
  description = "Fleet type. Valid values are: ON_DEMAND, ALWAYS_ON,ELASTIC"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition = anytrue([
      var.fleet_type == "ON_DEMAND",
      var.fleet_type == "ALWAYS_ON",
    var.fleet_type == "ELASTIC"])
    error_message = "Error! values for 'fleet_type' should be 'ON_DEMAND','ALWAYS_ON','ELASTIC'."
  }
}

variable "iam_role_arn" {
  description = "ARN of the IAM role to apply to the fleet."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      can(regex("^arn:aws:iam::[[:digit:]]{12}:role/([a-zA-Z0-9])+(.*)$", var.iam_role_arn)),
      var.iam_role_arn == null
    ])
    error_message = "Role arn is required and the allowed format is arn:aws:iam::<account-id>:role/<aws-service-role-name>."
  }
}

variable "idle_disconnect_timeout_in_seconds" {
  description = "Amount of time that users can be idle (inactive) before they are disconnected from their streaming session and the disconnect_timeout_in_seconds time interval begins."
  type        = number
  default     = null
}

variable "image_name" {
  description = "Name of the image used to create the fleet."
  type        = string
  default     = null
}

variable "image_arn" {
  description = "ARN of the public, private, or shared image to use."
  type        = string
  default     = null
}

variable "stream_view" {
  description = "AppStream 2.0 view that is displayed to your users when they stream from the fleet. When APP is specified, only the windows of applications opened by users display. When DESKTOP is specified, the standard desktop that is provided by the operating system displays. If not specified, defaults to APP."
  type        = string
  default     = "APP"
  validation {
    condition = anytrue([
      var.stream_view == null,
      var.stream_view == "APP",
    var.stream_view == "DESKTOP", ])
    error_message = "Error! values for 'stream_view' should be 'APP' and 'DESKTOP'."
  }
}

variable "max_user_duration_in_seconds" {
  description = "Maximum amount of time that a streaming session can remain active, in seconds."
  type        = number
  default     = null
}

variable "desired_instances" {
  description = "Desired number of streaming instances."
  type        = number
}

variable "security_group_ids" {
  description = "Identifiers of the security groups for the fleet or image builder."
  type        = list(string)
}

variable "subnet_ids" {
  description = " Identifiers of the subnets to which a network interface is attached from the fleet instance or image builder instance."
  type        = list(string)
  validation {
    condition = alltrue([
      for i in var.subnet_ids : can(regex("^subnet-([a-zA-Z0-9])+(.*)$", i))
    ])
    error_message = "Subnet_ids required and the allowed format of 'subnet_ids' is subnet-#########."
  }
}

variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# Domain join configuration for fleet instances
variable "domain_join_info" {
  description = "Configuration block for the name of the directory and organizational unit (OU) to use to join the fleet to a Microsoft Active Directory domain."
  type = object({
    directory_name                         = string
    organizational_unit_distinguished_name = optional(string)
  })
  default = null
}