<!-- BEGIN_TF_DOCS -->
# AWS Opensearch package module
Terraform module which creates package for Opensearch

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
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
| [aws_opensearch_package.package](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_package) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_package_description"></a> [package\_description](#input\_package\_description) | Description of the package | `string` | `null` | no |
| <a name="input_package_name"></a> [package\_name](#input\_package\_name) | Unique name for the package | `string` | n/a | yes |
| <a name="input_package_type"></a> [package\_type](#input\_package\_type) | The type of package | `string` | `"TXT-DICTIONARY"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Specifies whether a welcome email is sent to a user after the user is created in the user pool. | `string` | n/a | yes |
| <a name="input_s3_key"></a> [s3\_key](#input\_s3\_key) | Key (file name) of the package | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_available_package_version"></a> [available\_package\_version](#output\_available\_package\_version) | The current version of the package. |
| <a name="output_aws_opensearch_package_all"></a> [aws\_opensearch\_package\_all](#output\_aws\_opensearch\_package\_all) | Map of all package attributes |
| <a name="output_package_id"></a> [package\_id](#output\_package\_id) | The Id of the package. |

<!-- END_TF_DOCS -->