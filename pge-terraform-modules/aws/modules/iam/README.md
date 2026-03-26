<!-- BEGIN_TF_DOCS -->
# AWS IAM Role module
Terraform module which creates SAF2.0 IAM Role in AWS

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.91.0 |

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
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.attach_managed_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_trusted_aws_principals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | A list of AWS services allowed to assume this role.  Required if the trusted\_aws\_principals variable is not provided. | `list(string)` | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the role | `string` | `"IAM Role created by pge_team = ccoe-tf-developers"` | no |
| <a name="input_force_detach_policies"></a> [force\_detach\_policies](#input\_force\_detach\_policies) | Whether to force detaching any policies the role has before destroying it | `bool` | `false` | no |
| <a name="input_inline_policy"></a> [inline\_policy](#input\_inline\_policy) | A list of strings.  Each string should contain a json string to use for this inline policy or pass as a file name in json | `list(string)` | `[]` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours. | `number` | `3600` | no |
| <a name="input_name"></a> [name](#input\_name) | The name prefix for these IAM resources | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | The path to the role in IAM | `string` | `"/"` | no |
| <a name="input_permission_boundary"></a> [permission\_boundary](#input\_permission\_boundary) | IAM policy ARN limiting the maximum access this role can have | `string` | `""` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | A list of managed IAM policies arns to attach to the IAM role | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_trusted_aws_principals"></a> [trusted\_aws\_principals](#input\_trusted\_aws\_principals) | A list of AWS trusted principals allowed to assume this role.  Required if the aws\_service variable is not provided. | `list(string)` | `[]` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) specifying the role |
| <a name="output_create_date"></a> [create\_date](#output\_create\_date) | The creation date of the IAM role |
| <a name="output_description"></a> [description](#output\_description) | The description of the role. |
| <a name="output_iam_role"></a> [iam\_role](#output\_iam\_role) | Map of IAM Role object |
| <a name="output_id"></a> [id](#output\_id) | The stable and unique string identifying the role |
| <a name="output_name"></a> [name](#output\_name) | The name of the IAM role created |
| <a name="output_path"></a> [path](#output\_path) | The path of the role in IAM |

<!-- END_TF_DOCS -->