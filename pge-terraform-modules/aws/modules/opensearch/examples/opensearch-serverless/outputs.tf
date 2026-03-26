#
# Filename    : aws/modules/opensearch/examples/opensearch-serverless/outputs.tf
# Date        : 09 Mar 2026
# Author      : PGE
# Description : Outputs for OpenSearch Serverless (AOSS) example

#########################################
# Collection Outputs
#########################################

output "collection_id" {
  description = "Unique identifier of the OpenSearch Serverless collection"
  value       = module.opensearch_serverless.collection_id
}

output "collection_arn" {
  description = "ARN of the OpenSearch Serverless collection"
  value       = module.opensearch_serverless.collection_arn
}

output "collection_name" {
  description = "Name of the OpenSearch Serverless collection"
  value       = module.opensearch_serverless.collection_name
}

output "collection_endpoint" {
  description = "Collection endpoint for OpenSearch API operations (use this for indexing and search)"
  value       = module.opensearch_serverless.collection_endpoint
}

output "dashboard_endpoint" {
  description = "Dashboard endpoint for OpenSearch Dashboards UI"
  value       = module.opensearch_serverless.dashboard_endpoint
}

output "collection_type" {
  description = "Type of the collection (SEARCH, TIMESERIES, or VECTORSEARCH)"
  value       = module.opensearch_serverless.collection_type
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = module.opensearch_serverless.kms_key_arn
}

#########################################
# Policy Outputs
#########################################

output "encryption_policy_name" {
  description = "Name of the encryption security policy"
  value       = module.opensearch_serverless.encryption_policy_name
}

output "network_policy_name" {
  description = "Name of the network security policy"
  value       = module.opensearch_serverless.network_policy_name
}

output "data_access_policy_name" {
  description = "Name of the data access policy"
  value       = module.opensearch_serverless.data_access_policy_name
}

#########################################
# VPC Endpoint Outputs
#########################################

output "vpc_endpoint_id" {
  description = "ID of the VPC endpoint (if created)"
  value       = var.create_vpce ? module.opensearch_vpce[0].vpc_endpoint_id : null
}

output "vpc_endpoint_dns_entries" {
  description = "DNS entries for the VPC endpoint (if created)"
  value       = var.create_vpce ? module.opensearch_vpce[0].vpc_endpoint_dns_entry : null
}

