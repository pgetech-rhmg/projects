<!-- BEGIN_TF_DOCS -->
# AWS Glue Security Configuration module.
Terraform module which creates SAF2.0 Glue Security Configuration in AWS.

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
| [aws_glue_security_configuration.glue_security_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_security_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_glue_cloudwatch_encryption_kms_key_arn"></a> [glue\_cloudwatch\_encryption\_kms\_key\_arn](#input\_glue\_cloudwatch\_encryption\_kms\_key\_arn) | Amazon Resource Name (ARN) of the KMS key to be used to encrypt the data for glue cloudwatch encryption. | `string` | n/a | yes |
| <a name="input_glue_job_bookmarks_encryption_kms_key_arn"></a> [glue\_job\_bookmarks\_encryption\_kms\_key\_arn](#input\_glue\_job\_bookmarks\_encryption\_kms\_key\_arn) | Amazon Resource Name (ARN) of the KMS key to be used to encrypt the data for glue job bookmarks encryption. | `string` | n/a | yes |
| <a name="input_glue_s3_encryption_kms_key_arn"></a> [glue\_s3\_encryption\_kms\_key\_arn](#input\_glue\_s3\_encryption\_kms\_key\_arn) | Amazon Resource Name (ARN) of the KMS key to be used to encrypt the data for glue s3 encryption. | `string` | n/a | yes |
| <a name="input_glue_security_configuration_name"></a> [glue\_security\_configuration\_name](#input\_glue\_security\_configuration\_name) | Name of the security configuration. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_security_configuration"></a> [aws\_glue\_security\_configuration](#output\_aws\_glue\_security\_configuration) | A map of aws\_glue\_security\_configuration object. |
| <a name="output_glue_security_configuration_id"></a> [glue\_security\_configuration\_id](#output\_glue\_security\_configuration\_id) | Glue security configuration name |


<!-- END_TF_DOCS -->