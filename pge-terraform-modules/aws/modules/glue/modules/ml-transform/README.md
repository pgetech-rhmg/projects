<!-- BEGIN_TF_DOCS -->
# AWS Glue ML Transform module.
Terraform module which creates SAF2.0 aws\_glue\_ml\_transform in AWS.

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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.0 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_glue_ml_transform.glue_ml_transform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_ml_transform) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accuracy_cost_trade_off"></a> [accuracy\_cost\_trade\_off](#input\_accuracy\_cost\_trade\_off) | The value that is selected when tuning your transform for a balance between accuracy and cost. | `number` | `null` | no |
| <a name="input_catalog_id"></a> [catalog\_id](#input\_catalog\_id) | A unique identifier for the AWS Glue Data Catalog. | `string` | `null` | no |
| <a name="input_connection_name"></a> [connection\_name](#input\_connection\_name) | The name of the connection to the AWS Glue Data Catalog. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the ML Transform. | `string` | `null` | no |
| <a name="input_enforce_provided_labels"></a> [enforce\_provided\_labels](#input\_enforce\_provided\_labels) | The value to switch on or off to force the output to match the provided labels from users. | `bool` | `null` | no |
| <a name="input_glue_database_name"></a> [glue\_database\_name](#input\_glue\_database\_name) | A database name in the AWS Glue Data Catalog. | `string` | n/a | yes |
| <a name="input_glue_version"></a> [glue\_version](#input\_glue\_version) | The version of glue to use, for example 1.0. For information about available versions. | `string` | `null` | no |
| <a name="input_max_retries"></a> [max\_retries](#input\_max\_retries) | The maximum number of times to retry this ML Transform if it fails. | `number` | `null` | no |
| <a name="input_ml_transform"></a> [ml\_transform](#input\_ml\_transform) | worker\_type:<br> The type of predefined worker that is allocated when an ML Transform runs. Accepts a value of Standard, G.1X, or G.2X.<br>number\_of\_workers:<br> The number of workers of a defined worker\_type that are allocated when an ML Transform runs. Required with worker\_type.<br>max\_capacity:<br> The number of AWS Glue data processing units (DPUs) that are allocated to task runs for this transform. You can allocate from 2 to 100 DPUs; the default is 10. max\_capacity is a mutually exclusive option with number\_of\_workers and worker\_type. | <pre>object({<br>    worker_type       = string<br>    number_of_workers = number<br>    max_capacity      = number<br>  })</pre> | <pre>{<br>  "max_capacity": 10,<br>  "number_of_workers": null,<br>  "worker_type": null<br>}</pre> | no |
| <a name="input_ml_transform_name"></a> [ml\_transform\_name](#input\_ml\_transform\_name) | The name you assign to this ML Transform. It must be unique in your account. | `string` | n/a | yes |
| <a name="input_precision_recall_trade_off"></a> [precision\_recall\_trade\_off](#input\_precision\_recall\_trade\_off) | The value selected when tuning your transform for a balance between precision and recall. | `number` | `null` | no |
| <a name="input_primary_key_column_name"></a> [primary\_key\_column\_name](#input\_primary\_key\_column\_name) | The name of a column that uniquely identifies rows in the source table. | `string` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | The ARN of the IAM role associated with this ML Transform. | `string` | n/a | yes |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | A table name in the AWS Glue Data Catalog. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags. | `map(string)` | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | The ML Transform timeout in minutes. The default is 2880 minutes (48 hours). | `number` | `2800` | no |
| <a name="input_transform_type"></a> [transform\_type](#input\_transform\_type) | The type of machine learning transform. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name (ARN) of Glue ML Transform. |
| <a name="output_aws_glue_ml_transform"></a> [aws\_glue\_ml\_transform](#output\_aws\_glue\_ml\_transform) | A map of aws\_glue\_ml\_transform object. |
| <a name="output_id"></a> [id](#output\_id) | Glue ML Transform ID. |
| <a name="output_label_count"></a> [label\_count](#output\_label\_count) | The number of labels available for this transform. |
| <a name="output_schema"></a> [schema](#output\_schema) | The object that represents the schema that this transform accepts. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->