<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker module
# Terraform module which creates image\_version

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
| [aws_sagemaker_image_version.image_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_image_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_image"></a> [base\_image](#input\_base\_image) | The registry path of the container image on which this image version is based. | `string` | n/a | yes |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The name of the image. Must be unique to your account. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_image_version_arn"></a> [image\_version\_arn](#output\_image\_version\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this Image Version. |
| <a name="output_image_version_container_image"></a> [image\_version\_container\_image](#output\_image\_version\_container\_image) | The registry path of the container image that contains this image version. |
| <a name="output_image_version_id"></a> [image\_version\_id](#output\_image\_version\_id) | The name of the Image. |
| <a name="output_image_version_image_arn"></a> [image\_version\_image\_arn](#output\_image\_version\_image\_arn) | The Amazon Resource Name (ARN) of the image the version is based on. |
| <a name="output_sagemaker_image_version_all"></a> [sagemaker\_image\_version\_all](#output\_sagemaker\_image\_version\_all) | A map of aws sagemaker image version |

<!-- END_TF_DOCS -->