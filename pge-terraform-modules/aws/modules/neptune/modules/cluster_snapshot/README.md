<!-- BEGIN_TF_DOCS -->
*#AWS Neptune module
*Terraform module which creates snapshot

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
| [aws_neptune_cluster_snapshot.neptune_cluster_snapshot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/neptune_cluster_snapshot) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_cluster_identifier"></a> [db\_cluster\_identifier](#input\_db\_cluster\_identifier) | The DB Cluster Identifier from which to take the snapshot. The DB cluster should exist in the AWS account to take the snapshot. This is a prerequisite to meet before running the example. | `string` | n/a | yes |
| <a name="input_db_cluster_snapshot_identifier"></a> [db\_cluster\_snapshot\_identifier](#input\_db\_cluster\_snapshot\_identifier) | The Identifier for the snapshot. | `string` | n/a | yes |
| <a name="input_snapshot_create_timeouts"></a> [snapshot\_create\_timeouts](#input\_snapshot\_create\_timeouts) | How long to wait for the snapshot to be available. We should use the format like 20m for 20 minutes, 10s for ten seconds, or 2h for two hours. | `string` | `"20m"` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_neptune_cluster_snapshot_all"></a> [neptune\_cluster\_snapshot\_all](#output\_neptune\_cluster\_snapshot\_all) | A map of aws neptune cluster snapshot |
| <a name="output_neptune_snapshot_allocated_storage"></a> [neptune\_snapshot\_allocated\_storage](#output\_neptune\_snapshot\_allocated\_storage) | Specifies the allocated storage size in gigabytes (GB). |
| <a name="output_neptune_snapshot_availability_zones"></a> [neptune\_snapshot\_availability\_zones](#output\_neptune\_snapshot\_availability\_zones) | List of EC2 Availability Zones that instances in the DB cluster snapshot can be restored in. |
| <a name="output_neptune_snapshot_db_cluster_snapshot_arn"></a> [neptune\_snapshot\_db\_cluster\_snapshot\_arn](#output\_neptune\_snapshot\_db\_cluster\_snapshot\_arn) | The Amazon Resource Name (ARN) for the DB Cluster Snapshot. |
| <a name="output_neptune_snapshot_engine"></a> [neptune\_snapshot\_engine](#output\_neptune\_snapshot\_engine) | Specifies the name of the database engine. |
| <a name="output_neptune_snapshot_engine_version"></a> [neptune\_snapshot\_engine\_version](#output\_neptune\_snapshot\_engine\_version) | Version of the database engine for this DB cluster snapshot. |
| <a name="output_neptune_snapshot_kms_key_id"></a> [neptune\_snapshot\_kms\_key\_id](#output\_neptune\_snapshot\_kms\_key\_id) | If storage\_encrypted is true, the AWS KMS key identifier for the encrypted DB cluster snapshot. |
| <a name="output_neptune_snapshot_license_model"></a> [neptune\_snapshot\_license\_model](#output\_neptune\_snapshot\_license\_model) | License model information for the restored DB cluster. |
| <a name="output_neptune_snapshot_port"></a> [neptune\_snapshot\_port](#output\_neptune\_snapshot\_port) | Port that the DB cluster was listening on at the time of the snapshot. |
| <a name="output_neptune_snapshot_status"></a> [neptune\_snapshot\_status](#output\_neptune\_snapshot\_status) | The status of this DB Cluster Snapshot. |
| <a name="output_neptune_snapshot_storage_encrypted"></a> [neptune\_snapshot\_storage\_encrypted](#output\_neptune\_snapshot\_storage\_encrypted) | Specifies whether the DB cluster snapshot is encrypted. |
| <a name="output_neptune_snapshot_vpc_id"></a> [neptune\_snapshot\_vpc\_id](#output\_neptune\_snapshot\_vpc\_id) | The VPC ID associated with the DB cluster snapshot. |

<!-- END_TF_DOCS -->