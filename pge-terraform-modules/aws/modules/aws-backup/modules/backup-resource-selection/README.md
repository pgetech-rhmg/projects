<!-- BEGIN_TF_DOCS -->
# AWS Backup module
Terraform module which creates SAF2.0 AWS-Backup resource selections

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
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_backup_selection.backup_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_resources"></a> [backup\_resources](#input\_backup\_resources) | An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan. | `list(string)` | `[]` | no |
| <a name="input_backup_selection_name"></a> [backup\_selection\_name](#input\_backup\_selection\_name) | The display name of a resource selection document. | `string` | n/a | yes |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | The ARN of the IAM role that AWS Backup uses to authenticate when restoring and backing up the target resource. | `string` | n/a | yes |
| <a name="input_not_resources"></a> [not\_resources](#input\_not\_resources) | An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to exclude from a backup plan. | `list(string)` | `[]` | no |
| <a name="input_plan_id"></a> [plan\_id](#input\_plan\_id) | The backup plan ID to be associated with the selection of resources. | `string` | n/a | yes |
| <a name="input_selection_tags"></a> [selection\_tags](#input\_selection\_tags) | An array of tag condition objects used to filter resources based on tags for assigning to a backup plan | `any` | `[]` | no |
| <a name="input_string_equals"></a> [string\_equals](#input\_string\_equals) | The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2. | <pre>list(object({<br>    key : string<br>    value : string<br>    }<br>    )<br>  )</pre> | `[]` | no |
| <a name="input_string_like"></a> [string\_like](#input\_string\_like) | The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2. | <pre>list(object({<br>    key : string<br>    value : string<br>    }<br>    )<br>  )</pre> | `[]` | no |
| <a name="input_string_not_equals"></a> [string\_not\_equals](#input\_string\_not\_equals) | The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2. | <pre>list(object({<br>    key : string<br>    value : string<br>    }<br>    )<br>  )</pre> | `[]` | no |
| <a name="input_string_not_like"></a> [string\_not\_like](#input\_string\_not\_like) | The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2. | <pre>list(object({<br>    key : string<br>    value : string<br>    }<br>    )<br>  )</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all"></a> [all](#output\_all) | All attributes of Backup Selection identifier |
| <a name="output_id"></a> [id](#output\_id) | Backup Selection identifier |


<!-- END_TF_DOCS -->