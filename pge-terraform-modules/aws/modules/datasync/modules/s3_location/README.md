<!-- BEGIN_TF_DOCS -->
# AWS DataSync module
Terraform module which creates SAF2.0 DataSync s3 location resources in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 1.0 |

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
| [aws_datasync_location_s3.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_s3) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_s3_datasync_access_role"></a> [s3\_datasync\_access\_role](#input\_s3\_datasync\_access\_role) | The ARN of the IAM role used to access the S3 bucket by DataSync | `string` | n/a | yes |
| <a name="input_s3_location_arn"></a> [s3\_location\_arn](#input\_s3\_location\_arn) | The ARN of the S3 bucket | `string` | n/a | yes |
| <a name="input_s3_location_subdirectory"></a> [s3\_location\_subdirectory](#input\_s3\_location\_subdirectory) | The subdirectory in the S3 bucket | `string` | n/a | yes |
| <a name="input_s3_storage_class"></a> [s3\_storage\_class](#input\_s3\_storage\_class) | The storage class of the S3 bucket | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the source S3 location |
| <a name="output_id"></a> [id](#output\_id) | The ID of the source S3 location |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the source S3 location |


<!-- END_TF_DOCS -->