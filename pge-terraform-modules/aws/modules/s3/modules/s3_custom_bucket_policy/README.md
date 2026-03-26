<!-- BEGIN_TF_DOCS -->
# AWS S3 module
Terraform module which creates SAF2.0 S3 static website resource in AWS

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
| [aws_s3_bucket_policy.s3web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_iam_policy_document.cloudfront_s3_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_id"></a> [bucket\_id](#input\_bucket\_id) | The ID of the S3 bucket to which the policy will be applied. | `string` | `null` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | S3 bucket name. A unique identifier. | `string` | `null` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | The user-defined policy to be combined with the compliance policy. | `any` | `{}` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_s3_bucket_policy_all"></a> [aws\_s3\_bucket\_policy\_all](#output\_aws\_s3\_bucket\_policy\_all) | Map of all attributes of s3\_bucket\_policy\_all |

<!-- END_TF_DOCS -->