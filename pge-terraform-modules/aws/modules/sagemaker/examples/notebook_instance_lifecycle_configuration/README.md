<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker notebook instance lifecycle configuration example
# Terraform module example usage for Sagemaker notebook instance lifecycle configuration

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

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
| <a name="module_lifecycle_configuration"></a> [lifecycle\_configuration](#module\_lifecycle\_configuration) | ../../modules/notebook_instance_lifecycle_configuration | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the lifecycle configuration (must be unique). | `string` | n/a | yes |
| <a name="input_on_create"></a> [on\_create](#input\_on\_create) | A shell script (base64-encoded) that runs only once when the SageMaker Notebook Instance is created. | `string` | n/a | yes |
| <a name="input_on_start"></a> [on\_start](#input\_on\_start) | A shell script (base64-encoded) that runs every time the SageMaker Notebook Instance is started including the time it's created. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lifecycle_configuration_arn"></a> [lifecycle\_configuration\_arn](#output\_lifecycle\_configuration\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this lifecycle configuration. |

<!-- END_TF_DOCS -->