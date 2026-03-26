<!-- BEGIN_TF_DOCS -->
# AWS DMS with usage example
Terraform module which creates SAF2.0 dms resources in AWS.
Secrets key is a pre-requisite and must be existing to run this example.

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
| <a name="module_access_for_endpoint"></a> [access\_for\_endpoint](#module\_access\_for\_endpoint) | app.terraform.io/pgetech/iam/aws | 0.1.0 |
| <a name="module_cloudwatch_logs"></a> [cloudwatch\_logs](#module\_cloudwatch\_logs) | app.terraform.io/pgetech/iam/aws | 0.1.0 |
| <a name="module_dms_endpoint"></a> [dms\_endpoint](#module\_dms\_endpoint) | ../../modules/dms_endpoint_secrets | n/a |
| <a name="module_dms_event_subscription_one"></a> [dms\_event\_subscription\_one](#module\_dms\_event\_subscription\_one) | ../../modules/event_subscription | n/a |
| <a name="module_dms_replication_instance"></a> [dms\_replication\_instance](#module\_dms\_replication\_instance) | ../../modules/replication_instance | n/a |
| <a name="module_dms_replication_task"></a> [dms\_replication\_task](#module\_dms\_replication\_task) | ../.. | n/a |
| <a name="module_secrets_manager_access_iam_role"></a> [secrets\_manager\_access\_iam\_role](#module\_secrets\_manager\_access\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.0 |
| <a name="module_security_group_dms"></a> [security\_group\_dms](#module\_security\_group\_dms) | app.terraform.io/pgetech/security-group/aws | 0.1.0 |
| <a name="module_sns_topic"></a> [sns\_topic](#module\_sns\_topic) | app.terraform.io/pgetech/sns/aws | 0.1.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |
| <a name="module_vpc_dms"></a> [vpc\_dms](#module\_vpc\_dms) | app.terraform.io/pgetech/iam/aws | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
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
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role | `string` | n/a | yes |
| <a name="input_cidr_egress_rules_replication_instance"></a> [cidr\_egress\_rules\_replication\_instance](#input\_cidr\_egress\_rules\_replication\_instance) | variables for security\_group\_project | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_cidr_ingress_rules_replication_instance"></a> [cidr\_ingress\_rules\_replication\_instance](#input\_cidr\_ingress\_rules\_replication\_instance) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_event_categories"></a> [event\_categories](#input\_event\_categories) | List of event categories to listen for, see DescribeEventCategories for a canonical list. | `list(string)` | `null` | no |
| <a name="input_event_enabled"></a> [event\_enabled](#input\_event\_enabled) | Whether the event subscription should be enabled. | `bool` | `null` | no |
| <a name="input_event_name"></a> [event\_name](#input\_event\_name) | Name of event subscription. | `string` | n/a | yes |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | Policy arn for the iam role | `list(string)` | n/a | yes |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Enter the role name for access endpoints | `string` | n/a | yes |
| <a name="input_instance_allocated_storage"></a> [instance\_allocated\_storage](#input\_instance\_allocated\_storage) | The amount of storage (in gigabytes) to be initially allocated for the replication instance. | `number` | n/a | yes |
| <a name="input_instance_allow_major_version_upgrade"></a> [instance\_allow\_major\_version\_upgrade](#input\_instance\_allow\_major\_version\_upgrade) | (Optional, Default: false) Indicates that major version upgrades are allowed. | `bool` | `false` | no |
| <a name="input_instance_apply_immediately"></a> [instance\_apply\_immediately](#input\_instance\_apply\_immediately) | Indicates whether the changes should be applied immediately or during the next maintenance window. Only used when updating an existing resource. | `bool` | n/a | yes |
| <a name="input_instance_availability_zone"></a> [instance\_availability\_zone](#input\_instance\_availability\_zone) | The EC2 Availability Zone that the replication instance will be created in. | `string` | n/a | yes |
| <a name="input_instance_engine_version"></a> [instance\_engine\_version](#input\_instance\_engine\_version) | The engine version number of the replication instance. | `string` | n/a | yes |
| <a name="input_instance_multi_az"></a> [instance\_multi\_az](#input\_instance\_multi\_az) | Specifies if the replication instance is a multi-az deployment. You cannot set the availability\_zone parameter if the multi\_az parameter is set to true. | `bool` | n/a | yes |
| <a name="input_instance_preferred_maintenance"></a> [instance\_preferred\_maintenance](#input\_instance\_preferred\_maintenance) | The weekly time range during which system maintenance can occur, in Universal Coordinated Time (UTC). | `string` | n/a | yes |
| <a name="input_instance_publicly_accessible"></a> [instance\_publicly\_accessible](#input\_instance\_publicly\_accessible) | Specifies the accessibility options for the replication instance. A value of true represents an instance with a public IP address. A value of false represents an instance with a private IP address. | `bool` | n/a | yes |
| <a name="input_instance_replication_id"></a> [instance\_replication\_id](#input\_instance\_replication\_id) | The replication instance identifier. | `string` | n/a | yes |
| <a name="input_instance_replication_instance_class"></a> [instance\_replication\_instance\_class](#input\_instance\_replication\_instance\_class) | The compute and memory capacity of the replication instance as specified by the replication instance class. | `string` | n/a | yes |
| <a name="input_instance_version_upgrade"></a> [instance\_version\_upgrade](#input\_instance\_version\_upgrade) | Indicates that minor engine upgrades will be applied automatically to the replication instance during the maintenance window. | `bool` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console. | `string` | n/a | yes |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_migration_type"></a> [migration\_type](#input\_migration\_type) | The migration type. Can be one of full-load \| cdc \| full-load-and-cdc. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_replication_subnet_group_description"></a> [replication\_subnet\_group\_description](#input\_replication\_subnet\_group\_description) | The description for the subnet group. | `string` | n/a | yes |
| <a name="input_replication_subnet_group_id"></a> [replication\_subnet\_group\_id](#input\_replication\_subnet\_group\_id) | The name for the replication subnet group. This value is stored as a lowercase string. | `string` | n/a | yes |
| <a name="input_replication_task_id"></a> [replication\_task\_id](#input\_replication\_task\_id) | The replication task identifier.Must contain from 1 to 255 alphanumeric characters or hyphens.First character must be a letter.Cannot end with a hyphen.Cannot contain two consecutive hyphens. | `string` | n/a | yes |
| <a name="input_role_name_access_endpoint"></a> [role\_name\_access\_endpoint](#input\_role\_name\_access\_endpoint) | Enter the role name for access endpoints | `string` | n/a | yes |
| <a name="input_role_name_cloudwatch_logs"></a> [role\_name\_cloudwatch\_logs](#input\_role\_name\_cloudwatch\_logs) | Enter the role name for cloudwatch logs | `string` | n/a | yes |
| <a name="input_role_name_vpc"></a> [role\_name\_vpc](#input\_role\_name\_vpc) | Enter the role name for vpc | `string` | n/a | yes |
| <a name="input_role_service"></a> [role\_service](#input\_role\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_sg_description_replication_instance"></a> [sg\_description\_replication\_instance](#input\_sg\_description\_replication\_instance) | vpc id for security group | `string` | n/a | yes |
| <a name="input_sg_name_replication_instance"></a> [sg\_name\_replication\_instance](#input\_sg\_name\_replication\_instance) | name of the security group | `string` | n/a | yes |
| <a name="input_snstopic_display_name"></a> [snstopic\_display\_name](#input\_snstopic\_display\_name) | The display name of the SNS topic | `string` | n/a | yes |
| <a name="input_snstopic_name"></a> [snstopic\_name](#input\_snstopic\_name) | name of the SNS topic | `string` | n/a | yes |
| <a name="input_source_certificate_arn"></a> [source\_certificate\_arn](#input\_source\_certificate\_arn) | ARN of the source SSL certificate | `string` | n/a | yes |
| <a name="input_source_endpoint_database_name"></a> [source\_endpoint\_database\_name](#input\_source\_endpoint\_database\_name) | Name of the endpoint database. | `string` | n/a | yes |
| <a name="input_source_endpoint_engine_name"></a> [source\_endpoint\_engine\_name](#input\_source\_endpoint\_engine\_name) | Type of engine for the endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb,  mysql, opensearch, oracle, postgres, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift). | `string` | n/a | yes |
| <a name="input_source_endpoint_id"></a> [source\_endpoint\_id](#input\_source\_endpoint\_id) | Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens. | `string` | n/a | yes |
| <a name="input_source_endpoint_secrets_manager_arn"></a> [source\_endpoint\_secrets\_manager\_arn](#input\_source\_endpoint\_secrets\_manager\_arn) | Full ARN, partial ARN, or friendly name of the SecretsManagerSecret that contains the endpoint connection details. Supported only for engine\_name as aurora, aurora-postgresql, mariadb, mongodb, mysql, oracle, postgres, redshift or sqlserver. | `string` | n/a | yes |
| <a name="input_source_endpoint_ssl_mode"></a> [source\_endpoint\_ssl\_mode](#input\_source\_endpoint\_ssl\_mode) | SSL mode to use for the connection. Valid values are: none, require, verify-ca, verify-full. As per SAF, for each DMS endpoint where there is a port required, make sure the SSLMode is not 'None'. | `string` | n/a | yes |
| <a name="input_source_ids"></a> [source\_ids](#input\_source\_ids) | Ids of sources to listen to. | `list(string)` | n/a | yes |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | Type of source for events. Valid values: replication-instance or replication-task | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id\_1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | enter the value of subnet id\_2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | enter the value of subnet id\_3 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes |
| <a name="input_target_certificate_arn"></a> [target\_certificate\_arn](#input\_target\_certificate\_arn) | ARN of the target SSL certificate | `string` | n/a | yes |
| <a name="input_target_endpoint_database_name"></a> [target\_endpoint\_database\_name](#input\_target\_endpoint\_database\_name) | Name of the endpoint database. | `string` | n/a | yes |
| <a name="input_target_endpoint_engine_name"></a> [target\_endpoint\_engine\_name](#input\_target\_endpoint\_engine\_name) | Type of engine for the endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb,  mysql, opensearch, oracle, postgres, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift). | `string` | n/a | yes |
| <a name="input_target_endpoint_id"></a> [target\_endpoint\_id](#input\_target\_endpoint\_id) | Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens. | `string` | n/a | yes |
| <a name="input_target_endpoint_secrets_manager_arn"></a> [target\_endpoint\_secrets\_manager\_arn](#input\_target\_endpoint\_secrets\_manager\_arn) | Full ARN, partial ARN, or friendly name of the SecretsManagerSecret that contains the endpoint connection details. Supported only for engine\_name as aurora, aurora-postgresql, mariadb, mongodb, mysql, oracle, postgres, redshift or sqlserver. | `string` | n/a | yes |
| <a name="input_target_endpoint_ssl_mode"></a> [target\_endpoint\_ssl\_mode](#input\_target\_endpoint\_ssl\_mode) | SSL mode to use for the connection. Valid values are: none, require, verify-ca, verify-full. As per SAF, for each DMS endpoint where there is a port required, make sure the SSLMode is not 'None'. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dms_source_endpoint_arn"></a> [dms\_source\_endpoint\_arn](#output\_dms\_source\_endpoint\_arn) | ARN for the endpoint. |
| <a name="output_dms_source_endpoint_tags_all"></a> [dms\_source\_endpoint\_tags\_all](#output\_dms\_source\_endpoint\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_dms_target_endpoint_arn"></a> [dms\_target\_endpoint\_arn](#output\_dms\_target\_endpoint\_arn) | ARN for the endpoint. |
| <a name="output_dms_target_endpoint_tags_all"></a> [dms\_target\_endpoint\_tags\_all](#output\_dms\_target\_endpoint\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_event_subscription_arn"></a> [event\_subscription\_arn](#output\_event\_subscription\_arn) | ARN of the event subscription |
| <a name="output_replication_instance_arn"></a> [replication\_instance\_arn](#output\_replication\_instance\_arn) | The Amazon Resource Name (ARN) of the replication instance. |
| <a name="output_replication_instance_private_ips"></a> [replication\_instance\_private\_ips](#output\_replication\_instance\_private\_ips) | A list of the private IP addresses of the replication instance. |
| <a name="output_replication_task_arn"></a> [replication\_task\_arn](#output\_replication\_task\_arn) | The Amazon Resource Name (ARN) for the replication task. |
| <a name="output_replication_task_status"></a> [replication\_task\_status](#output\_replication\_task\_status) | Status of the replication task. |
| <a name="output_replication_task_tags_all"></a> [replication\_task\_tags\_all](#output\_replication\_task\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_vpc_id_replication_subnet_group"></a> [vpc\_id\_replication\_subnet\_group](#output\_vpc\_id\_replication\_subnet\_group) | The ID of the VPC the subnet group is in. |


<!-- END_TF_DOCS -->