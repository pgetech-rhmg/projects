<!-- BEGIN_TF_DOCS -->
# AWS Neptune User module example

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.8 |

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
| <a name="module_neptune_cluster_endpoint"></a> [neptune\_cluster\_endpoint](#module\_neptune\_cluster\_endpoint) | ../../modules/cluster_endpoint | n/a |
| <a name="module_neptune_cluster_instance"></a> [neptune\_cluster\_instance](#module\_neptune\_cluster\_instance) | ../../modules/cluster_instance | n/a |
| <a name="module_neptune_cluster_parameter_group"></a> [neptune\_cluster\_parameter\_group](#module\_neptune\_cluster\_parameter\_group) | ../../modules/cluster_parameter_group | n/a |
| <a name="module_neptune_instance_parameter_group"></a> [neptune\_instance\_parameter\_group](#module\_neptune\_instance\_parameter\_group) | ../../modules/instance_parameter_group | n/a |
| <a name="module_neptune_subnet_group"></a> [neptune\_subnet\_group](#module\_neptune\_subnet\_group) | ../../modules/subnet_group | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait_20min](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
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
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance    Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | (Optional) The neptune engine version. | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The instance class to use. | `string` | n/a | yes |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of instances to create. | `number` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS kms role to assume | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A common name for all resource. | `string` | n/a | yes |
| <a name="input_neptune_cluster_endpoint_type"></a> [neptune\_cluster\_endpoint\_type](#input\_neptune\_cluster\_endpoint\_type) | The type of the endpoint. One of: READER, WRITER, ANY. | `string` | n/a | yes |
| <a name="input_neptune_dfe_query_engine_value"></a> [neptune\_dfe\_query\_engine\_value](#input\_neptune\_dfe\_query\_engine\_value) | The value of the neptune instance parameter neptune\_dfe\_query\_engine.Allowed values are as follows: enabled and viaQueryHint (the default) | `string` | n/a | yes |
| <a name="input_neptune_lookup_cache_value"></a> [neptune\_lookup\_cache\_value](#input\_neptune\_lookup\_cache\_value) | The value of the neptune cluster parameter neptune\_lookup\_cache. | `string` | n/a | yes |
| <a name="input_neptune_ml_endpoint_value"></a> [neptune\_ml\_endpoint\_value](#input\_neptune\_ml\_endpoint\_value) | The value of the neptune cluster parameter neptune\_ml\_endpoint. | `string` | n/a | yes |
| <a name="input_neptune_ml_iam_role_value"></a> [neptune\_ml\_iam\_role\_value](#input\_neptune\_ml\_iam\_role\_value) | The value of the neptune cluster parameter neptune\_ml\_iam\_role. | `string` | n/a | yes |
| <a name="input_neptune_query_timeout_value"></a> [neptune\_query\_timeout\_value](#input\_neptune\_query\_timeout\_value) | The value of the neptune instance parameter neptune\_query\_timeout.This DB instance parameter specifies a timeout duration for graph queries, in milliseconds, for one instance. Valid values: 10 to 2,147,483,647 (231 - 1) | `number` | n/a | yes |
| <a name="input_neptune_result_cache_value"></a> [neptune\_result\_cache\_value](#input\_neptune\_result\_cache\_value) | The value of the neptune instance parameter neptune\_result\_cache | `string` | n/a | yes |
| <a name="input_neptune_streams_value"></a> [neptune\_streams\_value](#input\_neptune\_streams\_value) | The value of the neptune cluster parameter neptune\_streams. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | (Optional) Determines whether a final Neptune snapshot is created before the Neptune cluster is deleted. If true is specified, no Neptune snapshot is created. If false is specified, a Neptune snapshot is created before the Neptune cluster is deleted, using the value from final\_snapshot\_identifier. Default is false. | `bool` | `false` | no |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | enter the value of subnet id2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | enter the value of subnet id3 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_template_file_name"></a> [template\_file\_name](#input\_template\_file\_name) | Policy template file in json format | `string` | `""` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The Neptune Cluster Amazon Resource Name (ARN) |
| <a name="output_cluster_instance_address"></a> [cluster\_instance\_address](#output\_cluster\_instance\_address) | The hostname of the instance. |
| <a name="output_cluster_instance_arn"></a> [cluster\_instance\_arn](#output\_cluster\_instance\_arn) | Amazon Resource Name (ARN) of neptune instance. |
| <a name="output_cluster_instance_dbi_resource_id"></a> [cluster\_instance\_dbi\_resource\_id](#output\_cluster\_instance\_dbi\_resource\_id) | The region-unique, immutable identifier for the neptune instance. |
| <a name="output_cluster_instance_endpoint"></a> [cluster\_instance\_endpoint](#output\_cluster\_instance\_endpoint) | The connection endpoint in address:port format. |
| <a name="output_cluster_instance_id"></a> [cluster\_instance\_id](#output\_cluster\_instance\_id) | The Instance identifier. |
| <a name="output_cluster_instance_kms_key_arn"></a> [cluster\_instance\_kms\_key\_arn](#output\_cluster\_instance\_kms\_key\_arn) | The ARN for the KMS encryption key if one is set to the neptune cluster. |
| <a name="output_cluster_instance_storage_encrypted"></a> [cluster\_instance\_storage\_encrypted](#output\_cluster\_instance\_storage\_encrypted) | Specifies whether the neptune cluster is encrypted. |
| <a name="output_cluster_instance_tags_all"></a> [cluster\_instance\_tags\_all](#output\_cluster\_instance\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_cluster_instance_writer"></a> [cluster\_instance\_writer](#output\_cluster\_instance\_writer) | Boolean indicating if this instance is writable. False indicates this instance is a read replica. |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | The Route53 Hosted Zone ID of the endpoint |
| <a name="output_neptune_cluster_endpoint"></a> [neptune\_cluster\_endpoint](#output\_neptune\_cluster\_endpoint) | The DNS address of the Neptune instance |
| <a name="output_neptune_cluster_endpoint_arn"></a> [neptune\_cluster\_endpoint\_arn](#output\_neptune\_cluster\_endpoint\_arn) | The Neptune Cluster Endpoint Amazon Resource Name (ARN). |
| <a name="output_neptune_cluster_endpoint_id"></a> [neptune\_cluster\_endpoint\_id](#output\_neptune\_cluster\_endpoint\_id) | The Neptune Cluster Endpoint Identifier |
| <a name="output_neptune_cluster_endpoint_tags_all"></a> [neptune\_cluster\_endpoint\_tags\_all](#output\_neptune\_cluster\_endpoint\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_neptune_cluster_id"></a> [neptune\_cluster\_id](#output\_neptune\_cluster\_id) | The Neptune Cluster Identifier |
| <a name="output_neptune_cluster_members"></a> [neptune\_cluster\_members](#output\_neptune\_cluster\_members) | List of Neptune Instances that are a part of this cluster |
| <a name="output_neptune_cluster_parameter_group_arn"></a> [neptune\_cluster\_parameter\_group\_arn](#output\_neptune\_cluster\_parameter\_group\_arn) | The ARN of the neptune cluster parameter group |
| <a name="output_neptune_cluster_parameter_group_id"></a> [neptune\_cluster\_parameter\_group\_id](#output\_neptune\_cluster\_parameter\_group\_id) | The neptune cluster parameter group name |
| <a name="output_neptune_cluster_parameter_group_tags_all"></a> [neptune\_cluster\_parameter\_group\_tags\_all](#output\_neptune\_cluster\_parameter\_group\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block |
| <a name="output_neptune_cluster_reader_endpoint"></a> [neptune\_cluster\_reader\_endpoint](#output\_neptune\_cluster\_reader\_endpoint) | A read-only endpoint for the Neptune cluster, automatically load-balanced across replicas |
| <a name="output_neptune_cluster_resource_id"></a> [neptune\_cluster\_resource\_id](#output\_neptune\_cluster\_resource\_id) | The Neptune Cluster Resource ID |
| <a name="output_neptune_cluster_tags_all"></a> [neptune\_cluster\_tags\_all](#output\_neptune\_cluster\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_neptune_endpoint"></a> [neptune\_endpoint](#output\_neptune\_endpoint) | The DNS address of the endpoint. |
| <a name="output_neptune_instance_parameter_group_arn"></a> [neptune\_instance\_parameter\_group\_arn](#output\_neptune\_instance\_parameter\_group\_arn) | The ARN of the neptune instance parameter group |
| <a name="output_neptune_instance_parameter_group_id"></a> [neptune\_instance\_parameter\_group\_id](#output\_neptune\_instance\_parameter\_group\_id) | The neptune instance parameter group name |
| <a name="output_neptune_instance_parameter_group_tags_all"></a> [neptune\_instance\_parameter\_group\_tags\_all](#output\_neptune\_instance\_parameter\_group\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block |
| <a name="output_neptune_subnet_group_arn"></a> [neptune\_subnet\_group\_arn](#output\_neptune\_subnet\_group\_arn) | The ARN of the neptune subnet group |
| <a name="output_neptune_subnet_group_id"></a> [neptune\_subnet\_group\_id](#output\_neptune\_subnet\_group\_id) | The neptune subnet group name |
| <a name="output_neptune_subnet_group_tags_all"></a> [neptune\_subnet\_group\_tags\_all](#output\_neptune\_subnet\_group\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->