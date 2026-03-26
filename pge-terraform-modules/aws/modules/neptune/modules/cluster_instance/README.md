<!-- BEGIN_TF_DOCS -->
*#AWS Neptune module
*Terraform module which creates cluster instance

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_neptune_cluster_instance.neptune_cluster_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/neptune_cluster_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any instance modifications are applied immediately, or during the next maintenance window. Default is false. | `bool` | `false` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The EC2 Availability Zone that the neptune instance is created in. | `string` | `null` | no |
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | The identifier of the aws\_neptune\_cluster in which to launch this instance. | `string` | n/a | yes |
| <a name="input_cluster_instance_timeouts"></a> [cluster\_instance\_timeouts](#input\_cluster\_instance\_timeouts) | The cluster instance timeouts should be in the format 90m for 90 minutes, 10s for ten seconds, or 2h for two hours. | `list(map(string))` | <pre>[<br/>  {<br/>    "create": "90m",<br/>    "delete": "90m",<br/>    "update": "90m"<br/>  }<br/>]</pre> | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | (Optional) The neptune engine version. | `string` | `"1.1.0.0"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | The identifier for the neptune instance, if omitted, Terraform will assign a random, unique identifier. | `string` | `null` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The instance class to use. | `string` | n/a | yes |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of instances to create. | `number` | `1` | no |
| <a name="input_neptune_parameter_group_name"></a> [neptune\_parameter\_group\_name](#input\_neptune\_parameter\_group\_name) | The name of the neptune parameter group to associate with this instance. | `string` | `null` | no |
| <a name="input_neptune_subnet_group_name"></a> [neptune\_subnet\_group\_name](#input\_neptune\_subnet\_group\_name) | A subnet group to associate with this neptune instance. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | The port on which the DB accepts connections. Defaults to 8182. | `number` | `8182` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | The daily time range during which automated backups are created if automated backups are enabled. Eg: 04:00-09:00. | `string` | `null` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | The window to perform maintenance in. Syntax: ddd:hh24:mi-ddd:hh24:mi. Eg: Mon:00:00-Mon:03:00. | `string` | `null` | no |
| <a name="input_promotion_tier"></a> [promotion\_tier](#input\_promotion\_tier) | Default 0. Failover Priority setting on instance level. The reader who has lower tier has higher priority to get promoter to writer. | `number` | `0` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_instance_address"></a> [cluster\_instance\_address](#output\_cluster\_instance\_address) | The hostname of the instance. |
| <a name="output_cluster_instance_arn"></a> [cluster\_instance\_arn](#output\_cluster\_instance\_arn) | Amazon Resource Name (ARN) of neptune instance. |
| <a name="output_cluster_instance_dbi_resource_id"></a> [cluster\_instance\_dbi\_resource\_id](#output\_cluster\_instance\_dbi\_resource\_id) | The region-unique, immutable identifier for the neptune instance. |
| <a name="output_cluster_instance_endpoint"></a> [cluster\_instance\_endpoint](#output\_cluster\_instance\_endpoint) | The connection endpoint in address:port format. |
| <a name="output_cluster_instance_id"></a> [cluster\_instance\_id](#output\_cluster\_instance\_id) | The Instance identifier. |
| <a name="output_cluster_instance_kms_key_arn"></a> [cluster\_instance\_kms\_key\_arn](#output\_cluster\_instance\_kms\_key\_arn) | The ARN for the KMS encryption key if one is set to the neptune cluster. |
| <a name="output_cluster_instance_storage_encrypted"></a> [cluster\_instance\_storage\_encrypted](#output\_cluster\_instance\_storage\_encrypted) | Specifies whether the neptune cluster is encrypted. |
| <a name="output_cluster_instance_tags_all"></a> [cluster\_instance\_tags\_all](#output\_cluster\_instance\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_cluster_instance_writer"></a> [cluster\_instance\_writer](#output\_cluster\_instance\_writer) | Boolean indicating if this instance is writable. False indicates this instance is a read replica. |
| <a name="output_neptune_cluster_instance_all"></a> [neptune\_cluster\_instance\_all](#output\_neptune\_cluster\_instance\_all) | A map of aws neptune cluster instance |

<!-- END_TF_DOCS -->