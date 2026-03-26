##  Filename    : aws/modules/opensearch/examples/opensearch-serverless/variables.tf
#  Date        : 09 Mar 2026 Filename    : aws/modules/opensearch/examples/aoss/variables.tf
# Date        : 09 Mar 2026
# Author      : PGE
# Description : Variables for OpenSearch Serverless (AOSS) example

#########################################
# General Configuration
#########################################

variable "account_num" {
  description = "AWS account number"
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_num))
    error_message = "account_num must be a 12-digit AWS account number."
  }
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-west-2"
}

variable "app_prefix" {
  description = "Application prefix for resource naming (3-10 lowercase alphanumeric characters)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,9}$", var.app_prefix))
    error_message = "app_prefix must be 3-10 characters, start with lowercase letter, contain only lowercase letters and numbers."
  }
}

#########################################
# PGE Required Tags
#########################################

variable "AppID" {
  description = "PGE Application ID (format: APP-#####)"
  type        = string
  validation {
    condition     = can(regex("^APP-[0-9]{4,6}$", var.AppID))
    error_message = "AppID must be in format APP-#### where #### is 4-6 digits."
  }
}

variable "Environment" {
  description = "Environment name (Dev, Test, QA, or Prod)"
  type        = string
  validation {
    condition     = contains(["Dev", "Test", "QA", "Prod"], var.Environment)
    error_message = "Environment must be one of: Dev, Test, QA, Prod."
  }
}

variable "DataClassification" {
  description = "Data classification level"
  type        = string
  validation {
    condition = contains([
      "Public",
      "Internal",
      "Confidential",
      "Restricted",
      "Privileged",
      "Confidential-BCSI",
      "Restricted-BCSI"
    ], var.DataClassification)
    error_message = "DataClassification must be one of: Public, Internal, Confidential, Restricted, Privileged, Confidential-BCSI, Restricted-BCSI."
  }
}

variable "CRIS" {
  description = "Cyber Risk Impact Score (High, Medium, or Low)"
  type        = string
  validation {
    condition     = contains(["High", "Medium", "Low"], var.CRIS)
    error_message = "CRIS must be one of: High, Medium, Low."
  }
}

variable "Notify" {
  description = "List of email addresses for notifications"
  type        = list(string)
  validation {
    condition = alltrue([
      for email in var.Notify : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All Notify values must be valid email addresses."
  }
}

variable "Owner" {
  description = "List of three LANIDs responsible for the resources"
  type        = list(string)
  validation {
    condition     = length(var.Owner) == 3
    error_message = "Owner must contain exactly three LANIDs."
  }
  validation {
    condition = alltrue([
      for lanid in var.Owner : can(regex("^[A-Z0-9]{4,8}$", lanid))
    ])
    error_message = "All Owner LANIDs must be 4-8 uppercase alphanumeric characters."
  }
}

variable "Compliance" {
  description = "List of compliance requirements (SOX, HIPAA, CCPA, BCSI, None)"
  type        = list(string)
  validation {
    condition = alltrue([
      for comp in var.Compliance : contains(["SOX", "HIPAA", "CCPA", "BCSI", "None"], comp)
    ])
    error_message = "Compliance values must be one of: SOX, HIPAA, CCPA, BCSI, None."
  }
}

variable "Order" {
  description = "PGE Order number (7-9 digits)"
  type        = string
  validation {
    condition     = can(regex("^[0-9]{7,9}$", var.Order))
    error_message = "Order must be 7-9 digits."
  }
  validation {
    condition     = tonumber(var.Order) >= 1000000 && tonumber(var.Order) <= 999999999
    error_message = "Order must be between 1000000 and 999999999."
  }
}

#########################################
# KMS Configuration
#########################################

variable "aws_role" {
  description = "AWS IAM role for KMS key administration"
  type        = string
  default     = "TerraformAdmin"
}

variable "kms_role" {
  description = "KMS key alias role suffix"
  type        = string
  default     = "aoss"
}

#########################################
# OpenSearch Serverless Configuration
#########################################

variable "collection_type" {
  description = "Type of OpenSearch Serverless collection (SEARCH, TIMESERIES, VECTORSEARCH)"
  type        = string
  default     = "VECTORSEARCH"
  validation {
    condition     = contains(["SEARCH", "TIMESERIES", "VECTORSEARCH"], var.collection_type)
    error_message = "collection_type must be one of: SEARCH, TIMESERIES, VECTORSEARCH."
  }
}

variable "enable_standby_replicas" {
  description = "Enable standby replicas for high availability"
  type        = bool
  default     = true
}

#########################################
# Network Configuration
#########################################

variable "create_vpce" {
  description = "Whether to create a VPC endpoint for private access"
  type        = bool
  default     = false
}

################################################################################
# Network Configuration - SSM Parameters (PGE Standard)
################################################################################

variable "use_ssm_for_network" {
  description = "Use SSM Parameter Store to retrieve VPC, subnet, and security group information (PGE standard)"
  type        = bool
  default     = true
}

variable "vpc_id_ssm_parameter" {
  description = "SSM parameter name containing VPC ID (used when use_ssm_for_network is true)"
  type        = string
  default     = "/network/vpc/id"
}

variable "subnet_ids_ssm_parameter" {
  description = "SSM parameter name containing comma-separated subnet IDs (used when use_ssm_for_network is true)"
  type        = string
  default     = "/network/subnets/private"
}

variable "security_group_ids_ssm_parameter" {
  description = "SSM parameter name containing comma-separated security group IDs (used when use_ssm_for_network is true)"
  type        = string
  default     = "/network/security-groups/opensearch"
}

################################################################################
# Network Configuration - Direct Values (Alternative to SSM)
################################################################################

variable "vpc_id" {
  description = "VPC ID for VPC endpoint (required if create_vpce is true and use_ssm_for_network is false)"
  type        = string
  default     = null
  validation {
    condition     = var.vpc_id == null || can(regex("^vpc-[a-f0-9]{8,}$", var.vpc_id))
    error_message = "vpc_id must be a valid VPC ID starting with 'vpc-' or null."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for VPC endpoint (required if create_vpce is true and use_ssm_for_network is false)"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for subnet in var.subnet_ids : can(regex("^subnet-[a-f0-9]{8,}$", subnet))
    ])
    error_message = "All subnet_ids must be valid subnet IDs starting with 'subnet-'."
  }
}

variable "security_group_ids" {
  description = "List of security group IDs for VPC endpoint (used when use_ssm_for_network is false)"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for sg in var.security_group_ids : can(regex("^sg-[a-f0-9]{8,}$", sg))
    ])
    error_message = "All security_group_ids must be valid security group IDs starting with 'sg-'."
  }
}

variable "allow_public_access" {
  description = "Allow public internet access to the collection (not recommended for production)"
  type        = bool
  default     = false
}

variable "vpce_ids" {
  description = "List of existing VPC endpoint IDs to allow access (alternative to create_vpce)"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for vpce in var.vpce_ids : can(regex("^vpce-[a-f0-9]{8,}$", vpce))
    ])
    error_message = "All vpce_ids must be valid VPC endpoint IDs starting with 'vpce-'."
  }
}

#########################################
# Access Control
#########################################

variable "data_access_principals" {
  description = "List of IAM principal ARNs to grant access to the collection (defaults to current user if empty)"
  type        = list(string)
  default     = []
  validation {
    condition = length(var.data_access_principals) == 0 || alltrue([
      for arn in var.data_access_principals : can(regex("^arn:aws:iam::[0-9]{12}:(user|role)/[a-zA-Z0-9+=,.@_-]+(?:/[a-zA-Z0-9+=,.@_-]+)*$", arn)) || can(regex("^arn:aws:sts::[0-9]{12}:assumed-role/[a-zA-Z0-9+=,.@_-]+/[a-zA-Z0-9+=,.@_-]+$", arn))
    ])
    error_message = "All principals must be valid IAM user, role, or assumed role ARNs."
  }
}

variable "data_access_permissions" {
  description = "List of collection-level permissions to grant"
  type        = list(string)
  default = [
    "aoss:CreateCollectionItems",
    "aoss:DeleteCollectionItems",
    "aoss:UpdateCollectionItems",
    "aoss:DescribeCollectionItems"
  ]
}

variable "index_permissions" {
  description = "List of index-level permissions to grant"
  type        = list(string)
  default = [
    "aoss:CreateIndex",
    "aoss:DeleteIndex",
    "aoss:UpdateIndex",
    "aoss:DescribeIndex",
    "aoss:ReadDocument",
    "aoss:WriteDocument"
  ]
}

#########################################
# Optional Configuration
#########################################

variable "optional_tags" {
  description = "Optional tags to add to resources (in addition to required PGE tags)"
  type        = map(string)
  default     = {}
}
