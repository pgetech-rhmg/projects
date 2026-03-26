<!-- BEGIN_TF_DOCS -->
# AWS dms replication instance and subnet groups
Terraform module which creates SAF2.0 codepipeline in AWS

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.1.0 |
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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_dms_replication_instance.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_instance) | resource |
| [aws_dms_replication_subnet_group.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_subnet_group) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance_allocated_storage"></a> [instance\_allocated\_storage](#input\_instance\_allocated\_storage) | The amount of storage (in gigabytes) to be initially allocated for the replication instance. | `number` | `null` | no |
| <a name="input_instance_allow_major_version_upgrade"></a> [instance\_allow\_major\_version\_upgrade](#input\_instance\_allow\_major\_version\_upgrade) | (Optional, Default: false) Indicates that major version upgrades are allowed. | `bool` | `false` | no |
| <a name="input_instance_apply_immediately"></a> [instance\_apply\_immediately](#input\_instance\_apply\_immediately) | Indicates whether the changes should be applied immediately or during the next maintenance window. Only used when updating an existing resource. | `bool` | `null` | no |
| <a name="input_instance_availability_zone"></a> [instance\_availability\_zone](#input\_instance\_availability\_zone) | The EC2 Availability Zone that the replication instance will be created in. | `string` | `null` | no |
| <a name="input_instance_engine_version"></a> [instance\_engine\_version](#input\_instance\_engine\_version) | The engine version number of the replication instance. | `string` | `null` | no |
| <a name="input_instance_kms_key_arn"></a> [instance\_kms\_key\_arn](#input\_instance\_kms\_key\_arn) | The Amazon Resource Name (ARN) for the KMS key that will be used to encrypt the connection parameters. | `string` | `null` | no |
| <a name="input_instance_multi_az"></a> [instance\_multi\_az](#input\_instance\_multi\_az) | Specifies if the replication instance is a multi-az deployment. You cannot set the availability\_zone parameter if the multi\_az parameter is set to true. | `bool` | `null` | no |
| <a name="input_instance_preferred_maintenance"></a> [instance\_preferred\_maintenance](#input\_instance\_preferred\_maintenance) | The weekly time range during which system maintenance can occur, in Universal Coordinated Time (UTC). | `string` | `null` | no |
| <a name="input_instance_publicly_accessible"></a> [instance\_publicly\_accessible](#input\_instance\_publicly\_accessible) | Specifies the accessibility options for the replication instance. A value of true represents an instance with a public IP address. A value of false represents an instance with a private IP address. | `bool` | `null` | no |
| <a name="input_instance_replication_id"></a> [instance\_replication\_id](#input\_instance\_replication\_id) | The replication instance identifier. | `string` | n/a | yes |
| <a name="input_instance_replication_instance_class"></a> [instance\_replication\_instance\_class](#input\_instance\_replication\_instance\_class) | The compute and memory capacity of the replication instance as specified by the replication instance class. | `string` | n/a | yes |
| <a name="input_instance_version_upgrade"></a> [instance\_version\_upgrade](#input\_instance\_version\_upgrade) | Indicates that minor engine upgrades will be applied automatically to the replication instance during the maintenance window. | `bool` | `null` | no |
| <a name="input_replication_subnet_group_description"></a> [replication\_subnet\_group\_description](#input\_replication\_subnet\_group\_description) | The description for the subnet group. | `string` | n/a | yes |
| <a name="input_replication_subnet_group_id"></a> [replication\_subnet\_group\_id](#input\_replication\_subnet\_group\_id) | The name for the replication subnet group. This value is stored as a lowercase string. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of the EC2 subnet IDs for the subnet group. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_timeouts_create"></a> [timeouts\_create](#input\_timeouts\_create) | Used for Creating Instances | `string` | `"40m"` | no |
| <a name="input_timeouts_delete"></a> [timeouts\_delete](#input\_timeouts\_delete) | Used for destroying databases | `string` | `"80m"` | no |
| <a name="input_timeouts_update"></a> [timeouts\_update](#input\_timeouts\_update) | Used for Database modifications | `string` | `"80m"` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | A list of VPC security group IDs to be used with the replication instance. The VPC security groups must work with the VPC containing the replication instance. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dms_replication_instance_all"></a> [dms\_replication\_instance\_all](#output\_dms\_replication\_instance\_all) | A map of aws dms replication instance |
| <a name="output_dms_replication_subnet_group_all"></a> [dms\_replication\_subnet\_group\_all](#output\_dms\_replication\_subnet\_group\_all) | A map of aws dms replication subnet group |
| <a name="output_replication_instance_arn"></a> [replication\_instance\_arn](#output\_replication\_instance\_arn) | The Amazon Resource Name (ARN) of the replication instance. |
| <a name="output_replication_instance_private_ips"></a> [replication\_instance\_private\_ips](#output\_replication\_instance\_private\_ips) | A list of the private IP addresses of the replication instance. |
| <a name="output_vpc_id_replication_subnet_group"></a> [vpc\_id\_replication\_subnet\_group](#output\_vpc\_id\_replication\_subnet\_group) | The ID of the VPC the subnet group is in. |


<!-- END_TF_DOCS -->