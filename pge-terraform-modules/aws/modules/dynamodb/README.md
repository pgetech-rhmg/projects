 # AWS DynamoDB Terraform module

 Terraform base module for deploying and managing DynamoDB modules (dynamodb_table, dynamodb_global_table, dynamodb_kinesis_streaming) on Amazon Web Services (AWS). 

 DynamoDB Modules can be found at `dynamodb/modules/*`
 
 DYNAMODB_TABLE:

 Sub-module located at `dynamodb/modules/dynamodb_table`
 This sub-module creates the 'dynamodb table'.
 
 DYNAMODB_GLOBAL_TABLE:

 Sub-module located at `dynamodb/modules/dynamodb_global_table`
 This sub-module creates the 'dynamodb global table' ; Resources include: 'aws_dynamodb_table' and 'aws_dynamodb_global_table'

 DYNAMODB_KINESIS_STREAMING:

 Sub-module located at `dynamodb/modules/dynamodb_kinesis_streaming`
 This  sub-module creates the dynamodb with 'kinesis streaming destination'.

 EXAMPLES:
 DynamoDB Modules examples can be found at `dynamodb/examples/*`.

<!-- BEGIN_TF_DOCS -->
# AWS DynamoDb Table module.
Terraform module which creates SAF2.0 Dynamodb tables in AWS.
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

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.90.1 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.4 |

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
| [aws_dynamodb_table.dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [external_external.validate_replica_kms_key_arn_us_east_1](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.validate_server_side_encryption_kms_key_arn](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_replica"></a> [create\_replica](#input\_create\_replica) | Whether to create a replica or not | `bool` | `false` | no |
| <a name="input_global_secondary_indexes"></a> [global\_secondary\_indexes](#input\_global\_secondary\_indexes) | Describe a GSI for the table; subject to the normal limits on the number of GSIs, projected attributes, etc. | `any` | `[]` | no |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | The attribute to use as the hash (partition) key. Must also be defined as an attribute | `string` | n/a | yes |
| <a name="input_hash_range_key_attributes"></a> [hash\_range\_key\_attributes](#input\_hash\_range\_key\_attributes) | List of nested attribute definitions. Only required for hash\_key and range\_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data | `list(map(string))` | n/a | yes |
| <a name="input_local_secondary_indexes"></a> [local\_secondary\_indexes](#input\_local\_secondary\_indexes) | Describe an LSI on the table; these can only be allocated at creation so you cannot change this definition after you have created the resource. | `any` | `[]` | no |
| <a name="input_range_key"></a> [range\_key](#input\_range\_key) | The attribute to use as the range (sort) key. Must also be defined as an attribute | `string` | `null` | no |
| <a name="input_read_capacity"></a> [read\_capacity](#input\_read\_capacity) | The number of read units for this table. If the billing\_mode is PROVISIONED, this field should be greater than 0 | `number` | `0` | no |
| <a name="input_replica_kms_key_arn_us_east_1"></a> [replica\_kms\_key\_arn\_us\_east\_1](#input\_replica\_kms\_key\_arn\_us\_east\_1) | The ARN of the CMK that should be used for the AWS KMS encryption for the replica. | `string` | `null` | no |
| <a name="input_restore_date_time"></a> [restore\_date\_time](#input\_restore\_date\_time) | The time of the point-in-time recovery point to resolve. | `number` | `null` | no |
| <a name="input_restore_source_name"></a> [restore\_source\_name](#input\_restore\_source\_name) | The name of the table to restore. Must match the name of an existing table. | `string` | `null` | no |
| <a name="input_restore_to_latest_time"></a> [restore\_to\_latest\_time](#input\_restore\_to\_latest\_time) | If set, restores table to the most recent point-in-time recovery point. | `bool` | `false` | no |
| <a name="input_server_side_encryption_kms_key_arn"></a> [server\_side\_encryption\_kms\_key\_arn](#input\_server\_side\_encryption\_kms\_key\_arn) | The ARN of the CMK that should be used for the AWS KMS encryption. This attribute should only be specified if the key is different from the default DynamoDB CMK, alias/aws/dynamodb. | `string` | `null` | no |
| <a name="input_stream_enabled"></a> [stream\_enabled](#input\_stream\_enabled) | Indicates whether Streams are to be enabled (true) or disabled (false). | `bool` | `false` | no |
| <a name="input_stream_view_type"></a> [stream\_view\_type](#input\_stream\_view\_type) | When an item in the table is modified, StreamViewType determines what information is written to the table's stream. Valid values are: KEYS\_ONLY, NEW\_IMAGE, OLD\_IMAGE and NEW\_AND\_OLD\_IMAGES when the stream is enabled and value must be null when stream is disabled. | `string` | `null` | no |
| <a name="input_table_billing_mode"></a> [table\_billing\_mode](#input\_table\_billing\_mode) | Controls how you are charged for read and write throughput and how you manage capacity.To create global-table-replica set the 'table\_billing\_mode' to 'PAY\_PER\_REQUEST'. | `string` | `"PAY_PER_REQUEST"` | no |
| <a name="input_table_class"></a> [table\_class](#input\_table\_class) | The storage class of the table. Valid values are STANDARD and STANDARD\_INFREQUENT\_ACCESS. | `string` | `"STANDARD"` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | Dynamodb table name (space is not allowed). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to populate on the created table. | `map(string)` | n/a | yes |
| <a name="input_timeouts_create"></a> [timeouts\_create](#input\_timeouts\_create) | Used when creating the table. | `string` | `"10m"` | no |
| <a name="input_timeouts_delete"></a> [timeouts\_delete](#input\_timeouts\_delete) | Used when deleting the table | `string` | `"10m"` | no |
| <a name="input_timeouts_update"></a> [timeouts\_update](#input\_timeouts\_update) | Used when updating the table configuration and reset for each individual Global Secondary Index and Replica update. | `string` | `"60m"` | no |
| <a name="input_ttl_attribute_name"></a> [ttl\_attribute\_name](#input\_ttl\_attribute\_name) | The name of the table attribute to store the TTL timestamp in | `string` | `null` | no |
| <a name="input_ttl_enabled"></a> [ttl\_enabled](#input\_ttl\_enabled) | Indicates whether ttl is enabled | `bool` | `false` | no |
| <a name="input_write_capacity"></a> [write\_capacity](#input\_write\_capacity) | The number of write units for this table. If the billing\_mode is PROVISIONED, this field should be greater than 0 | `number` | `0` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dynamodb_table"></a> [dynamodb\_table](#output\_dynamodb\_table) | Object of the DynamoDB table |
| <a name="output_dynamodb_table_arn"></a> [dynamodb\_table\_arn](#output\_dynamodb\_table\_arn) | ARN of the DynamoDB table |
| <a name="output_dynamodb_table_id"></a> [dynamodb\_table\_id](#output\_dynamodb\_table\_id) | ID of the DynamoDB table |
| <a name="output_replica_arn"></a> [replica\_arn](#output\_replica\_arn) | ARN of the replica |
| <a name="output_replica_stream_arn"></a> [replica\_stream\_arn](#output\_replica\_stream\_arn) | ARN of the replica Table Stream. Only available when stream\_enabled = true |
| <a name="output_replica_stream_label"></a> [replica\_stream\_label](#output\_replica\_stream\_label) | Timestamp, in ISO 8601 format, for the replica stream. Note that this timestamp is not a unique identifier for the stream on its own. However, the combination of AWS customer ID, table name and this field is guaranteed to be unique. It can be used for creating CloudWatch Alarms. Only available when stream\_enabled = true. |
| <a name="output_stream_arn"></a> [stream\_arn](#output\_stream\_arn) | The ARN of the Table Stream. Only available when stream\_enabled = true |
| <a name="output_stream_label"></a> [stream\_label](#output\_stream\_label) | A timestamp, in ISO 8601 format, for this stream. Note that this timestamp is not a unique identifier for the stream on its own. However, the combination of AWS customer ID, table name and this field is guaranteed to be unique. It can be used for creating CloudWatch Alarms. Only available when stream\_enabled = true. |

<!-- END_TF_DOCS -->