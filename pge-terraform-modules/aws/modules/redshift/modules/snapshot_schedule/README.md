<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.0 |

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
| [aws_redshift_snapshot_schedule.snapshot_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_snapshot_schedule) | resource |
| [aws_redshift_snapshot_schedule_association.snapshot_schedule_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_snapshot_schedule_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_snapshot_cluster_identifier"></a> [snapshot\_cluster\_identifier](#input\_snapshot\_cluster\_identifier) | cluster to associate with snapshot schedule | `string` | `null` | no |
| <a name="input_snapshot_schedule_association"></a> [snapshot\_schedule\_association](#input\_snapshot\_schedule\_association) | variable declared for iteration. | `list(string)` | n/a | yes |
| <a name="input_snapshot_schedule_definitions"></a> [snapshot\_schedule\_definitions](#input\_snapshot\_schedule\_definitions) | The definition of the snapshot schedule. | `list(string)` | `[]` | no |
| <a name="input_snapshot_schedule_description"></a> [snapshot\_schedule\_description](#input\_snapshot\_schedule\_description) | The description of the snapshot schedule. | `string` | `null` | no |
| <a name="input_snapshot_schedule_force_destroy"></a> [snapshot\_schedule\_force\_destroy](#input\_snapshot\_schedule\_force\_destroy) | Whether to destroy all associated clusters with this snapshot schedule on deletion. Must be enabled and applied before attempting deletion. | `bool` | `null` | no |
| <a name="input_snapshot_schedule_identifier"></a> [snapshot\_schedule\_identifier](#input\_snapshot\_schedule\_identifier) | The snapshot schedule identifier. If omitted, Terraform will assign a random, unique identifier. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_redshift_snapshot_schedule_all"></a> [aws\_redshift\_snapshot\_schedule\_all](#output\_aws\_redshift\_snapshot\_schedule\_all) | A map of aws redshift snapshot schedule attributes references |
| <a name="output_aws_redshift_snapshot_schedule_association_all"></a> [aws\_redshift\_snapshot\_schedule\_association\_all](#output\_aws\_redshift\_snapshot\_schedule\_association\_all) | A map of aws redshift snapshot schedule association attributes references |
| <a name="output_snapshot_schedule_arn"></a> [snapshot\_schedule\_arn](#output\_snapshot\_schedule\_arn) | Amazon Resource Name (ARN) of the Redshift Snapshot Schedule. |
| <a name="output_snapshot_schedule_tags_all"></a> [snapshot\_schedule\_tags\_all](#output\_snapshot\_schedule\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider. |

<!-- END_TF_DOCS -->