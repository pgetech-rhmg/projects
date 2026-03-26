<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |

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
| <a name="module_opensearch_serverless"></a> [opensearch\_serverless](#module\_opensearch\_serverless) | ../../modules/opensearch-serverless | n/a |
| <a name="module_opensearch_vpce"></a> [opensearch\_vpce](#module\_opensearch\_vpce) | app.terraform.io/pgetech/vpc-endpoint/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.security_group_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | PGE Application ID (format: APP-#####) | `string` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score (High, Medium, or Low) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | List of compliance requirements (SOX, HIPAA, CCPA, BCSI, None) | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Data classification level | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | Environment name (Dev, Test, QA, or Prod) | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | List of email addresses for notifications | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | PGE Order number (7-9 digits) | `string` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List of three LANIDs responsible for the resources | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | AWS account number | `string` | n/a | yes |
| <a name="input_allow_public_access"></a> [allow\_public\_access](#input\_allow\_public\_access) | Allow public internet access to the collection (not recommended for production) | `bool` | `false` | no |
| <a name="input_app_prefix"></a> [app\_prefix](#input\_app\_prefix) | Application prefix for resource naming (3-10 lowercase alphanumeric characters) | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where resources will be created | `string` | `"us-west-2"` | no |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS IAM role for KMS key administration | `string` | `"TerraformAdmin"` | no |
| <a name="input_collection_type"></a> [collection\_type](#input\_collection\_type) | Type of OpenSearch Serverless collection (SEARCH, TIMESERIES, VECTORSEARCH) | `string` | `"VECTORSEARCH"` | no |
| <a name="input_create_vpce"></a> [create\_vpce](#input\_create\_vpce) | Whether to create a VPC endpoint for private access | `bool` | `false` | no |
| <a name="input_data_access_permissions"></a> [data\_access\_permissions](#input\_data\_access\_permissions) | List of collection-level permissions to grant | `list(string)` | <pre>[<br/>  "aoss:CreateCollectionItems",<br/>  "aoss:DeleteCollectionItems",<br/>  "aoss:UpdateCollectionItems",<br/>  "aoss:DescribeCollectionItems"<br/>]</pre> | no |
| <a name="input_data_access_principals"></a> [data\_access\_principals](#input\_data\_access\_principals) | List of IAM principal ARNs to grant access to the collection (defaults to current user if empty) | `list(string)` | `[]` | no |
| <a name="input_enable_standby_replicas"></a> [enable\_standby\_replicas](#input\_enable\_standby\_replicas) | Enable standby replicas for high availability | `bool` | `true` | no |
| <a name="input_index_permissions"></a> [index\_permissions](#input\_index\_permissions) | List of index-level permissions to grant | `list(string)` | <pre>[<br/>  "aoss:CreateIndex",<br/>  "aoss:DeleteIndex",<br/>  "aoss:UpdateIndex",<br/>  "aoss:DescribeIndex",<br/>  "aoss:ReadDocument",<br/>  "aoss:WriteDocument"<br/>]</pre> | no |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | KMS key alias role suffix | `string` | `"aoss"` | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags to add to resources (in addition to required PGE tags) | `map(string)` | `{}` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs for VPC endpoint (used when use\_ssm\_for\_network is false) | `list(string)` | `[]` | no |
| <a name="input_security_group_ids_ssm_parameter"></a> [security\_group\_ids\_ssm\_parameter](#input\_security\_group\_ids\_ssm\_parameter) | SSM parameter name containing comma-separated security group IDs (used when use\_ssm\_for\_network is true) | `string` | `"/network/security-groups/opensearch"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for VPC endpoint (required if create\_vpce is true and use\_ssm\_for\_network is false) | `list(string)` | `[]` | no |
| <a name="input_subnet_ids_ssm_parameter"></a> [subnet\_ids\_ssm\_parameter](#input\_subnet\_ids\_ssm\_parameter) | SSM parameter name containing comma-separated subnet IDs (used when use\_ssm\_for\_network is true) | `string` | `"/network/subnets/private"` | no |
| <a name="input_use_ssm_for_network"></a> [use\_ssm\_for\_network](#input\_use\_ssm\_for\_network) | Use SSM Parameter Store to retrieve VPC, subnet, and security group information (PGE standard) | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for VPC endpoint (required if create\_vpce is true and use\_ssm\_for\_network is false) | `string` | `null` | no |
| <a name="input_vpc_id_ssm_parameter"></a> [vpc\_id\_ssm\_parameter](#input\_vpc\_id\_ssm\_parameter) | SSM parameter name containing VPC ID (used when use\_ssm\_for\_network is true) | `string` | `"/network/vpc/id"` | no |
| <a name="input_vpce_ids"></a> [vpce\_ids](#input\_vpce\_ids) | List of existing VPC endpoint IDs to allow access (alternative to create\_vpce) | `list(string)` | `[]` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_collection_arn"></a> [collection\_arn](#output\_collection\_arn) | ARN of the OpenSearch Serverless collection |
| <a name="output_collection_endpoint"></a> [collection\_endpoint](#output\_collection\_endpoint) | Collection endpoint for OpenSearch API operations (use this for indexing and search) |
| <a name="output_collection_id"></a> [collection\_id](#output\_collection\_id) | Unique identifier of the OpenSearch Serverless collection |
| <a name="output_collection_name"></a> [collection\_name](#output\_collection\_name) | Name of the OpenSearch Serverless collection |
| <a name="output_collection_type"></a> [collection\_type](#output\_collection\_type) | Type of the collection (SEARCH, TIMESERIES, or VECTORSEARCH) |
| <a name="output_dashboard_endpoint"></a> [dashboard\_endpoint](#output\_dashboard\_endpoint) | Dashboard endpoint for OpenSearch Dashboards UI |
| <a name="output_data_access_policy_name"></a> [data\_access\_policy\_name](#output\_data\_access\_policy\_name) | Name of the data access policy |
| <a name="output_encryption_policy_name"></a> [encryption\_policy\_name](#output\_encryption\_policy\_name) | Name of the encryption security policy |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of the KMS key used for encryption |
| <a name="output_network_policy_name"></a> [network\_policy\_name](#output\_network\_policy\_name) | Name of the network security policy |
| <a name="output_vpc_endpoint_dns_entries"></a> [vpc\_endpoint\_dns\_entries](#output\_vpc\_endpoint\_dns\_entries) | DNS entries for the VPC endpoint (if created) |
| <a name="output_vpc_endpoint_id"></a> [vpc\_endpoint\_id](#output\_vpc\_endpoint\_id) | ID of the VPC endpoint (if created) |

<!-- END_TF_DOCS -->