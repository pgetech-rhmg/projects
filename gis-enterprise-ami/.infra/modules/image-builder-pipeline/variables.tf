variable "component_name" {
  description = "Component name (e.g., webadapter, portal, datastore, server)."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "source_ami_id" {
  description = "Base AMI ID for the recipe."
  type        = string
}

variable "instance_types" {
  description = "EC2 instance types for Image Builder."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "instance_profile_name" {
  description = "IAM instance profile for Image Builder instances."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for AMI encryption."
  type        = string
}

variable "share_account_ids" {
  description = "AWS account IDs to share the AMI with."
  type        = list(string)
  default     = []
}

variable "log_bucket" {
  description = "S3 bucket for Image Builder logs."
  type        = string
}

variable "security_group_id" {
  description = "Security group for Image Builder instances."
  type        = string
}

variable "subnet_id" {
  description = "Subnet for Image Builder instances."
  type        = string
}

variable "esri_assets_bucket" {
  description = "S3 bucket containing ESRI installation assets."
  type        = string
}

variable "ebs_volume_size" {
  description = "EBS volume size in GB."
  type        = string
  default     = "30"
}

variable "recipe_version" {
  description = "Image recipe version."
  type        = string
  default     = "1.0.0"
}

variable "component_version" {
  description = "Image Builder component version."
  type        = string
  default     = "1.0.0"
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
