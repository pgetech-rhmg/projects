<!-- BEGIN_TF_DOCS -->
# AWS Lambda layer version with S3 Bucket User module example

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
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Usage

Usage information can be found in `modules/examples/*`

`cd pge-terraform-modules/modules/examples/*`

`terraform init`

`terraform validate`

`terraform plan`

`terraform apply`

Run `terraform destroy` when you don't need these resources.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_layer_version"></a> [lambda\_layer\_version](#module\_lambda\_layer\_version) | ../../modules/lambda_layer_version_s3 | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_object.lambda_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_bucket_object_key"></a> [bucket\_object\_key](#input\_bucket\_object\_key) | Name of the s3 Bucket | `string` | n/a | yes |
| <a name="input_bucket_object_source"></a> [bucket\_object\_source](#input\_bucket\_object\_source) | Name of the s3 Bucket | `string` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console | `string` | `"Parameter Store KMS master key"` | no |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_layer_version_compatible_architectures"></a> [layer\_version\_compatible\_architectures](#input\_layer\_version\_compatible\_architectures) | List of Architectures this layer is compatible with. Currently x86\_64 and arm64 can be specified | `string` | n/a | yes |
| <a name="input_layer_version_compatible_runtimes"></a> [layer\_version\_compatible\_runtimes](#input\_layer\_version\_compatible\_runtimes) | A list of Runtimes this layer is compatible with. Up to 5 runtimes can be specified | `list(string)` | n/a | yes |
| <a name="input_layer_version_description"></a> [layer\_version\_description](#input\_layer\_version\_description) | Description of what your Lambda Layer does | `string` | n/a | yes |
| <a name="input_layer_version_layer_name"></a> [layer\_version\_layer\_name](#input\_layer\_version\_layer\_name) | Unique name for your Lambda Layer | `string` | n/a | yes |
| <a name="input_layer_version_permission_action"></a> [layer\_version\_permission\_action](#input\_layer\_version\_permission\_action) | Action, which will be allowed. lambda:GetLayerVersion value is suggested by AWS documantation | `string` | n/a | yes |
| <a name="input_layer_version_permission_principal"></a> [layer\_version\_permission\_principal](#input\_layer\_version\_permission\_principal) | AWS account ID which should be able to use your Lambda Layer. * can be used here, if you want to share your Lambda Layer widely | `string` | n/a | yes |
| <a name="input_layer_version_permission_statement_id"></a> [layer\_version\_permission\_statement\_id](#input\_layer\_version\_permission\_statement\_id) | The name of Lambda Layer Permission, for example dev-account - human readable note about what is this permission for | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the s3 Bucket | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
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