<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_opensearch"></a> [opensearch](#requirement\_opensearch) | >= 2.3.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_opensearch"></a> [opensearch](#provider\_opensearch) | >= 2.3.1 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9.0 |

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
| <a name="module_bedrock_kb"></a> [bedrock\_kb](#module\_bedrock\_kb) | ../.. | n/a |
| <a name="module_kb_bedrock_policy"></a> [kb\_bedrock\_policy](#module\_kb\_bedrock\_policy) | app.terraform.io/pgetech/iam/aws//modules/iam_policy | 0.1.1 |
| <a name="module_kb_opensearch_policy"></a> [kb\_opensearch\_policy](#module\_kb\_opensearch\_policy) | app.terraform.io/pgetech/iam/aws//modules/iam_policy | 0.1.1 |
| <a name="module_kb_role"></a> [kb\_role](#module\_kb\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_kb_s3_bucket"></a> [kb\_s3\_bucket](#module\_kb\_s3\_bucket) | app.terraform.io/pgetech/s3/aws | 0.1.2 |
| <a name="module_kb_s3_policy"></a> [kb\_s3\_policy](#module\_kb\_s3\_policy) | app.terraform.io/pgetech/iam/aws//modules/iam_policy | 0.1.1 |
| <a name="module_opensearch_serverless"></a> [opensearch\_serverless](#module\_opensearch\_serverless) | app.terraform.io/pgetech/opensearch/aws//modules/opensearch-serverless | 0.1.3 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role_policy_attachment.kb_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [opensearch_index.bedrock_kb](https://registry.terraform.io/providers/opensearch-project/opensearch/latest/docs/resources/index) | resource |
| [time_sleep.wait_for_aoss](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kb_bedrock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kb_opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kb_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_allow_public_access"></a> [allow\_public\_access](#input\_allow\_public\_access) | Allow public access to OpenSearch Serverless collection | `bool` | `true` | no |
| <a name="input_app_prefix"></a> [app\_prefix](#input\_app\_prefix) | Prefix for resource naming | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_chunk_max_tokens"></a> [chunk\_max\_tokens](#input\_chunk\_max\_tokens) | Maximum number of tokens per chunk | `number` | `300` | no |
| <a name="input_chunk_overlap_percentage"></a> [chunk\_overlap\_percentage](#input\_chunk\_overlap\_percentage) | Percentage overlap between chunks | `number` | `20` | no |
| <a name="input_chunking_strategy"></a> [chunking\_strategy](#input\_chunking\_strategy) | Chunking strategy (FIXED\_SIZE, HIERARCHICAL, SEMANTIC, NONE) | `string` | `"FIXED_SIZE"` | no |
| <a name="input_collection_type"></a> [collection\_type](#input\_collection\_type) | Type of OpenSearch Serverless collection | `string` | `"VECTORSEARCH"` | no |
| <a name="input_create_data_source"></a> [create\_data\_source](#input\_create\_data\_source) | Whether to create a data source for the knowledge base | `bool` | `true` | no |
| <a name="input_data_access_permissions"></a> [data\_access\_permissions](#input\_data\_access\_permissions) | Data access permissions for OpenSearch collection | `list(string)` | <pre>[<br/>  "aoss:DescribeCollectionItems",<br/>  "aoss:CreateCollectionItems"<br/>]</pre> | no |
| <a name="input_data_access_principals"></a> [data\_access\_principals](#input\_data\_access\_principals) | Additional IAM principals to grant data access (beyond Terraform user, CloudAdmin, and KB role) | `list(string)` | `[]` | no |
| <a name="input_embedding_model_id"></a> [embedding\_model\_id](#input\_embedding\_model\_id) | ID of the Bedrock embedding model to use | `string` | `"amazon.titan-embed-text-v2:0"` | no |
| <a name="input_enable_standby_replicas"></a> [enable\_standby\_replicas](#input\_enable\_standby\_replicas) | Enable standby replicas for OpenSearch Serverless collection (increases cost) | `bool` | `false` | no |
| <a name="input_index_knn_algo_param_ef_search"></a> [index\_knn\_algo\_param\_ef\_search](#input\_index\_knn\_algo\_param\_ef\_search) | ef\_search parameter for KNN algorithm | `string` | `"512"` | no |
| <a name="input_index_number_of_replicas"></a> [index\_number\_of\_replicas](#input\_index\_number\_of\_replicas) | Number of replicas for the OpenSearch index | `string` | `"1"` | no |
| <a name="input_index_number_of_shards"></a> [index\_number\_of\_shards](#input\_index\_number\_of\_shards) | Number of shards for the OpenSearch index | `string` | `"2"` | no |
| <a name="input_index_permissions"></a> [index\_permissions](#input\_index\_permissions) | Index permissions for OpenSearch collection | `list(string)` | <pre>[<br/>  "aoss:UpdateIndex",<br/>  "aoss:DescribeIndex",<br/>  "aoss:ReadDocument",<br/>  "aoss:WriteDocument",<br/>  "aoss:CreateIndex"<br/>]</pre> | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key ARN for encryption (if use\_aws\_owned\_key is false) | `string` | `null` | no |
| <a name="input_knowledge_base_description"></a> [knowledge\_base\_description](#input\_knowledge\_base\_description) | Description of the Bedrock Knowledge Base | `string` | `"Bedrock Knowledge Base for RAG applications with OpenSearch Serverless"` | no |
| <a name="input_metadata_field_name"></a> [metadata\_field\_name](#input\_metadata\_field\_name) | Name of the metadata field in OpenSearch | `string` | `"AMAZON_BEDROCK_METADATA"` | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_s3_acl"></a> [s3\_acl](#input\_s3\_acl) | S3 bucket ACL | `string` | `"private"` | no |
| <a name="input_s3_block_public_acls"></a> [s3\_block\_public\_acls](#input\_s3\_block\_public\_acls) | Block public ACLs for S3 bucket | `bool` | `true` | no |
| <a name="input_s3_block_public_policy"></a> [s3\_block\_public\_policy](#input\_s3\_block\_public\_policy) | Block public bucket policies for S3 bucket | `bool` | `true` | no |
| <a name="input_s3_force_destroy"></a> [s3\_force\_destroy](#input\_s3\_force\_destroy) | Allow Terraform to destroy bucket with objects | `bool` | `true` | no |
| <a name="input_s3_ignore_public_acls"></a> [s3\_ignore\_public\_acls](#input\_s3\_ignore\_public\_acls) | Ignore public ACLs for S3 bucket | `bool` | `true` | no |
| <a name="input_s3_inclusion_prefixes"></a> [s3\_inclusion\_prefixes](#input\_s3\_inclusion\_prefixes) | S3 prefixes to include for data ingestion (empty list = all objects) | `list(string)` | `[]` | no |
| <a name="input_s3_restrict_public_buckets"></a> [s3\_restrict\_public\_buckets](#input\_s3\_restrict\_public\_buckets) | Restrict public bucket policies for S3 bucket | `bool` | `true` | no |
| <a name="input_s3_versioning"></a> [s3\_versioning](#input\_s3\_versioning) | Enable S3 bucket versioning | `string` | `"Enabled"` | no |
| <a name="input_text_field_name"></a> [text\_field\_name](#input\_text\_field\_name) | Name of the text field in OpenSearch | `string` | `"AMAZON_BEDROCK_TEXT_CHUNK"` | no |
| <a name="input_use_aws_owned_key"></a> [use\_aws\_owned\_key](#input\_use\_aws\_owned\_key) | Use AWS-owned key for encryption (true) or customer managed KMS key (false) | `bool` | `true` | no |
| <a name="input_vector_dimension"></a> [vector\_dimension](#input\_vector\_dimension) | Dimension of the vector embeddings (1024 for Titan v2, 1536 for Cohere v3) | `number` | `1024` | no |
| <a name="input_vector_ef_construction"></a> [vector\_ef\_construction](#input\_vector\_ef\_construction) | ef\_construction parameter for HNSW index | `number` | `512` | no |
| <a name="input_vector_field_name"></a> [vector\_field\_name](#input\_vector\_field\_name) | Name of the vector field in OpenSearch | `string` | `"bedrock-knowledge-base-default-vector"` | no |
| <a name="input_vector_m"></a> [vector\_m](#input\_vector\_m) | m parameter for HNSW index (number of bi-directional links) | `number` | `16` | no |
| <a name="input_vpce_ids"></a> [vpce\_ids](#input\_vpce\_ids) | List of VPC endpoint IDs for private access | `list(string)` | `[]` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_source_arn"></a> [data\_source\_arn](#output\_data\_source\_arn) | ARN of the KB data source |
| <a name="output_data_source_id"></a> [data\_source\_id](#output\_data\_source\_id) | Bedrock data source ID |
| <a name="output_kb_role_arn"></a> [kb\_role\_arn](#output\_kb\_role\_arn) | ARN of the IAM role |
| <a name="output_kb_role_name"></a> [kb\_role\_name](#output\_kb\_role\_name) | Name of the IAM role |
| <a name="output_knowledge_base_arn"></a> [knowledge\_base\_arn](#output\_knowledge\_base\_arn) | ARN of the Bedrock Knowledge Base |
| <a name="output_knowledge_base_id"></a> [knowledge\_base\_id](#output\_knowledge\_base\_id) | ID of the Bedrock Knowledge Base |
| <a name="output_opensearch_collection_arn"></a> [opensearch\_collection\_arn](#output\_opensearch\_collection\_arn) | ARN of the OpenSearch collection |
| <a name="output_opensearch_collection_endpoint"></a> [opensearch\_collection\_endpoint](#output\_opensearch\_collection\_endpoint) | Endpoint of the OpenSearch collection |
| <a name="output_opensearch_dashboard_endpoint"></a> [opensearch\_dashboard\_endpoint](#output\_opensearch\_dashboard\_endpoint) | OpenSearch Dashboards endpoint |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | ARN of the S3 bucket |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | Name of the S3 bucket |

<!-- END_TF_DOCS -->