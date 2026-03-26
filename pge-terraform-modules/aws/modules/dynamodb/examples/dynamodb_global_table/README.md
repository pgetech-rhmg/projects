<!-- BEGIN_TF_DOCS -->
# AWS dynamodb with resource table usage example
Terraform module which creates SAF2.0 dynamodb with resource table in AWS.
Dynamodb-table with global-replica cannot be created with "table\_billing\_mode" "PROVISIONED".
This is a known issue and is a bug with the aws-provider and reported in the below github link:
https://github.com/hashicorp/terraform-provider-aws/issues/13097

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

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
| <a name="module_dynamodb_table_us_west_2"></a> [dynamodb\_table\_us\_west\_2](#module\_dynamodb\_table\_us\_west\_2) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

No resources.

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
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role | `string` | n/a | yes |
| <a name="input_create_replica"></a> [create\_replica](#input\_create\_replica) | Whether to create a replica or not | `bool` | n/a | yes |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | The attribute to use as the hash (partition) key. Must also be defined as an attribute | `string` | n/a | yes |
| <a name="input_hash_range_key_attributes"></a> [hash\_range\_key\_attributes](#input\_hash\_range\_key\_attributes) | List of nested attribute definitions. Only required for hash\_key and range\_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data | `list(map(string))` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console | `string` | `"Parameter Store KMS master key"` | no |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | KMS role | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_stream_enabled"></a> [stream\_enabled](#input\_stream\_enabled) | Indicates whether Streams are to be enabled (true) or disabled (false). | `bool` | n/a | yes |
| <a name="input_stream_view_type"></a> [stream\_view\_type](#input\_stream\_view\_type) | When an item in the table is modified, StreamViewType determines what information is written to the table's stream. Valid values are: KEYS\_ONLY, NEW\_IMAGE, OLD\_IMAGE and NEW\_AND\_OLD\_IMAGES when the stream is enabled and value must be null when stream is disabled. | `string` | n/a | yes |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | Dynamodb table name (space is not allowed). | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dynamodb_table_arn_us_west_2"></a> [dynamodb\_table\_arn\_us\_west\_2](#output\_dynamodb\_table\_arn\_us\_west\_2) | ARN of the DynamoDB table. |
| <a name="output_dynamodb_table_id_us_west_2"></a> [dynamodb\_table\_id\_us\_west\_2](#output\_dynamodb\_table\_id\_us\_west\_2) | ID of the DynamoDB table. |
| <a name="output_stream_arn_us_west_2"></a> [stream\_arn\_us\_west\_2](#output\_stream\_arn\_us\_west\_2) | The ARN of the Table Stream. Only available when stream\_enabled = true. |
| <a name="output_stream_label_us_west_2"></a> [stream\_label\_us\_west\_2](#output\_stream\_label\_us\_west\_2) | A timestamp, in ISO 8601 format, for this stream. Note that this timestamp is not a unique identifier for the stream on its own. However, the combination of AWS customer ID, table name and this field is guaranteed to be unique. It can be used for creating CloudWatch Alarms. Only available when stream\_enabled = true. |

<!-- END_TF_DOCS -->