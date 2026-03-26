<!-- BEGIN_TF_DOCS -->
# AWS Lambda layer version using Amazon S3
Terraform module which creates SAF2.0 Lambda layer version in AWS

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
| [aws_lambda_layer_version.layer_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |
| [aws_lambda_layer_version_permission.layer_version_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_layer_skip_destroy"></a> [layer\_skip\_destroy](#input\_layer\_skip\_destroy) | Whether to retain the old version of a previously deployed Lambda Layer. | `bool` | `false` | no |
| <a name="input_layer_version_compatible_architectures"></a> [layer\_version\_compatible\_architectures](#input\_layer\_version\_compatible\_architectures) | List of Architectures this layer is compatible with. Currently x86\_64 and arm64 can be specified | `string` | `null` | no |
| <a name="input_layer_version_compatible_runtimes"></a> [layer\_version\_compatible\_runtimes](#input\_layer\_version\_compatible\_runtimes) | A list of Runtimes this layer is compatible with. Up to 15 runtimes can be specified | `list(string)` | n/a | yes |
| <a name="input_layer_version_description"></a> [layer\_version\_description](#input\_layer\_version\_description) | Description of what your Lambda Layer does | `string` | `null` | no |
| <a name="input_layer_version_layer_name"></a> [layer\_version\_layer\_name](#input\_layer\_version\_layer\_name) | Unique name for your Lambda Layer | `string` | n/a | yes |
| <a name="input_layer_version_license_info"></a> [layer\_version\_license\_info](#input\_layer\_version\_license\_info) | License info for your Lambda Layer | `string` | `null` | no |
| <a name="input_layer_version_permission_action"></a> [layer\_version\_permission\_action](#input\_layer\_version\_permission\_action) | Action, which will be allowed. lambda:GetLayerVersion value is suggested by AWS documantation | `string` | `null` | no |
| <a name="input_layer_version_permission_principal"></a> [layer\_version\_permission\_principal](#input\_layer\_version\_permission\_principal) | AWS account ID which should be able to use your Lambda Layer. * can be used here, if you want to share your Lambda Layer widely | `string` | n/a | yes |
| <a name="input_layer_version_permission_statement_id"></a> [layer\_version\_permission\_statement\_id](#input\_layer\_version\_permission\_statement\_id) | The name of Lambda Layer Permission, for example dev-account - human readable note about what is this permission for | `string` | `null` | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | S3 bucket location containing the function's deployment package. Conflicts with filename and image\_uri. This bucket must reside in the same AWS region where you are creating the Lambda function | `string` | n/a | yes |
| <a name="input_s3_key"></a> [s3\_key](#input\_s3\_key) | S3 key of an object containing the function's deployment package. Conflicts with filename and image\_uri | `string` | n/a | yes |
| <a name="input_s3_object_version"></a> [s3\_object\_version](#input\_s3\_object\_version) | Object version containing the function's deployment package. Conflicts with filename and image\_uri | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_layer_all"></a> [lambda\_layer\_all](#output\_lambda\_layer\_all) | Map of all Lambda object |
| <a name="output_layer_version_arn"></a> [layer\_version\_arn](#output\_layer\_version\_arn) | ARN of the Lambda Layer with version |
| <a name="output_layer_version_created_date"></a> [layer\_version\_created\_date](#output\_layer\_version\_created\_date) | Date this resource was created |
| <a name="output_layer_version_layer_arn"></a> [layer\_version\_layer\_arn](#output\_layer\_version\_layer\_arn) | ARN of the Lambda Layer without version |
| <a name="output_layer_version_permission_id"></a> [layer\_version\_permission\_id](#output\_layer\_version\_permission\_id) | The layer\_name and version\_number, separated by a comma (,) |
| <a name="output_layer_version_permission_policy"></a> [layer\_version\_permission\_policy](#output\_layer\_version\_permission\_policy) | Full Lambda Layer Permission policy |
| <a name="output_layer_version_permission_revision_id"></a> [layer\_version\_permission\_revision\_id](#output\_layer\_version\_permission\_revision\_id) | A unique identifier for the current revision of the policy |
| <a name="output_layer_version_signing_job_arn"></a> [layer\_version\_signing\_job\_arn](#output\_layer\_version\_signing\_job\_arn) | ARN of a signing job |
| <a name="output_layer_version_signing_profile_version_arn"></a> [layer\_version\_signing\_profile\_version\_arn](#output\_layer\_version\_signing\_profile\_version\_arn) | ARN for a signing profile version |
| <a name="output_layer_version_source_code_size"></a> [layer\_version\_source\_code\_size](#output\_layer\_version\_source\_code\_size) | Size in bytes of the function .zip file |
| <a name="output_layer_version_version"></a> [layer\_version\_version](#output\_layer\_version\_version) | Lambda Layer version |

<!-- END_TF_DOCS -->