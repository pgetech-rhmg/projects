<!-- BEGIN_TF_DOCS -->
# AWS API Gateway Rest api user module using OpenApi example
Terraform module which creates SAF2.0 API Gateway using OpenApi in AWS

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
| <a name="module_api_gateway_deployment_and_stage"></a> [api\_gateway\_deployment\_and\_stage](#module\_api\_gateway\_deployment\_and\_stage) | ../../modules/open_api_deployment_and_stage | n/a |
| <a name="module_api_gateway_key"></a> [api\_gateway\_key](#module\_api\_gateway\_key) | ../../ | n/a |
| <a name="module_api_gateway_rest_api"></a> [api\_gateway\_rest\_api](#module\_api\_gateway\_rest\_api) | ../../modules/rest_api_open_api | n/a |
| <a name="module_api_gateway_usage_plan"></a> [api\_gateway\_usage\_plan](#module\_api\_gateway\_usage\_plan) | ../../modules/api_usage_plan | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.api_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

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
| <a name="input_api_key_name"></a> [api\_key\_name](#input\_api\_key\_name) | The name of the API key. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_method_settings_method_path"></a> [method\_settings\_method\_path](#input\_method\_settings\_method\_path) | Method path defined as {resource\_path}/{http\_method} for an individual method override. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_pVpcEndpoint"></a> [pVpcEndpoint](#input\_pVpcEndpoint) | Vpc-endpoint for the resource policy | `string` | n/a | yes |
| <a name="input_rest_api_name"></a> [rest\_api\_name](#input\_rest\_api\_name) | Name of the REST API. | `string` | n/a | yes |
| <a name="input_settings_logging_level"></a> [settings\_logging\_level](#input\_settings\_logging\_level) | Specifies the logging level for this method, which effects the log entries pushed to Amazon CloudWatch Logs. | `string` | n/a | yes |
| <a name="input_stage_cache_cluster_enabled"></a> [stage\_cache\_cluster\_enabled](#input\_stage\_cache\_cluster\_enabled) | Specifies whether a cache cluster is enabled for the stage. | `bool` | n/a | yes |
| <a name="input_stage_cache_cluster_size"></a> [stage\_cache\_cluster\_size](#input\_stage\_cache\_cluster\_size) | The size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237. | `number` | n/a | yes |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | The name of the stage | `string` | n/a | yes |
| <a name="input_usage_plan_description"></a> [usage\_plan\_description](#input\_usage\_plan\_description) | The description of a usage plan. | `string` | n/a | yes |
| <a name="input_usage_plan_key_type"></a> [usage\_plan\_key\_type](#input\_usage\_plan\_key\_type) | The type of the API key resource. Currently, the valid key type is API\_KEY. | `string` | n/a | yes |
| <a name="input_usage_plan_name"></a> [usage\_plan\_name](#input\_usage\_plan\_name) | The name of the usage plan. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_deployment_created_date"></a> [api\_gateway\_deployment\_created\_date](#output\_api\_gateway\_deployment\_created\_date) | The creation date of the deployment |
| <a name="output_api_gateway_deployment_id"></a> [api\_gateway\_deployment\_id](#output\_api\_gateway\_deployment\_id) | The ID for API Gateway Deployment |
| <a name="output_api_gateway_rest_api_arn"></a> [api\_gateway\_rest\_api\_arn](#output\_api\_gateway\_rest\_api\_arn) | The Amazon Resource Name for API Gateway REST API |
| <a name="output_api_gateway_rest_api_created_date"></a> [api\_gateway\_rest\_api\_created\_date](#output\_api\_gateway\_rest\_api\_created\_date) | The creation date of the REST API |
| <a name="output_api_gateway_rest_api_execution_arn"></a> [api\_gateway\_rest\_api\_execution\_arn](#output\_api\_gateway\_rest\_api\_execution\_arn) | The execution arn part to be used in source arn when allowing API Gateway to invoke Lambda Function |
| <a name="output_api_gateway_rest_api_id"></a> [api\_gateway\_rest\_api\_id](#output\_api\_gateway\_rest\_api\_id) | The ID of the REST API |
| <a name="output_api_gateway_rest_api_root_resource_id"></a> [api\_gateway\_rest\_api\_root\_resource\_id](#output\_api\_gateway\_rest\_api\_root\_resource\_id) | The Resource ID of the REST API's root |
| <a name="output_api_gateway_rest_api_tags_all"></a> [api\_gateway\_rest\_api\_tags\_all](#output\_api\_gateway\_rest\_api\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |
| <a name="output_api_gateway_stage_arn"></a> [api\_gateway\_stage\_arn](#output\_api\_gateway\_stage\_arn) | The Amazon Resource Name (ARN) for API Gateway Stage |
| <a name="output_api_gateway_stage_execution_arn"></a> [api\_gateway\_stage\_execution\_arn](#output\_api\_gateway\_stage\_execution\_arn) | The execution ARN to be used in lambda\_permission's source\_arn when allowing API Gateway to invoke a Lambda function |
| <a name="output_api_gateway_stage_id"></a> [api\_gateway\_stage\_id](#output\_api\_gateway\_stage\_id) | The ID for API Gateway Stage |
| <a name="output_api_gateway_stage_invoke_url"></a> [api\_gateway\_stage\_invoke\_url](#output\_api\_gateway\_stage\_invoke\_url) | The URL to invoke the API pointing to the stage |
| <a name="output_api_gateway_stage_tags_all"></a> [api\_gateway\_stage\_tags\_all](#output\_api\_gateway\_stage\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_api_gateway_stage_web_acl_arn"></a> [api\_gateway\_stage\_web\_acl\_arn](#output\_api\_gateway\_stage\_web\_acl\_arn) | The ARN of the WebAcl associated with the Stage |

<!-- END_TF_DOCS -->