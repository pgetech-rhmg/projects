<!-- BEGIN_TF_DOCS -->
# AWS CloudFront origin access control module
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
| [aws_cloudfront_origin_access_control.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudfront_oac_description"></a> [cloudfront\_oac\_description](#input\_cloudfront\_oac\_description) | The description of the Origin Access Control. | `string` | `"Managed by Terraform"` | no |
| <a name="input_cloudfront_oac_name"></a> [cloudfront\_oac\_name](#input\_cloudfront\_oac\_name) | A name that identifies the Origin Access Control. | `string` | n/a | yes |
| <a name="input_cloudfront_oac_origin_type"></a> [cloudfront\_oac\_origin\_type](#input\_cloudfront\_oac\_origin\_type) | The type of origin for this Origin Access Control. Valid values: lambda, mediapackagev2, mediastore, s3. | `string` | `"s3"` | no |
| <a name="input_cloudfront_oac_signing_behavior"></a> [cloudfront\_oac\_signing\_behavior](#input\_cloudfront\_oac\_signing\_behavior) | Specifies which requests CloudFront signs. Allowed values: always, never, no-override. | `string` | `"always"` | no |
| <a name="input_cloudfront_oac_signing_protocol"></a> [cloudfront\_oac\_signing\_protocol](#input\_cloudfront\_oac\_signing\_protocol) | Determines how CloudFront signs requests. The only valid value is sigv4. | `string` | `"sigv4"` | no |
| <a name="input_function_association"></a> [function\_association](#input\_function\_association) | A config block that triggers a cloudfront function with specific actions | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_origin_access_control_all"></a> [cloudfront\_origin\_access\_control\_all](#output\_cloudfront\_origin\_access\_control\_all) | Map of cloudfront origin access control resource. |
| <a name="output_cloudfront_origin_access_control_arn"></a> [cloudfront\_origin\_access\_control\_arn](#output\_cloudfront\_origin\_access\_control\_arn) | The ARN of the CloudFront origin access control. |
| <a name="output_cloudfront_origin_access_control_id"></a> [cloudfront\_origin\_access\_control\_id](#output\_cloudfront\_origin\_access\_control\_id) | The ID of the CloudFront origin access control. |
| <a name="output_cloudfront_origin_access_control_origin_type"></a> [cloudfront\_origin\_access\_control\_origin\_type](#output\_cloudfront\_origin\_access\_control\_origin\_type) | The origin type of the CloudFront origin access control. |
| <a name="output_cloudfront_origin_access_control_signing_behavior"></a> [cloudfront\_origin\_access\_control\_signing\_behavior](#output\_cloudfront\_origin\_access\_control\_signing\_behavior) | The signing behavior of the CloudFront origin access control. |
| <a name="output_cloudfront_origin_access_control_signing_protocol"></a> [cloudfront\_origin\_access\_control\_signing\_protocol](#output\_cloudfront\_origin\_access\_control\_signing\_protocol) | The signing protocol of the CloudFront origin access control. |


<!-- END_TF_DOCS -->