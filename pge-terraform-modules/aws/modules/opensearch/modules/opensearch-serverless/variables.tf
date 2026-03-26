#  Filename    : aws/modules/opensearch/modules/opensearch-serverless/variables.tf
#  Date        : 09 Mar 2026
#  Author      : PGE
#  Description : Variables for OpenSearch Serverless Collection module

#########################################
# Collection Variables
#########################################

variable "collection_name" {
  description = "Name of the OpenSearch Serverless collection"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,21}$", var.collection_name))
    error_message = "Collection name must start with lowercase letter, contain only lowercase letters, numbers, and hyphens, and be between 3-22 characters (to allow room for policy name suffixes)."
  }
}

variable "collection_type" {
  description = "Type of collection. Valid values: SEARCH, TIMESERIES, VECTORSEARCH"
  type        = string
  default     = "VECTORSEARCH"
  validation {
    condition     = contains(["SEARCH", "TIMESERIES", "VECTORSEARCH"], var.collection_type)
    error_message = "Valid values for collection_type are SEARCH, TIMESERIES, or VECTORSEARCH."
  }
}

variable "collection_description" {
  description = "Description of the OpenSearch Serverless collection"
  type        = string
  default     = "OpenSearch Serverless collection managed by Terraform"
}

variable "standby_replicas" {
  description = "Whether to enable standby replicas. Valid values: ENABLED, DISABLED"
  type        = string
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.standby_replicas)
    error_message = "Valid values for standby_replicas are ENABLED or DISABLED."
  }
}

variable "collection_create_timeout" {
  description = "Timeout for creating the collection"
  type        = string
  default     = "20m"
}

variable "collection_delete_timeout" {
  description = "Timeout for deleting the collection"
  type        = string
  default     = "20m"
}

#########################################
# Encryption Policy Variables
#########################################

variable "create_encryption_policy" {
  description = "Whether to create an encryption policy for the collection"
  type        = bool
  default     = true
}

variable "encryption_policy_name" {
  description = "Name of the encryption policy. If null, defaults to <collection_name>-enc (must be 3-32 characters)"
  type        = string
  default     = null
  validation {
    condition     = var.encryption_policy_name == null || can(regex("^[a-z][a-z0-9-]{2,31}$", var.encryption_policy_name))
    error_message = "Encryption policy name must start with lowercase letter, contain only lowercase letters, numbers, and hyphens, and be between 3-32 characters."
  }
}

variable "encryption_policy_description" {
  description = "Description of the encryption policy"
  type        = string
  default     = "Encryption policy for OpenSearch Serverless collection"
}

variable "use_aws_owned_key" {
  description = "Whether to use AWS owned key for encryption. Set to true for AWS owned key, false for customer managed KMS key. PGE standard is to use customer-managed KMS keys (false)"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "ARN of the customer-managed KMS key for encryption. Required when use_aws_owned_key is false (PGE standard)"
  type        = string
  default     = null
  validation {
    condition     = var.kms_key_arn == null || can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/[a-f0-9-]+$", var.kms_key_arn))
    error_message = "kms_key_arn must be a valid KMS key ARN starting with 'arn:aws:kms:' or null."
  }
}

#########################################
# Network Policy Variables
#########################################

variable "create_network_policy" {
  description = "Whether to create a network policy for the collection"
  type        = bool
  default     = true
}

variable "network_policy_name" {
  description = "Name of the network policy. If null, defaults to <collection_name>-net (must be 3-32 characters)"
  type        = string
  default     = null
  validation {
    condition     = var.network_policy_name == null || can(regex("^[a-z][a-z0-9-]{2,31}$", var.network_policy_name))
    error_message = "Network policy name must start with lowercase letter, contain only lowercase letters, numbers, and hyphens, and be between 3-32 characters."
  }
}

variable "network_policy_description" {
  description = "Description of the network policy"
  type        = string
  default     = "Network policy for OpenSearch Serverless collection"
}

variable "allow_public_access" {
  description = "Whether to allow public access to the collection"
  type        = bool
  default     = false
}

variable "vpce_ids" {
  description = "List of VPC endpoint IDs that can access the collection"
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
# Data Access Policy Variables
#########################################

variable "create_data_access_policy" {
  description = "Whether to create a data access policy for the collection"
  type        = bool
  default     = true
}

variable "data_access_policy_name" {
  description = "Name of the data access policy. If null, defaults to <collection_name>-access (must be 3-32 characters)"
  type        = string
  default     = null
  validation {
    condition     = var.data_access_policy_name == null || can(regex("^[a-z][a-z0-9-]{2,31}$", var.data_access_policy_name))
    error_message = "Data access policy name must start with lowercase letter, contain only lowercase letters, numbers, and hyphens, and be between 3-32 characters."
  }
}

variable "data_access_policy_description" {
  description = "Description of the data access policy"
  type        = string
  default     = "Data access policy for OpenSearch Serverless collection"
}

variable "data_access_permissions" {
  description = "List of permissions for collection-level access. Valid values: aoss:CreateCollectionItems, aoss:DeleteCollectionItems, aoss:UpdateCollectionItems, aoss:DescribeCollectionItems"
  type        = list(string)
  default = [
    "aoss:CreateCollectionItems",
    "aoss:DeleteCollectionItems",
    "aoss:UpdateCollectionItems",
    "aoss:DescribeCollectionItems"
  ]
  validation {
    condition = alltrue([
      for perm in var.data_access_permissions :
      contains([
        "aoss:CreateCollectionItems",
        "aoss:DeleteCollectionItems",
        "aoss:UpdateCollectionItems",
        "aoss:DescribeCollectionItems"
      ], perm)
    ])
    error_message = "All permissions must be valid collection-level permissions: aoss:CreateCollectionItems, aoss:DeleteCollectionItems, aoss:UpdateCollectionItems, aoss:DescribeCollectionItems."
  }
}

variable "index_permissions" {
  description = "List of permissions for index-level access. Valid values: aoss:CreateIndex, aoss:DeleteIndex, aoss:UpdateIndex, aoss:DescribeIndex, aoss:ReadDocument, aoss:WriteDocument"
  type        = list(string)
  default = [
    "aoss:CreateIndex",
    "aoss:DeleteIndex",
    "aoss:UpdateIndex",
    "aoss:DescribeIndex",
    "aoss:ReadDocument",
    "aoss:WriteDocument"
  ]
  validation {
    condition = alltrue([
      for perm in var.index_permissions :
      contains([
        "aoss:CreateIndex",
        "aoss:DeleteIndex",
        "aoss:UpdateIndex",
        "aoss:DescribeIndex",
        "aoss:ReadDocument",
        "aoss:WriteDocument"
      ], perm)
    ])
    error_message = "All permissions must be valid index-level permissions: aoss:CreateIndex, aoss:DeleteIndex, aoss:UpdateIndex, aoss:DescribeIndex, aoss:ReadDocument, aoss:WriteDocument."
  }
}

variable "data_access_principals" {
  description = "List of IAM principal ARNs that have access to the collection and indexes (used when use_multi_tier_access is false)"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for arn in var.data_access_principals : can(regex("^arn:aws:iam::[0-9]{12}:(user|role)/[a-zA-Z0-9+=,.@_-]+(?:/[a-zA-Z0-9+=,.@_-]+)*$", arn)) || can(regex("^arn:aws:sts::[0-9]{12}:assumed-role/[a-zA-Z0-9+=,.@_-]+/[a-zA-Z0-9+=,.@_-]+$", arn))
    ])
    error_message = "All principals must be valid IAM user, role, or assumed role ARNs."
  }
}

#########################################
# Multi-Tier Access Control (Amplify Security Pattern)
#########################################

variable "use_multi_tier_access" {
  description = "Enable 3-tier access control matching Amplify security pattern (privileged, public, specific indexes)"
  type        = bool
  default     = false
}

variable "privileged_principals" {
  description = "IAM principals with wildcard index access (admins, automation, Bedrock roles). Used when use_multi_tier_access is true."
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for arn in var.privileged_principals : can(regex("^arn:aws:iam::[0-9]{12}:(user|role)/[a-zA-Z0-9+=,.@_-]+(?:/[a-zA-Z0-9+=,.@_-]+)*$", arn)) || can(regex("^arn:aws:sts::[0-9]{12}:assumed-role/[a-zA-Z0-9+=,.@_-]+/[a-zA-Z0-9+=,.@_-]+$", arn))
    ])
    error_message = "All privileged principals must be valid IAM user, role, or assumed role ARNs."
  }
}

variable "public_access_principals" {
  description = "IAM principals with limited access to specific named indexes only (SSO users, app roles). Used when use_multi_tier_access is true."
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for arn in var.public_access_principals : can(regex("^arn:aws:iam::[0-9]{12}:(user|role)/[a-zA-Z0-9+=,.@_-]+(?:/[a-zA-Z0-9+=,.@_-]+)*$", arn)) || can(regex("^arn:aws:sts::[0-9]{12}:assumed-role/[a-zA-Z0-9+=,.@_-]+/[a-zA-Z0-9+=,.@_-]+$", arn))
    ])
    error_message = "All public principals must be valid IAM user, role, or assumed role ARNs."
  }
}

variable "public_index_names" {
  description = "List of specific index names that public_access_principals can access. Used when use_multi_tier_access is true. Example: ['public-kb-index', 'general-kb-index']"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for name in var.public_index_names : can(regex("^[a-z][a-z0-9-]{0,254}$", name))
    ])
    error_message = "Index names must start with lowercase letter, contain only lowercase letters, numbers, and hyphens, and be up to 255 characters."
  }
}

variable "public_index_permissions" {
  description = "Permissions granted to public_access_principals for specific named indexes. Used when use_multi_tier_access is true."
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
# Common Variables
#########################################

variable "tags" {
  description = "Map of tags to assign to resources. Must include PGE required tags: AppID, Environment, DataClassification, CRIS, Notify, Owner, Compliance, Order"
  type        = map(any)
  default     = {}
}
