<!-- BEGIN_TF_DOCS -->
# AWS CloudFront module Field level encryption configurations
Terraform module which creates SAF2.0 CloudFront in AWS

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
| [aws_cloudfront_field_level_encryption_config.cf_field_level_encryption_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_field_level_encryption_config) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cf_field_level_encryption_config"></a> [cf\_field\_level\_encryption\_config](#input\_cf\_field\_level\_encryption\_config) | A list of string to provide values for the resource field level encryption config. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_field_level_encryption_config_caller_reference"></a> [field\_level\_encryption\_config\_caller\_reference](#output\_field\_level\_encryption\_config\_caller\_reference) | Internal value used by CloudFront to allow future updates to the Field Level Encryption Config. |
| <a name="output_field_level_encryption_config_etag"></a> [field\_level\_encryption\_config\_etag](#output\_field\_level\_encryption\_config\_etag) | The current version of the Field Level Encryption Config. |
| <a name="output_field_level_encryption_config_id"></a> [field\_level\_encryption\_config\_id](#output\_field\_level\_encryption\_config\_id) | The identifier for the Field Level Encryption Config. |


<!-- END_TF_DOCS -->