# variables for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# variables for notebook_instnace
variable "instance_name" {
  description = "The name of the notebook instance (must be unique)."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,100}$", var.instance_name))
    error_message = "Allowed alphanumeric characters: a-z, A-Z, 0-9, and - (hyphen)."
  }
  validation {
    condition     = anytrue([length(var.instance_name) <= 63])
    error_message = "Maximum of 63 alphanumeric characters. Can include hyphens (-), but not spaces. Must be unique within your account in an AWS Region."
  }
}

variable "role_arn" {
  description = "The ARN of the IAM role to be used by the notebook instance which allows SageMaker to call other services on your behalf."
  type        = string
}

variable "instance_type" {
  description = "The name of ML compute instance type."
  type        = string
  validation {
    condition     = can(regex("^(ml.t2*|ml.t3*|ml.m5*|ml.m5d*|ml.m4*|ml.c5*|ml.c5d*|ml.c4*|ml.r5*|ml.p2*|ml.p3*|ml.p3dn*|ml.g4dn*|ml.g5*)", var.instance_type))
    error_message = "Invalid instance type."
  }
}

variable "platform_identifier" {
  description = "The platform identifier of the notebook instance runtime environment. This value can be either notebook-al1-v1, notebook-al2-v1, notebook-al2-v2 or notebook-al2-v3, depending on which version of Amazon Linux you require."
  type        = string
  default     = null
}

variable "volume_size" {
  description = "The size, in GB, of the ML storage volume to attach to the notebook instance. The default value is 5 GB."
  type        = number
  default     = 5
  validation {
    condition     = var.volume_size >= 5 && var.volume_size <= 16384 && floor(var.volume_size) == var.volume_size
    error_message = "The volume size must be from 5 GB to 16384 GB (16 TB)."
  }
}

variable "subnet_id" {
  description = "The VPC subnet ID."
  type        = string
  validation {
    condition     = anytrue([can(regex("^subnet-([a-zA-Z0-9])+(.*)$", var.subnet_id))])
    error_message = "Subnet_id required and the allowed format of 'subnet_id' is subnet-#########."
  }
}

variable "security_groups" {
  description = "The associated security groups."
  type        = list(string)
  validation {
    condition     = alltrue([for i in var.security_groups : can(regex("^sg-\\w+", i))])
    error_message = "Error! Provide list of security_groups, value should be in form of 'sg-xxxxxxxx'."
  }
}

variable "additional_code_repositories" {
  description = "An array of up to three Git repositories to associate with the notebook instance. These can be either the names of Git repositories stored as resources in your account, or the URL of Git repositories in AWS CodeCommit or in any other Git repository. These repositories are cloned at the same level as the default repository of your notebook instance."
  type        = list(string)
  default     = []
}

variable "default_code_repository" {
  description = "The Git repository associated with the notebook instance as its default code repository. This can be either the name of a Git repository stored as a resource in your account, or the URL of a Git repository in AWS CodeCommit or in any other Git repository."
  type        = string
  default     = null
}

variable "direct_internet_access" {
  description = "Set to Disabled to disable internet access to notebook. Requires security_groups and subnet_id to be set. Supported values: Enabled (Default) or Disabled. If set to Disabled, the notebook instance will be able to access resources only in your VPC, and will not be able to connect to Amazon SageMaker training and endpoint services unless your configure a NAT Gateway in your VPC."
  type        = string
  default     = "Disabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.direct_internet_access)
    error_message = "Supported values: Enabled or Disabled."
  }
}

variable "kms_key_id" {
  description = "The AWS Key Management Service (AWS KMS) key that Amazon SageMaker uses to encrypt the model artifacts at rest using Amazon S3 server-side encryption."
  type        = string
}

variable "lifecycle_config_name" {
  description = "The name of a lifecycle configuration to associate with the notebook instance."
  type        = string
  default     = null
}

variable "root_access" {
  description = "Whether root access is Enabled or Disabled for users of the notebook instance. The default value is Enabled."
  type        = string
  default     = "Disabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.root_access)
    error_message = "Supported values: Enabled or Disabled."
  }
}

variable "metadata_service_version" {
  description = "Indicates the minimum IMDS version that the notebook instance supports. When passed 1 is passed. This means that both IMDSv1 and IMDSv2 are supported. Valid values are 1 and 2."
  type        = number
  default     = 1
}