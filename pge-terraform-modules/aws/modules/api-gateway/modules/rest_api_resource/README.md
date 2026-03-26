<!-- BEGIN_TF_DOCS -->
# AWS API Gateway Resource
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
| [aws_api_gateway_resource.api_gateway_resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_gateway_parent_id"></a> [api\_gateway\_parent\_id](#input\_api\_gateway\_parent\_id) | The ID of the parent API resource | `string` | n/a | yes |
| <a name="input_api_gateway_path_part"></a> [api\_gateway\_path\_part](#input\_api\_gateway\_path\_part) | The last path segment of this API resource | `string` | n/a | yes |
| <a name="input_api_gateway_rest_api_id"></a> [api\_gateway\_rest\_api\_id](#input\_api\_gateway\_rest\_api\_id) | The ID of the associated REST API | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_resource_id"></a> [api\_gateway\_resource\_id](#output\_api\_gateway\_resource\_id) | The ID of the API Gateway Resource |
| <a name="output_api_gateway_resource_path"></a> [api\_gateway\_resource\_path](#output\_api\_gateway\_resource\_path) | The path for API Gateway Resource with including all parent paths |

<!-- END_TF_DOCS -->