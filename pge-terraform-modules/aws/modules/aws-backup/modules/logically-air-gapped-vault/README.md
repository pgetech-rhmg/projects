<!-- BEGIN_TF_DOCS -->
# AWS Backup Logically Air Gapped Vault module
Terraform module which creates SAF2.0  AWS Backup Logically Air Gapped Vault
A backup vault is a container that stores and organizes your backups.

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
| <a name="provider_external"></a> [external](#provider\_external) | n/a |

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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.0 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_backup_logically_air_gapped_vault.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_logically_air_gapped_vault) | resource |
| [aws_backup_vault_notifications.vault_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_notifications) | resource |
| [aws_backup_vault_policy.vault_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_vault_events"></a> [backup\_vault\_events](#input\_backup\_vault\_events) | An array of events that indicate the status of jobs to back up resources to the backup vault. | `list(string)` | `[]` | no |
| <a name="input_create_vault_notifications"></a> [create\_vault\_notifications](#input\_create\_vault\_notifications) | Change to true if vault notifications needs to be enabled | `bool` | `false` | no |
| <a name="input_create_vault_policy"></a> [create\_vault\_policy](#input\_create\_vault\_policy) | Change to true to add IAM policy for the backup vault | `bool` | `false` | no |
| <a name="input_max_retention_days"></a> [max\_retention\_days](#input\_max\_retention\_days) | The maximum retention period that the vault retains its recovery points | `number` | `null` | no |
| <a name="input_min_retention_days"></a> [min\_retention\_days](#input\_min\_retention\_days) | The minimum retention period that the vault retains its recovery points | `number` | `null` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | The Amazon Resource Name (ARN) that specifies the topic for a backup vault’s events | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_vault_iam_policy"></a> [vault\_iam\_policy](#input\_vault\_iam\_policy) | The backup vault access policy document in JSON format | `string` | `null` | no |
| <a name="input_vault_name"></a> [vault\_name](#input\_vault\_name) | Name of the backup vault to create | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vault_all"></a> [vault\_all](#output\_vault\_all) | All parameters of vault |
| <a name="output_vault_arn"></a> [vault\_arn](#output\_vault\_arn) | The ARN of the vault |
| <a name="output_vault_id"></a> [vault\_id](#output\_vault\_id) | The name of the vault |
| <a name="output_vault_recovery_points"></a> [vault\_recovery\_points](#output\_vault\_recovery\_points) | The number of recovery points that are stored in a backup vault |

<!-- END_TF_DOCS -->