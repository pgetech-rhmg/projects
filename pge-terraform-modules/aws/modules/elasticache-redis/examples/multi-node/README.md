<!-- BEGIN_TF_DOCS -->
# AWS Elasticache-redis module example
# Usage creation for Elasticache redis multinode cluster enabled cluster with replication and data partitioning.

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
| <a name="module_redis_multi_node"></a> [redis\_multi\_node](#module\_redis\_multi\_node) | ../../modules/elasticache-redis-multinode-cluster | n/a |
| <a name="module_security_group_redis"></a> [security\_group\_redis](#module\_security\_group\_redis) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.auth_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
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
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Whether any database modifications are applied immediately, or during the next maintenance window. | `bool` | `false` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create the resource.For CLOUDFRONT, you must create your WAFv2 resources in the us-east-1,(N. Virginia) Region. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role | `string` | n/a | yes |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    description      = string<br>    prefix_list_ids  = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_cidr_ingress_rules"></a> [cidr\_ingress\_rules](#input\_cidr\_ingress\_rules) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    description      = string<br>    prefix_list_ids  = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | Group identifier. ElastiCache converts this name to lowercase. Changing this value will re-create the resource. | `string` | n/a | yes |
| <a name="input_final_snapshot"></a> [final\_snapshot](#input\_final\_snapshot) | The name of your final snapshot when the replication group is deleted. | `string` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console | `string` | `"Parameter Store KMS master key"` | no |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_nodetype"></a> [nodetype](#input\_nodetype) | The instance class used. See AWS documentation for information on supported node types for Redis and guidance on selecting node types for Redis | `string` | n/a | yes |
| <a name="input_num_node_groups"></a> [num\_node\_groups](#input\_num\_node\_groups) | Number of node groups (shards) for this Redis replication group. Changing this number will trigger an online resizing operation before other settings modifications. Required unless global\_replication\_group\_id is set. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_redis_engine_version"></a> [redis\_engine\_version](#input\_redis\_engine\_version) | Version number of the cache engine to be used. If not set, defaults to the latest version. When the version is 6 or higher, the major and minor version can be set, e.g., 6.2, or the minor version can be unspecified which will use the latest version at creation time, e.g., 6.x. Otherwise, specify the full version desired, e.g., 5.0.6. The actual engine version used is returned in the attribute engine\_version\_actual. | `string` | `null` | no |
| <a name="input_replicas_per_node_group"></a> [replicas\_per\_node\_group](#input\_replicas\_per\_node\_group) | Number of replica nodes in each node group. Valid values are 0 to 5. Changing this number will trigger an online resizing operation before other settings modifications. | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | description for security group associated with lambda | `string` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | name of the security group associated with lambda | `string` | n/a | yes |
| <a name="input_slow_logs_log_delivery_destination"></a> [slow\_logs\_log\_delivery\_destination](#input\_slow\_logs\_log\_delivery\_destination) | Name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource | `string` | n/a | yes |
| <a name="input_slow_logs_log_delivery_destination_type"></a> [slow\_logs\_log\_delivery\_destination\_type](#input\_slow\_logs\_log\_delivery\_destination\_type) | For CloudWatch Logs use cloudwatch-logs or for Kinesis Data Firehose use kinesis-firehose | `string` | n/a | yes |
| <a name="input_slow_logs_log_delivery_log_format"></a> [slow\_logs\_log\_delivery\_log\_format](#input\_slow\_logs\_log\_delivery\_log\_format) | Valid values are json or text | `string` | n/a | yes |
| <a name="input_ssm_parameter_name_auth_token"></a> [ssm\_parameter\_name\_auth\_token](#input\_ssm\_parameter\_name\_auth\_token) | Enter the SSM parameter name for the auth\_token. Auth\_token is the password used to access a password protected server. | `string` | n/a | yes |
| <a name="input_ssm_parameter_name_private_subnet1"></a> [ssm\_parameter\_name\_private\_subnet1](#input\_ssm\_parameter\_name\_private\_subnet1) | Enter the SSM Parameter name for the private subnet id-1. | `string` | n/a | yes |
| <a name="input_ssm_parameter_name_private_subnet2"></a> [ssm\_parameter\_name\_private\_subnet2](#input\_ssm\_parameter\_name\_private\_subnet2) | Enter the SSM Parameter name for the private subnet id-2. | `string` | n/a | yes |
| <a name="input_ssm_parameter_name_vpc_id"></a> [ssm\_parameter\_name\_vpc\_id](#input\_ssm\_parameter\_name\_vpc\_id) | Enter the SSM Parameter name for the vpc\_id. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_parameter_group_arn"></a> [parameter\_group\_arn](#output\_parameter\_group\_arn) | The AWS ARN associated with the parameter group. |
| <a name="output_parameter_group_id"></a> [parameter\_group\_id](#output\_parameter\_group\_id) | The ElastiCache parameter group name. |
| <a name="output_parameter_group_tags_all"></a> [parameter\_group\_tags\_all](#output\_parameter\_group\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |
| <a name="output_replication_group_arn"></a> [replication\_group\_arn](#output\_replication\_group\_arn) | ARN of the created ElastiCache Replication Group. |
| <a name="output_replication_group_cluster_enabled"></a> [replication\_group\_cluster\_enabled](#output\_replication\_group\_cluster\_enabled) | Indicates if cluster mode is enabled. |
| <a name="output_replication_group_configuration_endpoint_address"></a> [replication\_group\_configuration\_endpoint\_address](#output\_replication\_group\_configuration\_endpoint\_address) | Address of the replication group configuration endpoint when cluster mode is enabled. |
| <a name="output_replication_group_engine_version_actual"></a> [replication\_group\_engine\_version\_actual](#output\_replication\_group\_engine\_version\_actual) | Running version of the cache engine. |
| <a name="output_replication_group_id"></a> [replication\_group\_id](#output\_replication\_group\_id) | ID of the ElastiCache Replication Group. |
| <a name="output_replication_group_member_clusters"></a> [replication\_group\_member\_clusters](#output\_replication\_group\_member\_clusters) | Identifiers of all the nodes that are part of this replication group. |
| <a name="output_replication_group_primary_endpoint_address"></a> [replication\_group\_primary\_endpoint\_address](#output\_replication\_group\_primary\_endpoint\_address) | Address of the endpoint for the primary node in the replication group, if the cluster mode is disabled. |
| <a name="output_replication_group_reader_endpoint_address"></a> [replication\_group\_reader\_endpoint\_address](#output\_replication\_group\_reader\_endpoint\_address) | Address of the endpoint for the reader node in the replication group, if the cluster mode is disabled. |
| <a name="output_replication_group_tags_all"></a> [replication\_group\_tags\_all](#output\_replication\_group\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_subnet_group_description"></a> [subnet\_group\_description](#output\_subnet\_group\_description) | The Description of the ElastiCache Subnet Group. |
| <a name="output_subnet_group_name"></a> [subnet\_group\_name](#output\_subnet\_group\_name) | The Name of the ElastiCache Subnet Group |
| <a name="output_subnet_group_subnet_ids"></a> [subnet\_group\_subnet\_ids](#output\_subnet\_group\_subnet\_ids) | The Subnet IDs of the ElastiCache Subnet Group |
| <a name="output_subnet_group_tags_all"></a> [subnet\_group\_tags\_all](#output\_subnet\_group\_tags\_all) | A map of tags assigned to the resource |

<!-- END_TF_DOCS -->