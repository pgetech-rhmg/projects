<!-- BEGIN_TF_DOCS -->
# AWS API Gateway Rest Api module
Terraform module which creates SAF2.0 API Gateway Rest Api in AWS

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
| [aws_api_gateway_client_certificate.api_gateway_client_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_client_certificate) | resource |
| [aws_api_gateway_documentation_part.api_gateway_documentation_part](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_documentation_part) | resource |
| [aws_api_gateway_documentation_version.api_gateway_documentation_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_documentation_version) | resource |
| [aws_api_gateway_gateway_response.api_gateway_gateway_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_gateway_response) | resource |
| [aws_api_gateway_model.api_gateway_model](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_model) | resource |
| [aws_api_gateway_rest_api.api_gateway_rest_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_vpc_link.api_gateway_vpc_link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_vpc_link) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_cloudwatch_role_arn"></a> [account\_cloudwatch\_role\_arn](#input\_account\_cloudwatch\_role\_arn) | The ARN of an IAM role for CloudWatch (to allow logging & monitoring). | `string` | `null` | no |
| <a name="input_api_gateway_account_create"></a> [api\_gateway\_account\_create](#input\_api\_gateway\_account\_create) | Whether to create API Gateway gateway response. | `bool` | `false` | no |
| <a name="input_api_gateway_client_certificate_create"></a> [api\_gateway\_client\_certificate\_create](#input\_api\_gateway\_client\_certificate\_create) | Whether to create API Gateway Client Certificate. | `bool` | `false` | no |
| <a name="input_client_certificate_description"></a> [client\_certificate\_description](#input\_client\_certificate\_description) | The description of the client certificate. | `string` | `null` | no |
| <a name="input_documentation_description"></a> [documentation\_description](#input\_documentation\_description) | The description of the API documentation version. | `string` | `null` | no |
| <a name="input_documentation_part_properties"></a> [documentation\_part\_properties](#input\_documentation\_part\_properties) | A content map of API specific keyvalue pairs describing the targeted API entity. The map must be encoded as a JSON string. Only Swaggercompliant keyvalue pairs can be exported and, hence, published. | `string` | `null` | no |
| <a name="input_documentation_version"></a> [documentation\_version](#input\_documentation\_version) | The version identifier of the API documentation snapshot. | `string` | `null` | no |
| <a name="input_endpoint_configuration_types"></a> [endpoint\_configuration\_types](#input\_endpoint\_configuration\_types) | A list of endpoint types | `string` | `"PRIVATE"` | no |
| <a name="input_endpoint_configuration_vpc_endpoint_ids"></a> [endpoint\_configuration\_vpc\_endpoint\_ids](#input\_endpoint\_configuration\_vpc\_endpoint\_ids) | Set of VPC Endpoint identifiers | `list(string)` | `null` | no |
| <a name="input_gateway_response_parameters"></a> [gateway\_response\_parameters](#input\_gateway\_response\_parameters) | A map specifying the templates used to transform the response body. | `map(string)` | `null` | no |
| <a name="input_gateway_response_templates"></a> [gateway\_response\_templates](#input\_gateway\_response\_templates) | A map specifying the parameters (paths, query strings and headers) of the Gateway Response. | `map(string)` | `null` | no |
| <a name="input_gateway_response_type"></a> [gateway\_response\_type](#input\_gateway\_response\_type) | The response type of the associated GatewayResponse. | `string` | `null` | no |
| <a name="input_gateway_status_code"></a> [gateway\_status\_code](#input\_gateway\_status\_code) | The HTTP status code of the Gateway Response. | `string` | `null` | no |
| <a name="input_location_method"></a> [location\_method](#input\_location\_method) | The HTTP verb of a method. The default value is * for any method. | `string` | `null` | no |
| <a name="input_location_name"></a> [location\_name](#input\_location\_name) | The name of the targeted API entity. | `string` | `null` | no |
| <a name="input_location_path"></a> [location\_path](#input\_location\_path) | The URL path of the target. The default value is / for the root resource. | `string` | `null` | no |
| <a name="input_location_status_code"></a> [location\_status\_code](#input\_location\_status\_code) | The HTTP status code of a response. The default value is * for any status code. | `string` | `null` | no |
| <a name="input_location_type"></a> [location\_type](#input\_location\_type) | The type of API entity to which the documentation content appliesE.g., API, METHOD or REQUEST\_BODY | `string` | `null` | no |
| <a name="input_model_content_type"></a> [model\_content\_type](#input\_model\_content\_type) | The content type of the model. | `string` | `null` | no |
| <a name="input_model_description"></a> [model\_description](#input\_model\_description) | The description of the model. | `string` | `null` | no |
| <a name="input_model_name"></a> [model\_name](#input\_model\_name) | The name of the model. | `string` | `null` | no |
| <a name="input_model_schema"></a> [model\_schema](#input\_model\_schema) | The schema of the model in a JSON form. | `string` | `null` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | The JSON formatted policy document that controls access to the API Gateway | `string` | `"{}"` | no |
| <a name="input_rest_api_api_key_source"></a> [rest\_api\_api\_key\_source](#input\_rest\_api\_api\_key\_source) | The Source of the API key for requests | `string` | `"HEADER"` | no |
| <a name="input_rest_api_binary_media_types"></a> [rest\_api\_binary\_media\_types](#input\_rest\_api\_binary\_media\_types) | The list of binary media types supported by the RestApi. By default, the RestApi supports only UTF-8-encoded text payloads. | `list(any)` | `null` | no |
| <a name="input_rest_api_description"></a> [rest\_api\_description](#input\_rest\_api\_description) | The Description of the REST API | `string` | `null` | no |
| <a name="input_rest_api_disable_execute_api_endpoint"></a> [rest\_api\_disable\_execute\_api\_endpoint](#input\_rest\_api\_disable\_execute\_api\_endpoint) | Specifies whether clients can invoke your API by using the default execute-api endpoint | `string` | `false` | no |
| <a name="input_rest_api_minimum_compression_size"></a> [rest\_api\_minimum\_compression\_size](#input\_rest\_api\_minimum\_compression\_size) | The Minimum response size to compress for the REST API | `number` | `-1` | no |
| <a name="input_rest_api_name"></a> [rest\_api\_name](#input\_rest\_api\_name) | The Name of the REST API | `string` | n/a | yes |
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
| <a name="output_api_gateway_documentation_part_id"></a> [api\_gateway\_documentation\_part\_id](#output\_api\_gateway\_documentation\_part\_id) | The unique ID of the Documentation Part |
| <a name="output_api_gateway_model_id"></a> [api\_gateway\_model\_id](#output\_api\_gateway\_model\_id) | The ID of the model |
| <a name="output_api_gateway_rest_api_arn"></a> [api\_gateway\_rest\_api\_arn](#output\_api\_gateway\_rest\_api\_arn) | The Amazon Resource Name for API Gateway REST API |
| <a name="output_api_gateway_rest_api_created_date"></a> [api\_gateway\_rest\_api\_created\_date](#output\_api\_gateway\_rest\_api\_created\_date) | The creation date of the REST API |
| <a name="output_api_gateway_rest_api_execution_arn"></a> [api\_gateway\_rest\_api\_execution\_arn](#output\_api\_gateway\_rest\_api\_execution\_arn) | The execution arn part to be used in source arn when allowing API Gateway to invoke Lambda Function |
| <a name="output_api_gateway_rest_api_id"></a> [api\_gateway\_rest\_api\_id](#output\_api\_gateway\_rest\_api\_id) | The ID of the REST API |
| <a name="output_api_gateway_rest_api_root_resource_id"></a> [api\_gateway\_rest\_api\_root\_resource\_id](#output\_api\_gateway\_rest\_api\_root\_resource\_id) | The Resource ID of the REST API's root |
| <a name="output_api_gateway_rest_api_tags_all"></a> [api\_gateway\_rest\_api\_tags\_all](#output\_api\_gateway\_rest\_api\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |
| <a name="output_api_gateway_vpc_link_id"></a> [api\_gateway\_vpc\_link\_id](#output\_api\_gateway\_vpc\_link\_id) | The identifier of the VpcLink |
| <a name="output_api_gateway_vpc_link_tags_all"></a> [api\_gateway\_vpc\_link\_tags\_all](#output\_api\_gateway\_vpc\_link\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_aws_api_gateway_rest_api_all"></a> [aws\_api\_gateway\_rest\_api\_all](#output\_aws\_api\_gateway\_rest\_api\_all) | A map of all attributes |

<!-- END_TF_DOCS -->