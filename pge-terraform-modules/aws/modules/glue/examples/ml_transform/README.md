<!-- BEGIN_TF_DOCS -->
# AWS GLUE with usage example
Terraform module which creates SAF2.0 Glue ML Transform resources in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

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
| <a name="module_glue_ml_transform"></a> [glue\_ml\_transform](#module\_glue\_ml\_transform) | ../../../glue/modules/ml-transform | n/a |
| <a name="module_ml_transform_iam_role"></a> [ml\_transform\_iam\_role](#module\_ml\_transform\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_lakeformation_permissions.iam_ml](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lakeformation_permissions) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_accuracy_cost_trade_off"></a> [accuracy\_cost\_trade\_off](#input\_accuracy\_cost\_trade\_off) | The value that is selected when tuning your transform for a balance between accuracy and cost. | `number` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_database_catalog_id"></a> [database\_catalog\_id](#input\_database\_catalog\_id) | Catalog id of the database. | `string` | n/a | yes |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the database. | `string` | n/a | yes |
| <a name="input_glue_database_name"></a> [glue\_database\_name](#input\_glue\_database\_name) | A database name in the AWS Glue Data Catalog. | `string` | n/a | yes |
| <a name="input_glue_version"></a> [glue\_version](#input\_glue\_version) | The version of glue to use, for example 1.0. For information about available versions. | `string` | n/a | yes |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | Policy arn for the iam role | `list(string)` | n/a | yes |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | The number of AWS Glue data processing units (DPUs) that are allocated to task runs for this transform. You can allocate from 2 to 100 DPUs; the default is 10. max\_capacity is a mutually exclusive option with number\_of\_workers and worker\_type. | `number` | n/a | yes |
| <a name="input_max_retries"></a> [max\_retries](#input\_max\_retries) | The maximum number of times to retry this ML Transform if it fails. | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A common name for resources. | `string` | n/a | yes |
| <a name="input_number_of_workers"></a> [number\_of\_workers](#input\_number\_of\_workers) | The number of workers of a defined worker\_type that are allocated when an ML Transform runs. Required with worker\_type. | `number` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | List of permissions granted to the principal. | `list(string)` | n/a | yes |
| <a name="input_precision_recall_trade_off"></a> [precision\_recall\_trade\_off](#input\_precision\_recall\_trade\_off) | The value selected when tuning your transform for a balance between precision and recall. | `number` | n/a | yes |
| <a name="input_primary_key_column_name"></a> [primary\_key\_column\_name](#input\_primary\_key\_column\_name) | The name of a column that uniquely identifies rows in the source table. | `string` | n/a | yes |
| <a name="input_role_service"></a> [role\_service](#input\_role\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | A table name in the AWS Glue Data Catalog. | `string` | n/a | yes |
| <a name="input_transform_type"></a> [transform\_type](#input\_transform\_type) | The type of machine learning transform. | `string` | n/a | yes |
| <a name="input_worker_type"></a> [worker\_type](#input\_worker\_type) | The type of predefined worker that is allocated when an ML Transform runs. Accepts a value of Standard, G.1X, or G.2X. Required with number\_of\_workers. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name (ARN) of Glue ML Transform. |
| <a name="output_id"></a> [id](#output\_id) | Glue ML Transform ID. |
| <a name="output_label_count"></a> [label\_count](#output\_label\_count) | The number of labels available for this transform. |
| <a name="output_schema"></a> [schema](#output\_schema) | The object that represents the schema that this transform accepts. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->