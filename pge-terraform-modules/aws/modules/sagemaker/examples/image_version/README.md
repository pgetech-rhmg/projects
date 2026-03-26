<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker image version example
# Terraform module example usage for Sagemaker image version

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

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
| <a name="module_sagemaker_image_version"></a> [sagemaker\_image\_version](#module\_sagemaker\_image\_version) | ../../modules/image_version | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_base_image"></a> [base\_image](#input\_base\_image) | The registry path of the container image on which this image version is based. | `string` | n/a | yes |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The name of the image. Must be unique to your account. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this Image Version. |
| <a name="output_container_image"></a> [container\_image](#output\_container\_image) | The registry path of the container image that contains this image version. |
| <a name="output_id"></a> [id](#output\_id) | The name of the Image. |
| <a name="output_image_arn"></a> [image\_arn](#output\_image\_arn) | The Amazon Resource Name (ARN) of the image the version is based on. |

<!-- END_TF_DOCS -->