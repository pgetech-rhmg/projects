<!-- BEGIN_TF_DOCS -->
# AWS CloudFront Orgin access identity module
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
| [aws_cloudfront_origin_access_identity.cf_origin_access_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_comment_cf_oai"></a> [comment\_cf\_oai](#input\_comment\_cf\_oai) | Comment for origin access identity | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_origin_access_identity_all"></a> [origin\_access\_identity\_all](#output\_origin\_access\_identity\_all) | Map of all origin\_access\_identity attributes |
| <a name="output_origin_access_identity_caller_reference"></a> [origin\_access\_identity\_caller\_reference](#output\_origin\_access\_identity\_caller\_reference) | Internal value used by CloudFront to allow future updates to the origin access identity. |
| <a name="output_origin_access_identity_cloudfront_access_identity_path"></a> [origin\_access\_identity\_cloudfront\_access\_identity\_path](#output\_origin\_access\_identity\_cloudfront\_access\_identity\_path) | A shortcut to the full path for the origin access identity to use in CloudFront. |
| <a name="output_origin_access_identity_etag"></a> [origin\_access\_identity\_etag](#output\_origin\_access\_identity\_etag) | The current version of the origin access identity's information. |
| <a name="output_origin_access_identity_iam_arn"></a> [origin\_access\_identity\_iam\_arn](#output\_origin\_access\_identity\_iam\_arn) | A pre-generated ARN for use in S3 bucket policies. |
| <a name="output_origin_access_identity_id"></a> [origin\_access\_identity\_id](#output\_origin\_access\_identity\_id) | The identifier for the distribution. |
| <a name="output_origin_access_identity_s3_canonical_user_id"></a> [origin\_access\_identity\_s3\_canonical\_user\_id](#output\_origin\_access\_identity\_s3\_canonical\_user\_id) | The Amazon S3 canonical user ID for the origin access identity, which you use when giving the origin access identity read permission to an object in Amazon S3. |


<!-- END_TF_DOCS -->