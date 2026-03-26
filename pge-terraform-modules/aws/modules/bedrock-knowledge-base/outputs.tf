#  Filename    : aws/modules/bedrock-knowledge-base/outputs.tf
#  Date        : 11 Mar 2026
#  Author      : PGE
#  Description : Outputs for Bedrock Knowledge Base module

#########################################
# Knowledge Base Outputs
#########################################

output "knowledge_base_id" {
  description = "Unique identifier of the Bedrock Knowledge Base"
  value       = aws_bedrockagent_knowledge_base.kb.id
}

output "knowledge_base_arn" {
  description = "ARN of the Bedrock Knowledge Base"
  value       = aws_bedrockagent_knowledge_base.kb.arn
}

output "knowledge_base_name" {
  description = "Name of the Bedrock Knowledge Base"
  value       = aws_bedrockagent_knowledge_base.kb.name
}

output "knowledge_base_created_at" {
  description = "Timestamp when the Knowledge Base was created"
  value       = aws_bedrockagent_knowledge_base.kb.created_at
}

output "knowledge_base_updated_at" {
  description = "Timestamp when the Knowledge Base was last updated"
  value       = aws_bedrockagent_knowledge_base.kb.updated_at
}

#########################################
# IAM Role Outputs (passed through from variable)
#########################################

output "kb_role_arn" {
  description = "ARN of the IAM role used by the Knowledge Base"
  value       = var.kb_role_arn
}

#########################################
# Data Source Outputs
#########################################

output "data_source_arn" {
  description = "ARN of the Knowledge Base data source (for IAM policies and resource references)"
  value       = var.create_data_source ? "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:knowledge-base/${aws_bedrockagent_knowledge_base.kb.id}/data-source/${aws_bedrockagent_data_source.kb_data_source[0].data_source_id}" : null
}

output "data_source_id" {
  description = "Bedrock data source ID (for AWS CLI/SDK operations)"
  value       = var.create_data_source ? aws_bedrockagent_data_source.kb_data_source[0].data_source_id : null
}



#########################################
# Configuration Outputs
#########################################

output "embedding_model_arn" {
  description = "ARN of the embedding model used by the Knowledge Base"
  value       = "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.id}::foundation-model/${var.embedding_model_id}"
}

output "opensearch_collection_arn" {
  description = "ARN of the OpenSearch Serverless collection"
  value       = var.opensearch_collection_arn
}

output "s3_data_source_bucket_arn" {
  description = "ARN of the S3 bucket used as data source"
  value       = var.s3_data_source_bucket_arn
}

output "chunking_strategy" {
  description = "Chunking strategy used for document processing"
  value       = var.chunking_strategy
}
