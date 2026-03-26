<!-- BEGIN_TF_DOCS -->
# OpenSearch Serverless module
Terraform module for provisioning and managing Amazon OpenSearch Serverless resources.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

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
| [aws_opensearchserverless_access_policy.data_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_access_policy) | resource |
| [aws_opensearchserverless_collection.collection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_collection) | resource |
| [aws_opensearchserverless_security_policy.encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_security_policy) | resource |
| [aws_opensearchserverless_security_policy.network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_security_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_public_access"></a> [allow\_public\_access](#input\_allow\_public\_access) | Whether to allow public access to the collection | `bool` | `false` | no |
| <a name="input_collection_create_timeout"></a> [collection\_create\_timeout](#input\_collection\_create\_timeout) | Timeout for creating the collection | `string` | `"20m"` | no |
| <a name="input_collection_delete_timeout"></a> [collection\_delete\_timeout](#input\_collection\_delete\_timeout) | Timeout for deleting the collection | `string` | `"20m"` | no |
| <a name="input_collection_description"></a> [collection\_description](#input\_collection\_description) | Description of the OpenSearch Serverless collection | `string` | `"OpenSearch Serverless collection managed by Terraform"` | no |
| <a name="input_collection_name"></a> [collection\_name](#input\_collection\_name) | Name of the OpenSearch Serverless collection | `string` | n/a | yes |
| <a name="input_collection_type"></a> [collection\_type](#input\_collection\_type) | Type of collection. Valid values: SEARCH, TIMESERIES, VECTORSEARCH | `string` | `"VECTORSEARCH"` | no |
| <a name="input_create_data_access_policy"></a> [create\_data\_access\_policy](#input\_create\_data\_access\_policy) | Whether to create a data access policy for the collection | `bool` | `true` | no |
| <a name="input_create_encryption_policy"></a> [create\_encryption\_policy](#input\_create\_encryption\_policy) | Whether to create an encryption policy for the collection | `bool` | `true` | no |
| <a name="input_create_network_policy"></a> [create\_network\_policy](#input\_create\_network\_policy) | Whether to create a network policy for the collection | `bool` | `true` | no |
| <a name="input_data_access_permissions"></a> [data\_access\_permissions](#input\_data\_access\_permissions) | List of permissions for collection-level access. Valid values: aoss:CreateCollectionItems, aoss:DeleteCollectionItems, aoss:UpdateCollectionItems, aoss:DescribeCollectionItems | `list(string)` | <pre>[<br/>  "aoss:CreateCollectionItems",<br/>  "aoss:DeleteCollectionItems",<br/>  "aoss:UpdateCollectionItems",<br/>  "aoss:DescribeCollectionItems"<br/>]</pre> | no |
| <a name="input_data_access_policy_description"></a> [data\_access\_policy\_description](#input\_data\_access\_policy\_description) | Description of the data access policy | `string` | `"Data access policy for OpenSearch Serverless collection"` | no |
| <a name="input_data_access_policy_name"></a> [data\_access\_policy\_name](#input\_data\_access\_policy\_name) | Name of the data access policy. If null, defaults to <collection\_name>-access (must be 3-32 characters) | `string` | `null` | no |
| <a name="input_data_access_principals"></a> [data\_access\_principals](#input\_data\_access\_principals) | List of IAM principal ARNs that have access to the collection and indexes (used when use\_multi\_tier\_access is false) | `list(string)` | `[]` | no |
| <a name="input_encryption_policy_description"></a> [encryption\_policy\_description](#input\_encryption\_policy\_description) | Description of the encryption policy | `string` | `"Encryption policy for OpenSearch Serverless collection"` | no |
| <a name="input_encryption_policy_name"></a> [encryption\_policy\_name](#input\_encryption\_policy\_name) | Name of the encryption policy. If null, defaults to <collection\_name>-enc (must be 3-32 characters) | `string` | `null` | no |
| <a name="input_index_permissions"></a> [index\_permissions](#input\_index\_permissions) | List of permissions for index-level access. Valid values: aoss:CreateIndex, aoss:DeleteIndex, aoss:UpdateIndex, aoss:DescribeIndex, aoss:ReadDocument, aoss:WriteDocument | `list(string)` | <pre>[<br/>  "aoss:CreateIndex",<br/>  "aoss:DeleteIndex",<br/>  "aoss:UpdateIndex",<br/>  "aoss:DescribeIndex",<br/>  "aoss:ReadDocument",<br/>  "aoss:WriteDocument"<br/>]</pre> | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the customer-managed KMS key for encryption. Required when use\_aws\_owned\_key is false (PGE standard) | `string` | `null` | no |
| <a name="input_network_policy_description"></a> [network\_policy\_description](#input\_network\_policy\_description) | Description of the network policy | `string` | `"Network policy for OpenSearch Serverless collection"` | no |
| <a name="input_network_policy_name"></a> [network\_policy\_name](#input\_network\_policy\_name) | Name of the network policy. If null, defaults to <collection\_name>-net (must be 3-32 characters) | `string` | `null` | no |
| <a name="input_privileged_principals"></a> [privileged\_principals](#input\_privileged\_principals) | IAM principals with wildcard index access (admins, automation, Bedrock roles). Used when use\_multi\_tier\_access is true. | `list(string)` | `[]` | no |
| <a name="input_public_access_principals"></a> [public\_access\_principals](#input\_public\_access\_principals) | IAM principals with limited access to specific named indexes only (SSO users, app roles). Used when use\_multi\_tier\_access is true. | `list(string)` | `[]` | no |
| <a name="input_public_index_names"></a> [public\_index\_names](#input\_public\_index\_names) | List of specific index names that public\_access\_principals can access. Used when use\_multi\_tier\_access is true. Example: ['public-kb-index', 'general-kb-index'] | `list(string)` | `[]` | no |
| <a name="input_public_index_permissions"></a> [public\_index\_permissions](#input\_public\_index\_permissions) | Permissions granted to public\_access\_principals for specific named indexes. Used when use\_multi\_tier\_access is true. | `list(string)` | <pre>[<br/>  "aoss:CreateIndex",<br/>  "aoss:DeleteIndex",<br/>  "aoss:UpdateIndex",<br/>  "aoss:DescribeIndex",<br/>  "aoss:ReadDocument",<br/>  "aoss:WriteDocument"<br/>]</pre> | no |
| <a name="input_standby_replicas"></a> [standby\_replicas](#input\_standby\_replicas) | Whether to enable standby replicas. Valid values: ENABLED, DISABLED | `string` | `"ENABLED"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to resources. Must include PGE required tags: AppID, Environment, DataClassification, CRIS, Notify, Owner, Compliance, Order | `map(any)` | `{}` | no |
| <a name="input_use_aws_owned_key"></a> [use\_aws\_owned\_key](#input\_use\_aws\_owned\_key) | Whether to use AWS owned key for encryption. Set to true for AWS owned key, false for customer managed KMS key. PGE standard is to use customer-managed KMS keys (false) | `bool` | `false` | no |
| <a name="input_use_multi_tier_access"></a> [use\_multi\_tier\_access](#input\_use\_multi\_tier\_access) | Enable 3-tier access control matching Amplify security pattern (privileged, public, specific indexes) | `bool` | `false` | no |
| <a name="input_vpce_ids"></a> [vpce\_ids](#input\_vpce\_ids) | List of VPC endpoint IDs that can access the collection | `list(string)` | `[]` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_mode"></a> [access\_mode](#output\_access\_mode) | Access control mode: single-tier or multi-tier |
| <a name="output_collection_all"></a> [collection\_all](#output\_collection\_all) | Map of all collection attributes |
| <a name="output_collection_arn"></a> [collection\_arn](#output\_collection\_arn) | ARN of the OpenSearch Serverless collection |
| <a name="output_collection_endpoint"></a> [collection\_endpoint](#output\_collection\_endpoint) | Collection endpoint for OpenSearch operations |
| <a name="output_collection_id"></a> [collection\_id](#output\_collection\_id) | Unique identifier of the OpenSearch Serverless collection |
| <a name="output_collection_name"></a> [collection\_name](#output\_collection\_name) | Name of the OpenSearch Serverless collection |
| <a name="output_collection_type"></a> [collection\_type](#output\_collection\_type) | Type of the collection |
| <a name="output_dashboard_endpoint"></a> [dashboard\_endpoint](#output\_dashboard\_endpoint) | Dashboard endpoint for OpenSearch Dashboards |
| <a name="output_data_access_policy"></a> [data\_access\_policy](#output\_data\_access\_policy) | JSON policy document of the data access policy |
| <a name="output_data_access_policy_name"></a> [data\_access\_policy\_name](#output\_data\_access\_policy\_name) | Name of the data access policy |
| <a name="output_data_access_policy_version"></a> [data\_access\_policy\_version](#output\_data\_access\_policy\_version) | Version of the data access policy |
| <a name="output_encryption_policy"></a> [encryption\_policy](#output\_encryption\_policy) | JSON policy document of the encryption policy |
| <a name="output_encryption_policy_name"></a> [encryption\_policy\_name](#output\_encryption\_policy\_name) | Name of the encryption policy |
| <a name="output_encryption_policy_version"></a> [encryption\_policy\_version](#output\_encryption\_policy\_version) | Version of the encryption policy |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The ARN of the KMS key used to encrypt the collection |
| <a name="output_network_policy"></a> [network\_policy](#output\_network\_policy) | JSON policy document of the network policy |
| <a name="output_network_policy_name"></a> [network\_policy\_name](#output\_network\_policy\_name) | Name of the network policy |
| <a name="output_network_policy_version"></a> [network\_policy\_version](#output\_network\_policy\_version) | Version of the network policy |
| <a name="output_privileged_principals"></a> [privileged\_principals](#output\_privileged\_principals) | List of privileged principals with wildcard index access (multi-tier mode only) |
| <a name="output_public_access_principals"></a> [public\_access\_principals](#output\_public\_access\_principals) | List of public principals with limited named index access (multi-tier mode only) |
| <a name="output_public_index_names"></a> [public\_index\_names](#output\_public\_index\_names) | List of index names accessible to public principals (multi-tier mode only) |

<!-- END_TF_DOCS -->