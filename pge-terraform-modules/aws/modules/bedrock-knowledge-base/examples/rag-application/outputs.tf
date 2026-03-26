#  Filename    : aws/modules/bedrock-knowledge-base/examples/rag-application/outputs.tf
#  Date        : 19 Mar 2026
#  Author      : PGE
#  Description : Outputs for RAG application example

output "knowledge_base_id" {
  description = "ID of the Bedrock Knowledge Base"
  value       = module.bedrock_kb.knowledge_base_id
}

output "knowledge_base_arn" {
  description = "ARN of the Bedrock Knowledge Base"
  value       = module.bedrock_kb.knowledge_base_arn
}

output "data_source_id" {
  description = "Bedrock data source ID"
  value       = module.bedrock_kb.data_source_id
}

output "data_source_arn" {
  description = "ARN of the KB data source"
  value       = module.bedrock_kb.data_source_arn
}

output "kb_role_arn" {
  description = "ARN of the IAM role"
  value       = module.kb_role.arn
}

output "kb_role_name" {
  description = "Name of the IAM role"
  value       = module.kb_role.name
}

output "opensearch_collection_arn" {
  description = "ARN of the OpenSearch collection"
  value       = module.opensearch_serverless.collection_arn
}

output "opensearch_collection_endpoint" {
  description = "Endpoint of the OpenSearch collection"
  value       = module.opensearch_serverless.collection_endpoint
}

output "opensearch_dashboard_endpoint" {
  description = "OpenSearch Dashboards endpoint"
  value       = module.opensearch_serverless.dashboard_endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.kb_s3_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.kb_s3_bucket.arn
}
