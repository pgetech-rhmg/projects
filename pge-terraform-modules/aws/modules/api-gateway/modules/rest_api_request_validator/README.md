<!-- BEGIN_TF_DOCS -->
# AWS API Gateway Request Validator
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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_request_validator.api_gateway_request_validator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_request_validator) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_request_validator_name"></a> [request\_validator\_name](#input\_request\_validator\_name) | The name of the request validator. | `string` | n/a | yes |
| <a name="input_request_validator_validate_request_body"></a> [request\_validator\_validate\_request\_body](#input\_request\_validator\_validate\_request\_body) | Boolean whether to validate request body. Defaults to false | `bool` | `false` | no |
| <a name="input_request_validator_validate_request_parameters"></a> [request\_validator\_validate\_request\_parameters](#input\_request\_validator\_validate\_request\_parameters) | Boolean whether to validate request parameters. Defaults to false | `bool` | `false` | no |
| <a name="input_rest_api_id"></a> [rest\_api\_id](#input\_rest\_api\_id) | The ID of the associated REST API | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_request_validator_id"></a> [api\_gateway\_request\_validator\_id](#output\_api\_gateway\_request\_validator\_id) | The unique ID of the request validator |

<!-- END_TF_DOCS -->