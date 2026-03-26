#  Filename    : aws/modules/opensearch/modules/opensearch-serverless/outputs.tf
#  Date        : 09 Mar 2026
#  Author      : PGE
#  Description : Outputs for OpenSearch Serverless Collection module

#########################################
# Collection Outputs
#########################################

output "collection_id" {
  description = "Unique identifier of the OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.collection.id
}

output "collection_arn" {
  description = "ARN of the OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.collection.arn
}

output "collection_name" {
  description = "Name of the OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.collection.name
}

output "collection_endpoint" {
  description = "Collection endpoint for OpenSearch operations"
  value       = aws_opensearchserverless_collection.collection.collection_endpoint
}

output "dashboard_endpoint" {
  description = "Dashboard endpoint for OpenSearch Dashboards"
  value       = aws_opensearchserverless_collection.collection.dashboard_endpoint
}

output "collection_type" {
  description = "Type of the collection"
  value       = aws_opensearchserverless_collection.collection.type
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt the collection"
  value       = aws_opensearchserverless_collection.collection.kms_key_arn
}

output "collection_all" {
  description = "Map of all collection attributes"
  value       = aws_opensearchserverless_collection.collection
  sensitive   = true
}

#########################################
# Encryption Policy Outputs
#########################################

output "encryption_policy_name" {
  description = "Name of the encryption policy"
  value       = var.create_encryption_policy ? aws_opensearchserverless_security_policy.encryption[0].name : null
}

output "encryption_policy_version" {
  description = "Version of the encryption policy"
  value       = var.create_encryption_policy ? aws_opensearchserverless_security_policy.encryption[0].policy_version : null
}

output "encryption_policy" {
  description = "JSON policy document of the encryption policy"
  value       = var.create_encryption_policy ? aws_opensearchserverless_security_policy.encryption[0].policy : null
}

#########################################
# Network Policy Outputs
#########################################

output "network_policy_name" {
  description = "Name of the network policy"
  value       = var.create_network_policy ? aws_opensearchserverless_security_policy.network[0].name : null
}

output "network_policy_version" {
  description = "Version of the network policy"
  value       = var.create_network_policy ? aws_opensearchserverless_security_policy.network[0].policy_version : null
}

output "network_policy" {
  description = "JSON policy document of the network policy"
  value       = var.create_network_policy ? aws_opensearchserverless_security_policy.network[0].policy : null
}

#########################################
# Data Access Policy Outputs
#########################################

output "data_access_policy_name" {
  description = "Name of the data access policy"
  value       = var.create_data_access_policy ? aws_opensearchserverless_access_policy.data_access[0].name : null
}

output "data_access_policy_version" {
  description = "Version of the data access policy"
  value       = var.create_data_access_policy ? aws_opensearchserverless_access_policy.data_access[0].policy_version : null
}

output "data_access_policy" {
  description = "JSON policy document of the data access policy"
  value       = var.create_data_access_policy ? aws_opensearchserverless_access_policy.data_access[0].policy : null
}

output "access_mode" {
  description = "Access control mode: single-tier or multi-tier"
  value       = var.use_multi_tier_access ? "multi-tier" : "single-tier"
}

output "privileged_principals" {
  description = "List of privileged principals with wildcard index access (multi-tier mode only)"
  value       = var.use_multi_tier_access ? var.privileged_principals : null
}

output "public_access_principals" {
  description = "List of public principals with limited named index access (multi-tier mode only)"
  value       = var.use_multi_tier_access ? var.public_access_principals : null
}

output "public_index_names" {
  description = "List of index names accessible to public principals (multi-tier mode only)"
  value       = var.use_multi_tier_access ? var.public_index_names : null
}
