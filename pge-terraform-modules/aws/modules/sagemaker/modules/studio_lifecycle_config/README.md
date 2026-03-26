<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker module
# Terraform module which creates studio\_lifecycle\_config

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
| [aws_sagemaker_studio_lifecycle_config.studio_lifecycle_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_studio_lifecycle_config) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_studio_lifecycle_config_app_type"></a> [studio\_lifecycle\_config\_app\_type](#input\_studio\_lifecycle\_config\_app\_type) | The App type that the Lifecycle Configuration is attached to. Valid values are JupyterServer and KernelGateway. | `string` | n/a | yes |
| <a name="input_studio_lifecycle_config_content"></a> [studio\_lifecycle\_config\_content](#input\_studio\_lifecycle\_config\_content) | The content of your Studio Lifecycle Configuration script. This content must be base64 encoded. | `string` | n/a | yes |
| <a name="input_studio_lifecycle_config_name"></a> [studio\_lifecycle\_config\_name](#input\_studio\_lifecycle\_config\_name) | The name of the Studio Lifecycle Configuration to create. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sagemaker_studio_lifecycle_config_all"></a> [sagemaker\_studio\_lifecycle\_config\_all](#output\_sagemaker\_studio\_lifecycle\_config\_all) | A map of aws sagemaker studio lifecycle config |
| <a name="output_studio_lifecycle_config_arn"></a> [studio\_lifecycle\_config\_arn](#output\_studio\_lifecycle\_config\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this Studio Lifecycle Config. |
| <a name="output_studio_lifecycle_config_id"></a> [studio\_lifecycle\_config\_id](#output\_studio\_lifecycle\_config\_id) | The name of the Studio Lifecycle Config. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->