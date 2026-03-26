<!-- BEGIN_TF_DOCS -->
AWS DocumentDB module
Terraform module which creates cluster snapshot

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
| [aws_docdb_cluster_snapshot.docdb_cluster_snapshot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster_snapshot) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_cluster_identifier"></a> [db\_cluster\_identifier](#input\_db\_cluster\_identifier) | The DocDB Cluster Identifier from which to take the snapshot. | `string` | n/a | yes |
| <a name="input_db_cluster_snapshot_identifier"></a> [db\_cluster\_snapshot\_identifier](#input\_db\_cluster\_snapshot\_identifier) | The Identifier for the snapshot. | `string` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | The cluster timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. | `map(string)` | `{}` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | List of EC2 Availability Zones that instances in the DocDB cluster snapshot can be restored in. |
| <a name="output_aws_docdb_cluster_snapshot"></a> [aws\_docdb\_cluster\_snapshot](#output\_aws\_docdb\_cluster\_snapshot) | The entire output of the aws\_docdb\_cluster\_snapshot resource |
| <a name="output_db_cluster_snapshot_arn"></a> [db\_cluster\_snapshot\_arn](#output\_db\_cluster\_snapshot\_arn) | The Amazon Resource Name (ARN) for the DocDB Cluster Snapshot. |
| <a name="output_engine"></a> [engine](#output\_engine) | Specifies the name of the database engine. |
| <a name="output_engine_version"></a> [engine\_version](#output\_engine\_version) | Version of the database engine for this DocDB cluster snapshot. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | If storage\_encrypted is true, the AWS KMS key identifier for the encrypted DocDB cluster snapshot. |
| <a name="output_port"></a> [port](#output\_port) | Port that the DocDB cluster was listening on at the time of the snapshot. |
| <a name="output_status"></a> [status](#output\_status) | The status of this DocDB Cluster Snapshot. |
| <a name="output_storage_encrypted"></a> [storage\_encrypted](#output\_storage\_encrypted) | Specifies whether the DocDB cluster snapshot is encrypted. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The VPC ID associated with the DocDB cluster snapshot. |

<!-- END_TF_DOCS -->