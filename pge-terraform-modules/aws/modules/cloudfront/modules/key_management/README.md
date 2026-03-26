<!-- BEGIN_TF_DOCS -->
# AWS CloudFront Key management module
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
| [aws_cloudfront_key_group.cf_key_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_key_group) | resource |
| [aws_cloudfront_public_key.cf_public_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_public_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cf_key_group"></a> [cf\_key\_group](#input\_cf\_key\_group) | A list of string to provide values for the resource key group. | `any` | `[]` | no |
| <a name="input_cf_public_key"></a> [cf\_public\_key](#input\_cf\_public\_key) | A list of string to provide values for the resource public key. | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_group_etag"></a> [key\_group\_etag](#output\_key\_group\_etag) | The identifier for this version of the key group. |
| <a name="output_key_group_id"></a> [key\_group\_id](#output\_key\_group\_id) | The identifier for the key group. |
| <a name="output_public_key_caller_reference"></a> [public\_key\_caller\_reference](#output\_public\_key\_caller\_reference) | Internal value used by CloudFront to allow future updates to the public key configuration. |
| <a name="output_public_key_etag"></a> [public\_key\_etag](#output\_public\_key\_etag) | The current version of the public key. |
| <a name="output_public_key_id"></a> [public\_key\_id](#output\_public\_key\_id) | The current version of the public key. |


<!-- END_TF_DOCS -->