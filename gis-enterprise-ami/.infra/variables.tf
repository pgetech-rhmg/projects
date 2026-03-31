###############################################################################
# Organization & Account
###############################################################################

variable "principal_orgid" {
  description = "AWS Organizations ID."
  type        = string
}

variable "aws_account_id" {
  description = "Target AWS account ID."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-west-2"
}


###############################################################################
# Application
###############################################################################

variable "app_name" {
  description = "Application name."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, qa, prod)."
  type        = string
}

variable "arcgis_version" {
  description = "ArcGIS Enterprise version."
  type        = string
  default     = "11.5"
}


###############################################################################
# Tagging & Compliance (PGE Standard)
###############################################################################

variable "appid" {
  description = "AMPS APP ID."
  type        = number
}

variable "notify" {
  description = "Notification email addresses (PGE LANID@pge.com)."
  type        = list(string)
}

variable "owner" {
  description = "Application owner LANIDs."
  type        = list(string)
}

variable "order" {
  description = "Cost center order number."
  type        = number
}

variable "dataclassification" {
  description = "Data classification level."
  type        = string
}

variable "compliance" {
  description = "Compliance requirements."
  type        = list(string)
}

variable "cris" {
  description = "Criticality rating."
  type        = string
}


###############################################################################
# Image Builder
###############################################################################

variable "components" {
  description = "List of AMI components to build (e.g., webadapter, portal, datastore, server)."
  type        = list(string)
}

variable "source_ami_id" {
  description = "Base AMI ID (RHEL golden image) for Image Builder recipes."
  type        = string
}

variable "instance_types" {
  description = "EC2 instance types for Image Builder."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "share_account_ids" {
  description = "AWS account IDs to share built AMIs with."
  type        = list(string)
  default     = []
}

variable "esri_assets_bucket" {
  description = "S3 bucket containing ESRI installation assets."
  type        = string
}

variable "ebs_volume_sizes" {
  description = "EBS volume sizes per component (GB). Defaults to 30 if not specified."
  type        = map(number)
  default     = {}
}


###############################################################################
# Networking (looked up from SSM in data.tf, but subnet override available)
###############################################################################

variable "subnet_index" {
  description = "Index of the private subnet to use (1, 2, or 3)."
  type        = number
  default     = 1
}
