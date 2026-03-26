<!-- BEGIN_TF_DOCS -->
# AWS SSM module
Terraform module which creates SAF2.0 SSM Patch-Manager Baseline in AWS

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
| [aws_ssm_default_patch_baseline.default_patch_baseline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_default_patch_baseline) | resource |
| [aws_ssm_patch_baseline.baseline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_patch_baseline) | resource |
| [aws_ssm_patch_group.patchgroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_patch_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_approved_patches"></a> [approved\_patches](#input\_approved\_patches) | A list of explicitly approved patches for the baseline | `list(string)` | `[]` | no |
| <a name="input_approved_patches_compliance_level"></a> [approved\_patches\_compliance\_level](#input\_approved\_patches\_compliance\_level) | Defines the compliance level for approved patches. This means that if an approved patch is reported as missing, this is the severity of the compliance violation. Valid compliance levels include the following: CRITICAL, HIGH, MEDIUM, LOW, INFORMATIONAL, UNSPECIFIED. The default value is UNSPECIFIED. | `string` | `"UNSPECIFIED"` | no |
| <a name="input_operating_system"></a> [operating\_system](#input\_operating\_system) | Defines the operating system the patch baseline applies to. Supported operating systems include WINDOWS, AMAZON\_LINUX, AMAZON\_LINUX\_2, SUSE, UBUNTU, CENTOS, and REDHAT\_ENTERPRISE\_LINUX. The Default value is WINDOWS. | `string` | `"AMAZON_LINUX_2"` | no |
| <a name="input_patch_baseline_approval_rules"></a> [patch\_baseline\_approval\_rules](#input\_patch\_baseline\_approval\_rules) | A set of rules used to include patches in the baseline. Up to 10 approval rules can be specified. Each `approval_rule` block requires the fields documented below. | `list(any)` | `[]` | no |
| <a name="input_patch_baseline_global_filter"></a> [patch\_baseline\_global\_filter](#input\_patch\_baseline\_global\_filter) | A set of global filters used to exclude patches from the baseline. Up to 4 global filters can be specified using Key/Value pairs. Valid Keys are PRODUCT, CLASSIFICATION, MSRC\_SEVERITY, and PATCH\_ID | <pre>list(object({<br>    key : string<br>    values : list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_patch_groups"></a> [patch\_groups](#input\_patch\_groups) | The targets to register with the maintenance window. In other words, the instances to run commands on when the maintenance window runs. You can specify targets using instance IDs, resource group names, or tags that have been applied to instances. | `list(string)` | `[]` | no |
| <a name="input_rejected_patches"></a> [rejected\_patches](#input\_rejected\_patches) | A list of rejected patches | `list(string)` | `[]` | no |
| <a name="input_rejected_patches_action"></a> [rejected\_patches\_action](#input\_rejected\_patches\_action) | The action for Patch Manager to take on patches included in the rejected\_patches list. Valid values are ALLOW\_AS\_DEPENDENCY and BLOCK | `string` | `null` | no |
| <a name="input_set_default_patch_baseline"></a> [set\_default\_patch\_baseline](#input\_set\_default\_patch\_baseline) | whether to set this baseline as a Default Patch Baseline | `bool` | `false` | no |
| <a name="input_ssm_patch_baseline_description"></a> [ssm\_patch\_baseline\_description](#input\_ssm\_patch\_baseline\_description) | The description of the patch baseline. | `string` | `"This is PGE patch-manager baseline"` | no |
| <a name="input_ssm_patch_baseline_name"></a> [ssm\_patch\_baseline\_name](#input\_ssm\_patch\_baseline\_name) | The name of the patch baseline | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | SSM Patch Manager patch baseline ARN |
| <a name="output_id"></a> [id](#output\_id) | SSM Patch Manager patch baseline ID |
| <a name="output_patch_baseline_all"></a> [patch\_baseline\_all](#output\_patch\_baseline\_all) | Map of all Patch baseline object |
| <a name="output_patchgroup_id"></a> [patchgroup\_id](#output\_patchgroup\_id) | SSM Patch Manager patch group ID |


<!-- END_TF_DOCS -->