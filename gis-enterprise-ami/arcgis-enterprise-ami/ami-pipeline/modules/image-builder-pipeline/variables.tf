variable "component_name" {
  description = "Name of the ArcGIS component (webadapter, portal, datastore, server)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "base_ami_name_filter" {
  description = "Name filter for base AMI"
  type        = string
}

variable "installer_yaml" {
  description = "Rendered YAML content for installer component"
  type        = string
}

variable "test_yaml" {
  description = "Rendered YAML content for test component"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for AMI encryption"
  type        = string
}

variable "share_account_ids" {
  description = "List of AWS account IDs to share AMIs with"
  type        = list(string)
}

variable "log_bucket" {
  description = "S3 bucket name for Image Builder logs"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for Image Builder instances"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for Image Builder instances"
  type        = string
}


variable "instance_types" {
  description = "List of instance types for image builder"
  type        = list(string)
}

variable "source_ami_id" {
  type = string
  description = "The source AMI to base all built AMIs from"
}

variable "tags" {
  description = "required tags"
  type        = map(string)
  default     = {}
}

variable "recipe_version" {
  type = string
  description = "Recipe Version"
  default = "1.0.0"
}

variable "component_version" {
  type = string
  description = "Component Version"
  default = "1.0.0"
}

variable "ebs_volume_size" {
  type = string
  description = "EBS volume size"
  default = "30"
}

variable "instance_profile_name" {
  type = string
  description = "The name of the IAM instance profile for Image Builder"
}
