<!-- BEGIN_TF_DOCS -->
# AWS sagemaker endpoint module
# Terraform module which creates Sagemaker endpoint

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.0 |

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
| [aws_sagemaker_endpoint.endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployment_config"></a> [deployment\_config](#input\_deployment\_config) | The deployment configuration for an endpoint, which contains the desired deployment strategy and rollback configurations. | `list(any)` | `[]` | no |
| <a name="input_endpoint_config_name"></a> [endpoint\_config\_name](#input\_endpoint\_config\_name) | The name of the endpoint configuration to use. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the endpoint. If omitted, Terraform will assign a random, unique name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_arn"></a> [endpoint\_arn](#output\_endpoint\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this endpoint. |
| <a name="output_endpoint_name"></a> [endpoint\_name](#output\_endpoint\_name) | The name of the endpoint. |
| <a name="output_sagemaker_endpoint_all"></a> [sagemaker\_endpoint\_all](#output\_sagemaker\_endpoint\_all) | A map of aws sagemaker endpoint |

<!-- END_TF_DOCS -->