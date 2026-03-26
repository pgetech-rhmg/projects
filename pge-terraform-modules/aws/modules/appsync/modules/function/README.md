<!-- BEGIN_TF_DOCS -->
# AWS AppSync Module
# Terraform module which creates AppSync Function

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appsync_function.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_function) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_id"></a> [api\_id](#input\_api\_id) | ID of the associated AppSync API. | `string` | n/a | yes |
| <a name="input_data_source"></a> [data\_source](#input\_data\_source) | Function data source name. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Function description. | `string` | `null` | no |
| <a name="input_function_version"></a> [function\_version](#input\_function\_version) | Version of the request mapping template. Currently the supported value is 2018-05-29. | `string` | `"2018-05-29"` | no |
| <a name="input_max_batch_size"></a> [max\_batch\_size](#input\_max\_batch\_size) | Maximum batching size for a resolver. Valid values are between 0 and 2000. | `number` | `0` | no |
| <a name="input_name"></a> [name](#input\_name) | Function name. The function name does not have to be unique. | `string` | n/a | yes |
| <a name="input_request_mapping_template"></a> [request\_mapping\_template](#input\_request\_mapping\_template) | Function request mapping template. Functions support only the 2018-05-29 version of the request mapping template. | `string` | n/a | yes |
| <a name="input_response_mapping_template"></a> [response\_mapping\_template](#input\_response\_mapping\_template) | Function response mapping template. | `string` | n/a | yes |
| <a name="input_sync_config"></a> [sync\_config](#input\_sync\_config) | conflict\_detection :<br>  Conflict Detection strategy to use. Valid values are NONE and VERSION.<br>conflict\_handler :<br>  Conflict Resolution strategy to perform in the event of a conflict. Valid values are NONE, OPTIMISTIC\_CONCURRENCY, AUTOMERGE, and LAMBDA.<br>lambda\_conflict\_handler\_arn :<br>  ARN for the Lambda function to use as the Conflict Handler. | <pre>object({<br>    conflict_detection          = optional(string)<br>    conflict_handler            = optional(string)<br>    lambda_conflict_handler_arn = optional(string)<br>  })</pre> | <pre>{<br>  "conflict_detection": null,<br>  "conflict_handler": null,<br>  "lambda_conflict_handler_arn": null<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_appsync_function_all"></a> [aws\_appsync\_function\_all](#output\_aws\_appsync\_function\_all) | Map of aws\_appsync\_function object. |
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN of the Function object. |
| <a name="output_function_id"></a> [function\_id](#output\_function\_id) | Unique ID representing the Function object. |
| <a name="output_id"></a> [id](#output\_id) | API Function ID (Formatted as ApiId-FunctionId) |


<!-- END_TF_DOCS -->