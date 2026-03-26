<!-- BEGIN_TF_DOCS -->
# AWS API Gateway Usage Plan
Terraform module which creates SAF2.0 API Gateway Usage Plan in AWS

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
| [aws_api_gateway_usage_plan.api_gateway_usage_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan) | resource |
| [aws_api_gateway_usage_plan_key.api_gateway_usage_plan_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_quota_settings"></a> [api\_quota\_settings](#input\_api\_quota\_settings) | The quota settings of the usage plan. | `any` | `[]` | no |
| <a name="input_api_stages"></a> [api\_stages](#input\_api\_stages) | The associated API stages of the usage plan. | `any` | `[]` | no |
| <a name="input_api_throttle_settings"></a> [api\_throttle\_settings](#input\_api\_throttle\_settings) | The throttling limits of the usage plan. | `any` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | n/a | yes |
| <a name="input_usage_plan_description"></a> [usage\_plan\_description](#input\_usage\_plan\_description) | The description of a usage plan. | `string` | `null` | no |
| <a name="input_usage_plan_key_id"></a> [usage\_plan\_key\_id](#input\_usage\_plan\_key\_id) | The identifier of the API key resource. | `string` | n/a | yes |
| <a name="input_usage_plan_key_type"></a> [usage\_plan\_key\_type](#input\_usage\_plan\_key\_type) | The type of the API key resource. Currently, the valid key type is API\_KEY. | `string` | `null` | no |
| <a name="input_usage_plan_name"></a> [usage\_plan\_name](#input\_usage\_plan\_name) | The name of the usage plan. | `string` | `null` | no |
| <a name="input_usage_plan_product_code"></a> [usage\_plan\_product\_code](#input\_usage\_plan\_product\_code) | The AWS Marketplace product identifier to associate with the usage plan as a SaaS product on AWS Marketplace. | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_usage_plan_all"></a> [api\_gateway\_usage\_plan\_all](#output\_api\_gateway\_usage\_plan\_all) | A map of all attributes |
| <a name="output_api_gateway_usage_plan_api_stages"></a> [api\_gateway\_usage\_plan\_api\_stages](#output\_api\_gateway\_usage\_plan\_api\_stages) | The associated API stages of the usage plan |
| <a name="output_api_gateway_usage_plan_arn"></a> [api\_gateway\_usage\_plan\_arn](#output\_api\_gateway\_usage\_plan\_arn) | The Amazon Resource Name (ARN) of usage\_plan version |
| <a name="output_api_gateway_usage_plan_description"></a> [api\_gateway\_usage\_plan\_description](#output\_api\_gateway\_usage\_plan\_description) | The description of a usage plan |
| <a name="output_api_gateway_usage_plan_id"></a> [api\_gateway\_usage\_plan\_id](#output\_api\_gateway\_usage\_plan\_id) | The ID of the API resource |
| <a name="output_api_gateway_usage_plan_key_id"></a> [api\_gateway\_usage\_plan\_key\_id](#output\_api\_gateway\_usage\_plan\_key\_id) | The Id of a usage plan key |
| <a name="output_api_gateway_usage_plan_key_key_id"></a> [api\_gateway\_usage\_plan\_key\_key\_id](#output\_api\_gateway\_usage\_plan\_key\_key\_id) | The identifier of the API gateway key resource |
| <a name="output_api_gateway_usage_plan_key_key_type"></a> [api\_gateway\_usage\_plan\_key\_key\_type](#output\_api\_gateway\_usage\_plan\_key\_key\_type) | The type of a usage plan key. Currently, the valid key type is API\_KEY |
| <a name="output_api_gateway_usage_plan_key_name"></a> [api\_gateway\_usage\_plan\_key\_name](#output\_api\_gateway\_usage\_plan\_key\_name) | The name of a usage plan key |
| <a name="output_api_gateway_usage_plan_key_usage_plan_id"></a> [api\_gateway\_usage\_plan\_key\_usage\_plan\_id](#output\_api\_gateway\_usage\_plan\_key\_usage\_plan\_id) | The ID of the API resource |
| <a name="output_api_gateway_usage_plan_key_value"></a> [api\_gateway\_usage\_plan\_key\_value](#output\_api\_gateway\_usage\_plan\_key\_value) | The value of a usage plan key |
| <a name="output_api_gateway_usage_plan_name"></a> [api\_gateway\_usage\_plan\_name](#output\_api\_gateway\_usage\_plan\_name) | The name of the usage plan |
| <a name="output_api_gateway_usage_plan_product_code"></a> [api\_gateway\_usage\_plan\_product\_code](#output\_api\_gateway\_usage\_plan\_product\_code) | The AWS Marketplace product identifier to associate with the usage plan as a SaaS product on AWS Marketplace |
| <a name="output_api_gateway_usage_plan_quota_settings"></a> [api\_gateway\_usage\_plan\_quota\_settings](#output\_api\_gateway\_usage\_plan\_quota\_settings) | The quota of the usage plan |
| <a name="output_api_gateway_usage_plan_tags_all"></a> [api\_gateway\_usage\_plan\_tags\_all](#output\_api\_gateway\_usage\_plan\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_api_gateway_usage_plan_throttle_settings"></a> [api\_gateway\_usage\_plan\_throttle\_settings](#output\_api\_gateway\_usage\_plan\_throttle\_settings) | The throttling limits of the usage plan |

<!-- END_TF_DOCS -->