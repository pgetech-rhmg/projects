<!-- BEGIN_TF_DOCS -->
# AWS CloudFront Field level encryption profile module
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
| [aws_cloudfront_field_level_encryption_profile.cf_field_level_encryption_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_field_level_encryption_profile) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cf_field_level_encryption_profile"></a> [cf\_field\_level\_encryption\_profile](#input\_cf\_field\_level\_encryption\_profile) | A list of string to provide values for the resource field level encryption profile | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_field_level_encryption_profile_caller_reference"></a> [field\_level\_encryption\_profile\_caller\_reference](#output\_field\_level\_encryption\_profile\_caller\_reference) | Internal value used by CloudFront to allow future updates to the Field Level Encryption Profile. |
| <a name="output_field_level_encryption_profile_etag"></a> [field\_level\_encryption\_profile\_etag](#output\_field\_level\_encryption\_profile\_etag) | The current version of the Field Level Encryption Profile. |
| <a name="output_field_level_encryption_profile_id"></a> [field\_level\_encryption\_profile\_id](#output\_field\_level\_encryption\_profile\_id) | The identifier for the Field Level Encryption Profile. |


<!-- END_TF_DOCS -->