# Variable for tags
variable "tags" {
  description = "A map of tags to populate on the created table."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#Variables for image_builder
variable "name" {
  description = "Unique name for the image builder."
  type        = string
}

variable "description" {
  description = "Description to display."
  type        = string
  default     = null
}

variable "display_name" {
  description = "Human-readable friendly name for the AppStream image builder."
  type        = string
  default     = null
}

variable "image_name" {
  description = "Name of the image used to create the image builder."
  type        = string
  validation {
    condition     = can(regex("^(AppStream-Graphics*|AppStream-Win*|AppStream-AmazonLinux*)", var.image_name))
    error_message = "Invalid image name. Image name must be like AppStream-Graphics-Pro-WinServer2019-07-12-2022."
  }
}

variable "instance_type" {
  description = "The instance type to use when launching the image builder."
  type        = string
  validation {
    condition     = can(regex("^(stream.standard*|stream.compute*|stream.memory*|stream.graphics*|Graphics Prostream.*)", var.instance_type))
    error_message = "Invalid instance type. Enter the instance type that matches the image and Instance families."
  }
}

variable "appstream_agent_version" {
  description = "The version of the AppStream 2.0 agent to use for this image builder."
  type        = string
  default     = null
}

variable "iam_role_arn" {
  description = "ARN of the IAM role to apply to the image builder."
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "Identifiers of the security groups for the image builder or image builder"
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([length(var.security_group_ids) >= 1])
    error_message = "Error! security group must contain at least one security group id."
  }
}

variable "subnet_ids" {
  description = " Identifiers of the subnets to which a network interface is attached from the image builder instance or image builder instance."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([length(var.subnet_ids) >= 1])
    error_message = "Error! Subnet groups must contain at least one subnet."
  }
}

variable "endpoint_type" {
  description = "Type of interface endpoint."
  type        = string
  default     = null
}

variable "vpce_id" {
  description = "Identifier (ID) of the VPC in which the interface endpoint is used. Set to null for internet access."
  type        = string
  default     = null
}

# ✅ DOMAIN JOIN INFO - FULLY SUPPORTED
# Configuration for joining the image builder to a Microsoft Active Directory domain
# Use this when you want the image builder itself to be domain-joined during creation
variable "domain_join_info" {
  description = "Configuration block for the name of the directory and organizational unit (OU) to use to join the image builder to a Microsoft Active Directory domain."
  type = object({
    directory_name                         = string
    organizational_unit_distinguished_name = optional(string)
  })
  default = null
}