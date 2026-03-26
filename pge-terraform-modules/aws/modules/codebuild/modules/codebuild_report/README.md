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

# AWS Codebuild module creating Codebuild report
Terraform module which creates SAF2.0 Codebuild in AWS.

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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_codebuild_report_group.codebuild_rg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_report_group) | resource |
| [aws_codebuild_resource_policy.codebuild_resource_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_resource_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_codebuild_resource_policy"></a> [codebuild\_resource\_policy](#input\_codebuild\_resource\_policy) | Policy file | `string` | `"{}"` | no |
| <a name="input_codebuild_rg_bucket"></a> [codebuild\_rg\_bucket](#input\_codebuild\_rg\_bucket) | The name of the S3 bucket where the raw data of a report are exported | `string` | n/a | yes |
| <a name="input_codebuild_rg_delete_reports"></a> [codebuild\_rg\_delete\_reports](#input\_codebuild\_rg\_delete\_reports) | If true, deletes any reports that belong to a report group before deleting the report group | `bool` | `false` | no |
| <a name="input_codebuild_rg_export_type"></a> [codebuild\_rg\_export\_type](#input\_codebuild\_rg\_export\_type) | The export configuration type | `string` | n/a | yes |
| <a name="input_codebuild_rg_kms"></a> [codebuild\_rg\_kms](#input\_codebuild\_rg\_kms) | The encryption key for the report's encrypted raw data. The KMS key ARN | `string` | n/a | yes |
| <a name="input_codebuild_rg_name"></a> [codebuild\_rg\_name](#input\_codebuild\_rg\_name) | The name of Report Group | `string` | n/a | yes |
| <a name="input_codebuild_rg_packaging"></a> [codebuild\_rg\_packaging](#input\_codebuild\_rg\_packaging) | The type of build output artifact to create | `string` | `"NONE"` | no |
| <a name="input_codebuild_rg_path"></a> [codebuild\_rg\_path](#input\_codebuild\_rg\_path) | The path to the exported report's raw data results | `string` | `null` | no |
| <a name="input_codebuild_rg_type"></a> [codebuild\_rg\_type](#input\_codebuild\_rg\_type) | The type of the Report Group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codebuild_report_arn"></a> [codebuild\_report\_arn](#output\_codebuild\_report\_arn) | ARN of the CodeBuild Report Group |
| <a name="output_codebuild_report_created"></a> [codebuild\_report\_created](#output\_codebuild\_report\_created) | The date and time this Report Group was created |
| <a name="output_codebuild_report_group"></a> [codebuild\_report\_group](#output\_codebuild\_report\_group) | A map of codebuild report group |
| <a name="output_codebuild_report_tags_all"></a> [codebuild\_report\_tags\_all](#output\_codebuild\_report\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_codebuild_resource_policy"></a> [codebuild\_resource\_policy](#output\_codebuild\_resource\_policy) | A map of codebuild resource policy |

<!-- END_TF_DOCS -->