<!-- BEGIN_TF_DOCS -->
# AWS Elasticache-redis module example
# Usage creation for elasticache-redis single node instance with no replication.

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
| <a name="module_redis_single_node"></a> [redis\_single\_node](#module\_redis\_single\_node) | ../../ | n/a |
| <a name="module_security_group_redis"></a> [security\_group\_redis](#module\_security\_group\_redis) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

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
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create the resource.For CLOUDFRONT, you must create your WAFv2 resources in the us-east-1,(N. Virginia) Region. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role | `string` | n/a | yes |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    description      = string<br>    prefix_list_ids  = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_cidr_ingress_rules"></a> [cidr\_ingress\_rules](#input\_cidr\_ingress\_rules) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    description      = string<br>    prefix_list_ids  = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | Replication group identifier. This parameter is stored as a lowercase string. | `string` | n/a | yes |
| <a name="input_final_snapshot"></a> [final\_snapshot](#input\_final\_snapshot) | The name of your final node group (shard) snapshot. | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Specifies the weekly time range for when maintenance on the cache cluster is performed. The format is ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC). The minimum maintenance window is a 60 minute period. Example: sun:05:00-sun:09:00 | `string` | n/a | yes |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | The instance class used. See AWS documentation for information on supported node types for Redis and guidance on selecting node types for Redis | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_redis_engine_version"></a> [redis\_engine\_version](#input\_redis\_engine\_version) | Version number of the cache engine to be used. If not set, defaults to the latest version. When the version is 6 or higher, the major and minor version can be set, e.g., 6.2, or the minor version can be unspecified which will use the latest version at creation time, e.g., 6.x. Otherwise, specify the full version desired, e.g., 5.0.6. The actual engine version used is returned in the attribute engine\_version\_actual. | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | description for security group associated with lambda | `string` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | name of the security group associated with lambda | `string` | n/a | yes |
| <a name="input_slow_logs_log_delivery_destination"></a> [slow\_logs\_log\_delivery\_destination](#input\_slow\_logs\_log\_delivery\_destination) | Name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource | `string` | n/a | yes |
| <a name="input_slow_logs_log_delivery_destination_type"></a> [slow\_logs\_log\_delivery\_destination\_type](#input\_slow\_logs\_log\_delivery\_destination\_type) | For CloudWatch Logs use cloudwatch-logs or for Kinesis Data Firehose use kinesis-firehose | `string` | n/a | yes |
| <a name="input_slow_logs_log_delivery_log_format"></a> [slow\_logs\_log\_delivery\_log\_format](#input\_slow\_logs\_log\_delivery\_log\_format) | Valid values are json or text | `string` | n/a | yes |
| <a name="input_snapshot_retention"></a> [snapshot\_retention](#input\_snapshot\_retention) | Number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them. For example, if you set SnapshotRetentionLimit to 5, then a snapshot that was taken today will be retained for 5 days before being deleted. If the value of SnapshotRetentionLimit is set to zero (0), backups are turned off. snapshot\_retention\_limit is not supported on cache.t1.micro cache nodes | `number` | n/a | yes |
| <a name="input_snapshot_window"></a> [snapshot\_window](#input\_snapshot\_window) | Daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster. Example: 05:00-09:00 | `string` | n/a | yes |
| <a name="input_ssm_parameter_name_private_subnet1"></a> [ssm\_parameter\_name\_private\_subnet1](#input\_ssm\_parameter\_name\_private\_subnet1) | Enter the SSM Parameter name for the private subnet id-1. | `string` | n/a | yes |
| <a name="input_ssm_parameter_name_private_subnet2"></a> [ssm\_parameter\_name\_private\_subnet2](#input\_ssm\_parameter\_name\_private\_subnet2) | Enter the SSM Parameter name for the private subnet id-2. | `string` | n/a | yes |
| <a name="input_ssm_parameter_name_vpc_id"></a> [ssm\_parameter\_name\_vpc\_id](#input\_ssm\_parameter\_name\_vpc\_id) | Enter the SSM Parameter name for the vpc\_id. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the created ElastiCache Cluster |
| <a name="output_cache_nodes"></a> [cache\_nodes](#output\_cache\_nodes) | List of node objects |
| <a name="output_cluster_address"></a> [cluster\_address](#output\_cluster\_address) | DNS name of the cache cluster without the port appended. |
| <a name="output_configuration_endpoint"></a> [configuration\_endpoint](#output\_configuration\_endpoint) | Configuration endpoint to allow host discovery. |
| <a name="output_engine_version_actual"></a> [engine\_version\_actual](#output\_engine\_version\_actual) | The running version of the cache engine. |
| <a name="output_parameter_group_arn"></a> [parameter\_group\_arn](#output\_parameter\_group\_arn) | The AWS ARN associated with the parameter group. |
| <a name="output_parameter_group_id"></a> [parameter\_group\_id](#output\_parameter\_group\_id) | The ElastiCache parameter group name. |
| <a name="output_parameter_group_tags_all"></a> [parameter\_group\_tags\_all](#output\_parameter\_group\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |
| <a name="output_subnet_group_description"></a> [subnet\_group\_description](#output\_subnet\_group\_description) | The Description of the ElastiCache Subnet Group. |
| <a name="output_subnet_group_name"></a> [subnet\_group\_name](#output\_subnet\_group\_name) | The Name of the ElastiCache Subnet Group |
| <a name="output_subnet_group_subnet_ids"></a> [subnet\_group\_subnet\_ids](#output\_subnet\_group\_subnet\_ids) | The Subnet IDs of the ElastiCache Subnet Group |
| <a name="output_subnet_group_tags_all"></a> [subnet\_group\_tags\_all](#output\_subnet\_group\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider |

<!-- END_TF_DOCS -->