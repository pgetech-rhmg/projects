<!-- BEGIN_TF_DOCS -->

# Prerequesties

### AWS Secrets Manager - GitHub Token
# For testing this example, you need to create a GitHub token and store it in AWS Secrets Manager.
# Provide the **ARN** of the secret in the variable "secretsmanager_github_token_secret_arn".
#
# Note: Previously, this variable used the secret name. It has now been updated to use the full ARN.
#
# Steps to create the secret in AWS Secrets Manager:
# 1. Create a plain text secret with the following key-value pairs:
#    - ServerType = GITHUB
#    - AuthType = PERSONAL_ACCESS_TOKEN
#    - Token = "your_personal_access_token"

# AWS codebuild report User module example

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_codebuild_report_group"></a> [codebuild\_report\_group](#module\_codebuild\_report\_group) | ../../modules/codebuild_report | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | app.terraform.io/pgetech/kms/aws | 0.1.0 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the S3 bucket | `string` | n/a | yes |
| <a name="input_codebuild_rg_delete_reports"></a> [codebuild\_rg\_delete\_reports](#input\_codebuild\_rg\_delete\_reports) | If true, deletes any reports that belong to a report group before deleting the report group | `bool` | n/a | yes |
| <a name="input_codebuild_rg_export_type"></a> [codebuild\_rg\_export\_type](#input\_codebuild\_rg\_export\_type) | The export configuration type | `string` | n/a | yes |
| <a name="input_codebuild_rg_name"></a> [codebuild\_rg\_name](#input\_codebuild\_rg\_name) | The name of Report Group | `string` | n/a | yes |
| <a name="input_codebuild_rg_packaging"></a> [codebuild\_rg\_packaging](#input\_codebuild\_rg\_packaging) | The type of build output artifact to create. Valid values are: NONE and ZIP. | `string` | n/a | yes |
| <a name="input_codebuild_rg_path"></a> [codebuild\_rg\_path](#input\_codebuild\_rg\_path) | The path to the exported report's raw data results | `string` | n/a | yes |
| <a name="input_codebuild_rg_type"></a> [codebuild\_rg\_type](#input\_codebuild\_rg\_type) | The type of the Report Group | `string` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console. | `string` | n/a | yes |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_policy_file_name"></a> [policy\_file\_name](#input\_policy\_file\_name) | Valid JSON document representing a resource policy | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codebuild_report_arn"></a> [codebuild\_report\_arn](#output\_codebuild\_report\_arn) | ARN of the CodeBuild Report Group |
| <a name="output_codebuild_report_created"></a> [codebuild\_report\_created](#output\_codebuild\_report\_created) | The date and time this Report Group was created |
| <a name="output_codebuild_report_tags_all"></a> [codebuild\_report\_tags\_all](#output\_codebuild\_report\_tags\_all) | A map of tags assigned to the resource |

<!-- END_TF_DOCS -->