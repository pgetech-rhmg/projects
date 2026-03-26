<!-- BEGIN_TF_DOCS -->
# AWS Bedrock Knowledge Base Module
Terraform module for deploying Amazon Bedrock Knowledge Base

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.37.0 |

## Usage

Usage information can be found in `modules/examples/*`

`cd pge-terraform-modules/modules/examples/*`

`terraform init`

`terraform validate`

`terraform plan`

`terraform apply`

Run `terraform destroy` when you don't need these resources.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_bedrockagent_data_source.kb_data_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_data_source) | resource |
| [aws_bedrockagent_knowledge_base.kb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_knowledge_base) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chunk_max_tokens"></a> [chunk\_max\_tokens](#input\_chunk\_max\_tokens) | Maximum number of tokens per chunk for FIXED\_SIZE strategy | `number` | `300` | no |
| <a name="input_chunk_overlap_percentage"></a> [chunk\_overlap\_percentage](#input\_chunk\_overlap\_percentage) | Percentage of overlap between chunks for FIXED\_SIZE strategy | `number` | `20` | no |
| <a name="input_chunking_strategy"></a> [chunking\_strategy](#input\_chunking\_strategy) | Chunking strategy for document processing. Valid values: FIXED\_SIZE, HIERARCHICAL, SEMANTIC, NONE | `string` | `"FIXED_SIZE"` | no |
| <a name="input_create_data_source"></a> [create\_data\_source](#input\_create\_data\_source) | Whether to create a data source for the knowledge base | `bool` | `true` | no |
| <a name="input_data_source_description"></a> [data\_source\_description](#input\_data\_source\_description) | Description of the data source | `string` | `"S3 data source for Bedrock Knowledge Base"` | no |
| <a name="input_data_source_name"></a> [data\_source\_name](#input\_data\_source\_name) | Name of the data source | `string` | `"s3-data-source"` | no |
| <a name="input_embedding_model_id"></a> [embedding\_model\_id](#input\_embedding\_model\_id) | ID of the Bedrock embedding model to use. Common values: amazon.titan-embed-text-v1, amazon.titan-embed-text-v2:0, cohere.embed-english-v3, cohere.embed-multilingual-v3 | `string` | `"amazon.titan-embed-text-v2:0"` | no |
| <a name="input_hierarchical_child_max_tokens"></a> [hierarchical\_child\_max\_tokens](#input\_hierarchical\_child\_max\_tokens) | Maximum tokens for child chunks in HIERARCHICAL strategy | `number` | `300` | no |
| <a name="input_hierarchical_overlap_tokens"></a> [hierarchical\_overlap\_tokens](#input\_hierarchical\_overlap\_tokens) | Number of overlapping tokens between hierarchical chunks | `number` | `60` | no |
| <a name="input_hierarchical_parent_max_tokens"></a> [hierarchical\_parent\_max\_tokens](#input\_hierarchical\_parent\_max\_tokens) | Maximum tokens for parent chunks in HIERARCHICAL strategy | `number` | `1500` | no |
| <a name="input_kb_role_arn"></a> [kb\_role\_arn](#input\_kb\_role\_arn) | ARN of the IAM role for the Knowledge Base to assume. Must have permissions for S3, OpenSearch Serverless, Bedrock model invocation, and optionally KMS. | `string` | n/a | yes |
| <a name="input_knowledge_base_description"></a> [knowledge\_base\_description](#input\_knowledge\_base\_description) | Description of the Bedrock Knowledge Base | `string` | `"Bedrock Knowledge Base for RAG applications"` | no |
| <a name="input_knowledge_base_name"></a> [knowledge\_base\_name](#input\_knowledge\_base\_name) | Name of the Bedrock Knowledge Base | `string` | n/a | yes |
| <a name="input_metadata_field_name"></a> [metadata\_field\_name](#input\_metadata\_field\_name) | Name of the metadata field in OpenSearch index | `string` | `"AMAZON_BEDROCK_METADATA"` | no |
| <a name="input_opensearch_collection_arn"></a> [opensearch\_collection\_arn](#input\_opensearch\_collection\_arn) | ARN of the OpenSearch Serverless collection | `string` | n/a | yes |
| <a name="input_opensearch_vector_index_name"></a> [opensearch\_vector\_index\_name](#input\_opensearch\_vector\_index\_name) | Name of the vector index in the OpenSearch Serverless collection | `string` | n/a | yes |
| <a name="input_s3_data_source_bucket_arn"></a> [s3\_data\_source\_bucket\_arn](#input\_s3\_data\_source\_bucket\_arn) | ARN of the S3 bucket containing knowledge base documents | `string` | n/a | yes |
| <a name="input_s3_inclusion_prefixes"></a> [s3\_inclusion\_prefixes](#input\_s3\_inclusion\_prefixes) | List of S3 prefixes to include for data ingestion. Leave empty to include all objects in the bucket | `list(string)` | `[]` | no |
| <a name="input_semantic_breakpoint_threshold"></a> [semantic\_breakpoint\_threshold](#input\_semantic\_breakpoint\_threshold) | Breakpoint percentile threshold for semantic chunking (0-100) | `number` | `95` | no |
| <a name="input_semantic_buffer_size"></a> [semantic\_buffer\_size](#input\_semantic\_buffer\_size) | Buffer size for semantic chunking | `number` | `1` | no |
| <a name="input_semantic_max_tokens"></a> [semantic\_max\_tokens](#input\_semantic\_max\_tokens) | Maximum tokens per semantic chunk | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of mandatory PGE tags to apply to all resources. Must include: AppID, Environment, DataClassification, CRIS, Notify, Owner, Compliance, Order | `map(string)` | n/a | yes |
| <a name="input_text_field_name"></a> [text\_field\_name](#input\_text\_field\_name) | Name of the text field in OpenSearch index | `string` | `"AMAZON_BEDROCK_TEXT_CHUNK"` | no |
| <a name="input_vector_field_name"></a> [vector\_field\_name](#input\_vector\_field\_name) | Name of the vector field in OpenSearch index | `string` | `"AMAZON_BEDROCK_VECTOR"` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_chunking_strategy"></a> [chunking\_strategy](#output\_chunking\_strategy) | Chunking strategy used for document processing |
| <a name="output_data_source_arn"></a> [data\_source\_arn](#output\_data\_source\_arn) | ARN of the Knowledge Base data source (for IAM policies and resource references) |
| <a name="output_data_source_id"></a> [data\_source\_id](#output\_data\_source\_id) | Bedrock data source ID (for AWS CLI/SDK operations) |
| <a name="output_embedding_model_arn"></a> [embedding\_model\_arn](#output\_embedding\_model\_arn) | ARN of the embedding model used by the Knowledge Base |
| <a name="output_kb_role_arn"></a> [kb\_role\_arn](#output\_kb\_role\_arn) | ARN of the IAM role used by the Knowledge Base |
| <a name="output_knowledge_base_arn"></a> [knowledge\_base\_arn](#output\_knowledge\_base\_arn) | ARN of the Bedrock Knowledge Base |
| <a name="output_knowledge_base_created_at"></a> [knowledge\_base\_created\_at](#output\_knowledge\_base\_created\_at) | Timestamp when the Knowledge Base was created |
| <a name="output_knowledge_base_id"></a> [knowledge\_base\_id](#output\_knowledge\_base\_id) | Unique identifier of the Bedrock Knowledge Base |
| <a name="output_knowledge_base_name"></a> [knowledge\_base\_name](#output\_knowledge\_base\_name) | Name of the Bedrock Knowledge Base |
| <a name="output_knowledge_base_updated_at"></a> [knowledge\_base\_updated\_at](#output\_knowledge\_base\_updated\_at) | Timestamp when the Knowledge Base was last updated |
| <a name="output_opensearch_collection_arn"></a> [opensearch\_collection\_arn](#output\_opensearch\_collection\_arn) | ARN of the OpenSearch Serverless collection |
| <a name="output_s3_data_source_bucket_arn"></a> [s3\_data\_source\_bucket\_arn](#output\_s3\_data\_source\_bucket\_arn) | ARN of the S3 bucket used as data source |

<!-- END_TF_DOCS -->