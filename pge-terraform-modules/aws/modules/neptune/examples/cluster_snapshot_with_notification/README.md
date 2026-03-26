<!-- BEGIN_TF_DOCS -->
# AWS Neptune cluster snapshot with notification User module example

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

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
| <a name="module_neptune_cluster"></a> [neptune\_cluster](#module\_neptune\_cluster) | ../../ | n/a |
| <a name="module_neptune_cluster_parameter_group"></a> [neptune\_cluster\_parameter\_group](#module\_neptune\_cluster\_parameter\_group) | ../../modules/cluster_parameter_group | n/a |
| <a name="module_neptune_cluster_snapshot"></a> [neptune\_cluster\_snapshot](#module\_neptune\_cluster\_snapshot) | ../../modules/cluster_snapshot | n/a |
| <a name="module_neptune_event_subscription"></a> [neptune\_event\_subscription](#module\_neptune\_event\_subscription) | ../../modules/event_subscription | n/a |
| <a name="module_neptune_subnet_group"></a> [neptune\_subnet\_group](#module\_neptune\_subnet\_group) | ../../modules/subnet_group | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_sns_topic"></a> [sns\_topic](#module\_sns\_topic) | app.terraform.io/pgetech/sns/aws | 0.1.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.selected_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.selected_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.selected_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | (Optional) The neptune engine version. | `string` | n/a | yes |
| <a name="input_event_categories"></a> [event\_categories](#input\_event\_categories) | A list of event categories for a source\_type that you want to subscribe to. If the end user is not passing any values to this variable, then it will take all the possible values. | `list(string)` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS kms role to assume | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A common name for resources. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | (Optional) Determines whether a final Neptune snapshot is created before the Neptune cluster is deleted. If true is specified, no Neptune snapshot is created. If false is specified, a Neptune snapshot is created before the Neptune cluster is deleted, using the value from final\_snapshot\_identifier. Default is false. | `bool` | `false` | no |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | The type of source that will be generating the events. Valid options are db-instance, db-security-group, db-parameter-group, db-snapshot, db-cluster or db-cluster-snapshot. If not set, all sources will be subscribed to. | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | enter the value of subnet id2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | enter the value of subnet id3 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_template_file_name"></a> [template\_file\_name](#input\_template\_file\_name) | Policy template file in json format | `string` | `""` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | The cluster timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The Neptune Cluster Amazon Resource Name (ARN) |
| <a name="output_event_subscription_arn"></a> [event\_subscription\_arn](#output\_event\_subscription\_arn) | The Amazon Resource Name of the Neptune event notification subscription. |
| <a name="output_event_subscription_customer_aws_id"></a> [event\_subscription\_customer\_aws\_id](#output\_event\_subscription\_customer\_aws\_id) | The AWS customer account associated with the Neptune event notification subscription. |
| <a name="output_event_subscription_id"></a> [event\_subscription\_id](#output\_event\_subscription\_id) | The name of the Neptune event notification subscription. |
| <a name="output_event_subscription_tags_all"></a> [event\_subscription\_tags\_all](#output\_event\_subscription\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | The Route53 Hosted Zone ID of the endpoint |
| <a name="output_neptune_cluster_endpoint"></a> [neptune\_cluster\_endpoint](#output\_neptune\_cluster\_endpoint) | The DNS address of the Neptune instance |
| <a name="output_neptune_cluster_id"></a> [neptune\_cluster\_id](#output\_neptune\_cluster\_id) | The Neptune Cluster Identifier |
| <a name="output_neptune_cluster_members"></a> [neptune\_cluster\_members](#output\_neptune\_cluster\_members) | List of Neptune Instances that are a part of this cluster |
| <a name="output_neptune_cluster_parameter_group_arn"></a> [neptune\_cluster\_parameter\_group\_arn](#output\_neptune\_cluster\_parameter\_group\_arn) | The ARN of the neptune cluster parameter group |
| <a name="output_neptune_cluster_parameter_group_id"></a> [neptune\_cluster\_parameter\_group\_id](#output\_neptune\_cluster\_parameter\_group\_id) | The neptune cluster parameter group name |
| <a name="output_neptune_cluster_parameter_group_tags_all"></a> [neptune\_cluster\_parameter\_group\_tags\_all](#output\_neptune\_cluster\_parameter\_group\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block |
| <a name="output_neptune_cluster_reader_endpoint"></a> [neptune\_cluster\_reader\_endpoint](#output\_neptune\_cluster\_reader\_endpoint) | A read-only endpoint for the Neptune cluster, automatically load-balanced across replicas |
| <a name="output_neptune_cluster_resource_id"></a> [neptune\_cluster\_resource\_id](#output\_neptune\_cluster\_resource\_id) | The Neptune Cluster Resource ID |
| <a name="output_neptune_cluster_tags_all"></a> [neptune\_cluster\_tags\_all](#output\_neptune\_cluster\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
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
| <a name="output_neptune_subnet_group_arn"></a> [neptune\_subnet\_group\_arn](#output\_neptune\_subnet\_group\_arn) | The ARN of the neptune subnet group |
| <a name="output_neptune_subnet_group_id"></a> [neptune\_subnet\_group\_id](#output\_neptune\_subnet\_group\_id) | The neptune subnet group name |
| <a name="output_neptune_subnet_group_tags_all"></a> [neptune\_subnet\_group\_tags\_all](#output\_neptune\_subnet\_group\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->