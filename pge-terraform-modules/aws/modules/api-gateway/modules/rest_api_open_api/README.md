<!-- BEGIN_TF_DOCS -->
# AWS API Gateway module using OpenApi
Terraform module which creates SAF2.0 API Gateway using OpenApi approch in AWS

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
| [aws_api_gateway_rest_api.api_gateway_rest_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_endpoint_configuration_types"></a> [endpoint\_configuration\_types](#input\_endpoint\_configuration\_types) | A list of endpoint types | `string` | `"PRIVATE"` | no |
| <a name="input_endpoint_configuration_vpc_endpoint_ids"></a> [endpoint\_configuration\_vpc\_endpoint\_ids](#input\_endpoint\_configuration\_vpc\_endpoint\_ids) | Set of VPC Endpoint identifiers | `list(string)` | `null` | no |
| <a name="input_openapi_config"></a> [openapi\_config](#input\_openapi\_config) | The OpenAPI specification that defines the set of routes and integrations to create as part of the REST API | `any` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | The JSON formatted policy document that controls access to the API Gateway | `string` | `"{}"` | no |
| <a name="input_rest_api_name"></a> [rest\_api\_name](#input\_rest\_api\_name) | The Name of the REST API | `string` | n/a | yes |
| <a name="input_rest_api_parameters"></a> [rest\_api\_parameters](#input\_rest\_api\_parameters) | The Map of customizations for importing the specification in the body argument | `map(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_rest_api_arn"></a> [api\_gateway\_rest\_api\_arn](#output\_api\_gateway\_rest\_api\_arn) | The Amazon Resource Name for API Gateway REST API |
| <a name="output_api_gateway_rest_api_created_date"></a> [api\_gateway\_rest\_api\_created\_date](#output\_api\_gateway\_rest\_api\_created\_date) | The creation date of the REST API |
| <a name="output_api_gateway_rest_api_execution_arn"></a> [api\_gateway\_rest\_api\_execution\_arn](#output\_api\_gateway\_rest\_api\_execution\_arn) | The execution arn part to be used in source arn when allowing API Gateway to invoke Lambda Function |
| <a name="output_api_gateway_rest_api_id"></a> [api\_gateway\_rest\_api\_id](#output\_api\_gateway\_rest\_api\_id) | The ID of the REST API |
| <a name="output_api_gateway_rest_api_root_resource_id"></a> [api\_gateway\_rest\_api\_root\_resource\_id](#output\_api\_gateway\_rest\_api\_root\_resource\_id) | The Resource ID of the REST API's root |
| <a name="output_api_gateway_rest_api_tags_all"></a> [api\_gateway\_rest\_api\_tags\_all](#output\_api\_gateway\_rest\_api\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |
| <a name="output_aws_api_gateway_rest_api_all"></a> [aws\_api\_gateway\_rest\_api\_all](#output\_aws\_api\_gateway\_rest\_api\_all) | A map of all attributes |

<!-- END_TF_DOCS -->