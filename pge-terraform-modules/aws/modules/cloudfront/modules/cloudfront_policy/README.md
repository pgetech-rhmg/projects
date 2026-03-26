<!-- BEGIN_TF_DOCS -->
# AWS CloudFront Policy module
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
| [aws_cloudfront_cache_policy.cf_cache_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_origin_request_policy.cf_origin_request_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
| [aws_cloudfront_response_headers_policy.cf__response_headers_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cache_policy"></a> [cache\_policy](#input\_cache\_policy) | A list of string to provide values for the resource cache policy | `any` | `[]` | no |
| <a name="input_origin_request_policy"></a> [origin\_request\_policy](#input\_origin\_request\_policy) | A list of string to provide values for the resource request policy. | `any` | `[]` | no |
| <a name="input_response_headers_policy"></a> [response\_headers\_policy](#input\_response\_headers\_policy) | A list of string to provide values for the resource response headers policy | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cache_policy_etag"></a> [cache\_policy\_etag](#output\_cache\_policy\_etag) | The current version of the cache policy. |
| <a name="output_cache_policy_id"></a> [cache\_policy\_id](#output\_cache\_policy\_id) | The identifier for the cache policy. |
| <a name="output_origin_request_policy_etag"></a> [origin\_request\_policy\_etag](#output\_origin\_request\_policy\_etag) | The current version of the origin request policy. |
| <a name="output_origin_request_policy_id"></a> [origin\_request\_policy\_id](#output\_origin\_request\_policy\_id) | The identifier for the origin request policy. |
| <a name="output_response_headers_policy_etag"></a> [response\_headers\_policy\_etag](#output\_response\_headers\_policy\_etag) | The current version of the response headers policy. |
| <a name="output_response_headers_policy_id"></a> [response\_headers\_policy\_id](#output\_response\_headers\_policy\_id) | The identifier for the response headers policy. |


<!-- END_TF_DOCS -->