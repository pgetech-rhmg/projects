<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker module
# Terraform module which creates aws\_sagemaker\_notebook\_instance\_lifecycle\_configuration

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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_sagemaker_notebook_instance_lifecycle_configuration.lifecycle_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_notebook_instance_lifecycle_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the lifecycle configuration (must be unique). | `string` | n/a | yes |
| <a name="input_on_create"></a> [on\_create](#input\_on\_create) | A shell script (base64-encoded) that runs only once when the SageMaker Notebook Instance is created. | `string` | `null` | no |
| <a name="input_on_start"></a> [on\_start](#input\_on\_start) | A shell script (base64-encoded) that runs every time the SageMaker Notebook Instance is started including the time it's created. | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lifecycle_configuration_arn"></a> [lifecycle\_configuration\_arn](#output\_lifecycle\_configuration\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this lifecycle configuration. |
| <a name="output_sagemaker_notebook_instance_lifecycle_configuration_all"></a> [sagemaker\_notebook\_instance\_lifecycle\_configuration\_all](#output\_sagemaker\_notebook\_instance\_lifecycle\_configuration\_all) | A map of aws sagemaker notebook instance lifecycle configuration |

<!-- END_TF_DOCS -->