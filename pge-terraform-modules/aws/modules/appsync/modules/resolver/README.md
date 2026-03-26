<!-- BEGIN_TF_DOCS -->
# AWS AppSync module
# Terraform module which creates AppSync Resolver

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
| [aws_appsync_resolver.appsync_resolver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_resolver) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_id"></a> [api\_id](#input\_api\_id) | API ID for the GraphQL API. | `string` | n/a | yes |
| <a name="input_caching_keys"></a> [caching\_keys](#input\_caching\_keys) | List of caching key. | `list(string)` | `[]` | no |
| <a name="input_data_source"></a> [data\_source](#input\_data\_source) | Data source name. | `string` | `null` | no |
| <a name="input_field"></a> [field](#input\_field) | Field name from the schema defined in the GraphQL API. | `string` | n/a | yes |
| <a name="input_kind"></a> [kind](#input\_kind) | Resolver type. Valid values are UNIT and PIPELINE. | `string` | `null` | no |
| <a name="input_max_batch_size"></a> [max\_batch\_size](#input\_max\_batch\_size) | Maximum batching size for a resolver. Valid values are between 0 and 2000. | `string` | `0` | no |
| <a name="input_pipeline_config"></a> [pipeline\_config](#input\_pipeline\_config) | PipelineConfig | `map(any)` | `null` | no |
| <a name="input_request_template"></a> [request\_template](#input\_request\_template) | Request mapping template for UNIT resolver or 'before mapping template' for PIPELINE resolver. Required for non-Lambda resolvers. | `string` | `null` | no |
| <a name="input_response_template"></a> [response\_template](#input\_response\_template) | Response mapping template for UNIT resolver or 'after mapping template' for PIPELINE resolver. Required for non-Lambda resolvers. | `string` | `null` | no |
| <a name="input_sync_config"></a> [sync\_config](#input\_sync\_config) | conflict\_detection :<br>  Conflict Detection strategy to use. Valid values are NONE and VERSION.<br>conflict\_handler :<br>  Conflict Resolution strategy to perform in the event of a conflict. Valid values are NONE, OPTIMISTIC\_CONCURRENCY, AUTOMERGE, and LAMBDA.<br>lambda\_conflict\_handler\_arn :<br>  ARN for the Lambda function to use as the Conflict Handler. | <pre>object({<br>    conflict_detection          = optional(string)<br>    conflict_handler            = optional(string)<br>    lambda_conflict_handler_arn = optional(string)<br>  })</pre> | <pre>{<br>  "conflict_detection": null,<br>  "conflict_handler": null,<br>  "lambda_conflict_handler_arn": null<br>}</pre> | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | TTL in seconds. | `number` | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | Type name from the schema defined in the GraphQL API. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appsync_resolver_all"></a> [appsync\_resolver\_all](#output\_appsync\_resolver\_all) | Map of appsync\_resolver object. |
| <a name="output_appsync_resolver_arn"></a> [appsync\_resolver\_arn](#output\_appsync\_resolver\_arn) | ARN |


<!-- END_TF_DOCS -->