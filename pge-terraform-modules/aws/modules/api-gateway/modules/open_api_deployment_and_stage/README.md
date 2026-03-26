<!-- BEGIN_TF_DOCS -->
# AWS API Gateway deployment and stage module using OpenApi
Terraform module which creates SAF2.0 API Gateway deployment and stage using OpenApi approch in AWS

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
| [aws_api_gateway_account.api_gateway_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account) | resource |
| [aws_api_gateway_base_path_mapping.api_gateway_base_path_mapping](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_base_path_mapping) | resource |
| [aws_api_gateway_client_certificate.api_gateway_client_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_client_certificate) | resource |
| [aws_api_gateway_deployment.api_gateway_deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_documentation_part.api_gateway_documentation_part](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_documentation_part) | resource |
| [aws_api_gateway_documentation_version.api_gateway_documentation_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_documentation_version) | resource |
| [aws_api_gateway_method_settings.api_gateway_method_settings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_stage.api_gateway_stage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_api_gateway_vpc_link.api_gateway_vpc_link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_vpc_link) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_log_settings_destination_arn"></a> [access\_log\_settings\_destination\_arn](#input\_access\_log\_settings\_destination\_arn) | The Amazon Resource Name (ARN) of the CloudWatch Logs log group or Kinesis Data Firehose delivery stream to receive access logs. | `string` | `null` | no |
| <a name="input_access_log_settings_format"></a> [access\_log\_settings\_format](#input\_access\_log\_settings\_format) | The formatting and values recorded in the logs. | `string` | `null` | no |
| <a name="input_account_cloudwatch_role_arn"></a> [account\_cloudwatch\_role\_arn](#input\_account\_cloudwatch\_role\_arn) | The ARN of an IAM role for CloudWatch (to allow logging & monitoring). | `string` | `null` | no |
| <a name="input_api_gateway_account_create"></a> [api\_gateway\_account\_create](#input\_api\_gateway\_account\_create) | Whether to create API Gateway gateway response. | `bool` | `false` | no |
| <a name="input_api_gateway_client_certificate_create"></a> [api\_gateway\_client\_certificate\_create](#input\_api\_gateway\_client\_certificate\_create) | Whether to create API Gateway Client Certificate. | `bool` | `false` | no |
| <a name="input_base_path_mapping_base_path"></a> [base\_path\_mapping\_base\_path](#input\_base\_path\_mapping\_base\_path) | Path segment that must be prepended to the path when accessing the API via this mapping. | `string` | `null` | no |
| <a name="input_base_path_mapping_domain_name"></a> [base\_path\_mapping\_domain\_name](#input\_base\_path\_mapping\_domain\_name) | The already-registered domain name to connect the API to. | `string` | `null` | no |
| <a name="input_base_path_mapping_stage_name"></a> [base\_path\_mapping\_stage\_name](#input\_base\_path\_mapping\_stage\_name) | The name of a specific deployment stage to expose at the given path | `string` | `null` | no |
| <a name="input_client_certificate_description"></a> [client\_certificate\_description](#input\_client\_certificate\_description) | The description of the client certificate. | `string` | `null` | no |
| <a name="input_deployment_description"></a> [deployment\_description](#input\_deployment\_description) | The description of the deployment. | `string` | `null` | no |
| <a name="input_deployment_rest_api_id"></a> [deployment\_rest\_api\_id](#input\_deployment\_rest\_api\_id) | The ID of the REST API | `string` | n/a | yes |
| <a name="input_deployment_triggers"></a> [deployment\_triggers](#input\_deployment\_triggers) | Map of arbitrary keys and values that, when changed, will trigger a redeployment. | `map(string)` | `null` | no |
| <a name="input_deployment_variables"></a> [deployment\_variables](#input\_deployment\_variables) | Map to set on the stage managed by the stage\_name argument. | `map(string)` | `null` | no |
| <a name="input_documentation_description"></a> [documentation\_description](#input\_documentation\_description) | The description of the API documentation version. | `string` | `null` | no |
| <a name="input_documentation_part_properties"></a> [documentation\_part\_properties](#input\_documentation\_part\_properties) | A content map of API specific keyvalue pairs describing the targeted API entity. The map must be encoded as a JSON string. Only Swaggercompliant keyvalue pairs can be exported and, hence, published. | `string` | `null` | no |
| <a name="input_documentation_version"></a> [documentation\_version](#input\_documentation\_version) | The version identifier of the API documentation snapshot. | `string` | `null` | no |
| <a name="input_location_method"></a> [location\_method](#input\_location\_method) | The HTTP verb of a method. The default value is * for any method. | `string` | `null` | no |
| <a name="input_location_name"></a> [location\_name](#input\_location\_name) | The name of the targeted API entity. | `string` | `null` | no |
| <a name="input_location_path"></a> [location\_path](#input\_location\_path) | The URL path of the target. The default value is / for the root resource. | `string` | `null` | no |
| <a name="input_location_status_code"></a> [location\_status\_code](#input\_location\_status\_code) | The HTTP status code of a response. The default value is * for any status code. | `string` | `null` | no |
| <a name="input_location_type"></a> [location\_type](#input\_location\_type) | The type of API entity to which the documentation content appliesE.g., API, METHOD or REQUEST\_BODY | `string` | `null` | no |
| <a name="input_method_settings_method_path"></a> [method\_settings\_method\_path](#input\_method\_settings\_method\_path) | Method path defined as {resource\_path}/{http\_method} for an individual method override. | `string` | `null` | no |
| <a name="input_settings_cache_ttl_in_seconds"></a> [settings\_cache\_ttl\_in\_seconds](#input\_settings\_cache\_ttl\_in\_seconds) | Specifies the time to live (TTL), in seconds, for cached responses. The higher the TTL, the longer the response will be cached. | `number` | `null` | no |
| <a name="input_settings_caching_enabled"></a> [settings\_caching\_enabled](#input\_settings\_caching\_enabled) | Specifies whether responses should be cached and returned for requests.A cache cluster must be enabled on the stage for responses to be cached. | `bool` | `true` | no |
| <a name="input_settings_data_trace_enabled"></a> [settings\_data\_trace\_enabled](#input\_settings\_data\_trace\_enabled) | Specifies whether data trace logging is enabled for this method, which effects the log entries pushed to Amazon CloudWatch Logs. | `bool` | `false` | no |
| <a name="input_settings_logging_level"></a> [settings\_logging\_level](#input\_settings\_logging\_level) | Specifies the logging level for this method, which effects the log entries pushed to Amazon CloudWatch Logs. | `string` | `"INFO"` | no |
| <a name="input_settings_throttling_burst_limit"></a> [settings\_throttling\_burst\_limit](#input\_settings\_throttling\_burst\_limit) | Specifies the throttling burst limit. | `number` | `-1` | no |
| <a name="input_settings_throttling_rate_limit"></a> [settings\_throttling\_rate\_limit](#input\_settings\_throttling\_rate\_limit) | Specifies the throttling rate limit. | `number` | `-1` | no |
| <a name="input_stage_cache_cluster_enabled"></a> [stage\_cache\_cluster\_enabled](#input\_stage\_cache\_cluster\_enabled) | Specifies whether a cache cluster is enabled for the stage. | `bool` | `false` | no |
| <a name="input_stage_cache_cluster_size"></a> [stage\_cache\_cluster\_size](#input\_stage\_cache\_cluster\_size) | The size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237. | `number` | `null` | no |
| <a name="input_stage_client_certificate_id"></a> [stage\_client\_certificate\_id](#input\_stage\_client\_certificate\_id) | The identifier of a client certificate for the stage | `string` | `null` | no |
| <a name="input_stage_description"></a> [stage\_description](#input\_stage\_description) | The description of the stage. | `string` | `null` | no |
| <a name="input_stage_documentation_version"></a> [stage\_documentation\_version](#input\_stage\_documentation\_version) | The version of the associated API documentation. | `string` | `null` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | The name of the stage. | `string` | `null` | no |
| <a name="input_stage_variables"></a> [stage\_variables](#input\_stage\_variables) | A map that defines the stage variables. | `map(string)` | `null` | no |
| <a name="input_stage_xray_tracing_enabled"></a> [stage\_xray\_tracing\_enabled](#input\_stage\_xray\_tracing\_enabled) | Describes Whether active tracing with X-ray is enabled. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | n/a | yes |
| <a name="input_vpc_link_description"></a> [vpc\_link\_description](#input\_vpc\_link\_description) | The description of the VPC link. | `string` | `null` | no |
| <a name="input_vpc_link_name"></a> [vpc\_link\_name](#input\_vpc\_link\_name) | The name used to label and identify the VPC link. | `string` | `null` | no |
| <a name="input_vpc_link_target_arns"></a> [vpc\_link\_target\_arns](#input\_vpc\_link\_target\_arns) | The list of network load balancer arns in the VPC targeted by the VPC link. Currently AWS only supports 1 target. | `list(string)` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_account_throttle_settings"></a> [api\_gateway\_account\_throttle\_settings](#output\_api\_gateway\_account\_throttle\_settings) | Account-Level throttle settings. |
| <a name="output_api_gateway_client_certificate_arn"></a> [api\_gateway\_client\_certificate\_arn](#output\_api\_gateway\_client\_certificate\_arn) | The Amazon Resource Name (ARN) of the client certificate |
| <a name="output_api_gateway_client_certificate_created_date"></a> [api\_gateway\_client\_certificate\_created\_date](#output\_api\_gateway\_client\_certificate\_created\_date) | The date when the client certificate was created |
| <a name="output_api_gateway_client_certificate_expiration_date"></a> [api\_gateway\_client\_certificate\_expiration\_date](#output\_api\_gateway\_client\_certificate\_expiration\_date) | The date when the client certificate will expire. |
| <a name="output_api_gateway_client_certificate_id"></a> [api\_gateway\_client\_certificate\_id](#output\_api\_gateway\_client\_certificate\_id) | The identifier of the client certificate |
| <a name="output_api_gateway_client_certificate_pem_encoded_certificate"></a> [api\_gateway\_client\_certificate\_pem\_encoded\_certificate](#output\_api\_gateway\_client\_certificate\_pem\_encoded\_certificate) | The identifier of the client certificate |
| <a name="output_api_gateway_client_certificate_tags_all"></a> [api\_gateway\_client\_certificate\_tags\_all](#output\_api\_gateway\_client\_certificate\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_api_gateway_deployment_created_date"></a> [api\_gateway\_deployment\_created\_date](#output\_api\_gateway\_deployment\_created\_date) | The creation date of the deployment |
| <a name="output_api_gateway_deployment_id"></a> [api\_gateway\_deployment\_id](#output\_api\_gateway\_deployment\_id) | The ID for API Gateway Deployment |
| <a name="output_api_gateway_documentation_part_id"></a> [api\_gateway\_documentation\_part\_id](#output\_api\_gateway\_documentation\_part\_id) | The unique ID of the Documentation Part |
| <a name="output_api_gateway_stage_arn"></a> [api\_gateway\_stage\_arn](#output\_api\_gateway\_stage\_arn) | The Amazon Resource Name (ARN) for API Gateway Stage |
| <a name="output_api_gateway_stage_execution_arn"></a> [api\_gateway\_stage\_execution\_arn](#output\_api\_gateway\_stage\_execution\_arn) | The execution ARN to be used in lambda\_permission's source\_arn when allowing API Gateway to invoke a Lambda function |
| <a name="output_api_gateway_stage_id"></a> [api\_gateway\_stage\_id](#output\_api\_gateway\_stage\_id) | The ID for API Gateway Stage |
| <a name="output_api_gateway_stage_invoke_url"></a> [api\_gateway\_stage\_invoke\_url](#output\_api\_gateway\_stage\_invoke\_url) | The URL to invoke the API pointing to the stage |
| <a name="output_api_gateway_stage_name"></a> [api\_gateway\_stage\_name](#output\_api\_gateway\_stage\_name) | The Amazon Resource Name (ARN) for API Gateway Stage |
| <a name="output_api_gateway_stage_tags_all"></a> [api\_gateway\_stage\_tags\_all](#output\_api\_gateway\_stage\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_api_gateway_stage_web_acl_arn"></a> [api\_gateway\_stage\_web\_acl\_arn](#output\_api\_gateway\_stage\_web\_acl\_arn) | The ARN of the WebAcl associated with the Stage |
| <a name="output_api_gateway_vpc_link_id"></a> [api\_gateway\_vpc\_link\_id](#output\_api\_gateway\_vpc\_link\_id) | The identifier of the VpcLink |
| <a name="output_api_gateway_vpc_link_tags_all"></a> [api\_gateway\_vpc\_link\_tags\_all](#output\_api\_gateway\_vpc\_link\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_aws_api_gateway_deployment_all"></a> [aws\_api\_gateway\_deployment\_all](#output\_aws\_api\_gateway\_deployment\_all) | A map of all attributes |

<!-- END_TF_DOCS -->