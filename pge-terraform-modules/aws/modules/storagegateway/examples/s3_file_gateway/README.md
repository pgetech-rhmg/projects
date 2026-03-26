<!-- BEGIN_TF_DOCS -->
# AWS storagegateway s3\_file\_gateway Example
Prerequisites :
To generate activation key for the storage gateway.
Step-1: Create one EC2 instance with the ami "ami-0aa80e1f5cd5b99be" (gateway instance).
Step-2: Create another EC2 instance to connect (SSH) with the gateway instance to generate the activation key.
Step-3: After doing SSH, in gateway instance select appropriate options to generate activation key.
Step-4: Once the activation key is generated store the value in ssm parameter store (ssm\_parameter\_activation\_key).
Testing status:
This example is tested in the AWS console. Steps in the prerequisites are followed during testing.
# Terraform module example usage for storagegateway s3\_file\_gateway

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
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

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
| <a name="module_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#module\_cloudwatch\_log\_group) | app.terraform.io/pgetech/cloudwatch/aws//modules/log-group | 0.1.3 |
| <a name="module_nfs_file_share"></a> [nfs\_file\_share](#module\_nfs\_file\_share) | ../../modules/nfs_file_share | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_s3_filesystem"></a> [s3\_filesystem](#module\_s3\_filesystem) | ../../ | n/a |
| <a name="module_s3_filesystem_cache"></a> [s3\_filesystem\_cache](#module\_s3\_filesystem\_cache) | ../../modules/cache | n/a |
| <a name="module_secretsmanager"></a> [secretsmanager](#module\_secretsmanager) | app.terraform.io/pgetech/secretsmanager/aws | 0.1.3 |
| <a name="module_storagegateway_iam_role"></a> [storagegateway\_iam\_role](#module\_storagegateway\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.allow_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_secretsmanager_secret.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.secrets_activation_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssm_parameter.activation_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_storagegateway_local_disk.cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/storagegateway_local_disk) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_cache_stale_timeout_in_seconds"></a> [cache\_stale\_timeout\_in\_seconds](#input\_cache\_stale\_timeout\_in\_seconds) | Refreshes a file share's cache by using Time To Live (TTL). TTL is the length of time since the last refresh after which access to the directory would cause the file gateway to first refresh that directory's contents from the Amazon S3 bucket. Valid Values: 300 to 2,592,000 seconds (5 minutes to 30 days). | `number` | n/a | yes |
| <a name="input_client_list"></a> [client\_list](#input\_client\_list) | The list of clients that are allowed to access the file gateway. The list must contain either valid IP addresses or valid CIDR blocks. Set to ['0.0.0.0/0'] to not limit access. Minimum 1 item. Maximum 100 items. | `list(any)` | n/a | yes |
| <a name="input_day_of_month"></a> [day\_of\_month](#input\_day\_of\_month) | The day of the month component of the maintenance start time represented as an ordinal number from 1 to 28, where 1 represents the first day of the month and 28 represents the last day of the month. | `number` | n/a | yes |
| <a name="input_day_of_week"></a> [day\_of\_week](#input\_day\_of\_week) | The day of the week component of the maintenance start time week represented as an ordinal number from 0 to 6, where 0 represents Sunday and 6 Saturday. | `number` | n/a | yes |
| <a name="input_directory_mode"></a> [directory\_mode](#input\_directory\_mode) | The Unix directory mode in the string form nnnn. | `string` | n/a | yes |
| <a name="input_disk_node"></a> [disk\_node](#input\_disk\_node) | Device node of the local disk to retrieve. | `string` | n/a | yes |
| <a name="input_file_mode"></a> [file\_mode](#input\_file\_mode) | The Unix file mode in the string form nnnn. | `string` | n/a | yes |
| <a name="input_gateway_timezone"></a> [gateway\_timezone](#input\_gateway\_timezone) | Time zone for the gateway. The time zone is of the format 'GMT', 'GMT-hr:mm', or 'GMT+hr:mm'. For example, GMT-4:00 indicates the time is 4 hours behind GMT. The time zone is used, for example, for scheduling snapshots and your gateway's maintenance schedule. | `string` | n/a | yes |
| <a name="input_gateway_type"></a> [gateway\_type](#input\_gateway\_type) | Type of the gateway. The default value is STORED. | `string` | n/a | yes |
| <a name="input_gateway_vpc_endpoint"></a> [gateway\_vpc\_endpoint](#input\_gateway\_vpc\_endpoint) | VPC endpoint address to be used when activating your gateway. This should be used when your instance is in a private subnet. Requires HTTP access from client computer running terraform. | `string` | n/a | yes |
| <a name="input_group_id"></a> [group\_id](#input\_group\_id) | The default group ID for the file share (unless the files have another group ID specified). | `number` | n/a | yes |
| <a name="input_hour_of_day"></a> [hour\_of\_day](#input\_hour\_of\_day) | The hour component of the maintenance start time represented as hh, where hh is the hour (00 to 23). The hour of the day is in the time zone of the gateway. | `number` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS kms role to assume | `string` | n/a | yes |
| <a name="input_logs_name"></a> [logs\_name](#input\_logs\_name) | To identify the log group name | `string` | n/a | yes |
| <a name="input_minute_of_hour"></a> [minute\_of\_hour](#input\_minute\_of\_hour) | The minute component of the maintenance start time represented as mm, where mm is the minute (00 to 59). The minute of the hour is in the time zone of the gateway. | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the gateway. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_owner_id"></a> [owner\_id](#input\_owner\_id) | he default owner ID for the file share (unless the files have another owner ID specified). | `number` | n/a | yes |
| <a name="input_recovery_window_in_days"></a> [recovery\_window\_in\_days](#input\_recovery\_window\_in\_days) | Number of days that AWS Secrets Manager waits before it can delete the secret | `number` | `30` | no |
| <a name="input_secret_version_enabled"></a> [secret\_version\_enabled](#input\_secret\_version\_enabled) | Specifies if versioning is set or not | `bool` | n/a | yes |
| <a name="input_secretsmanager_description"></a> [secretsmanager\_description](#input\_secretsmanager\_description) | Description of the secret | `string` | n/a | yes |
| <a name="input_secretsmanager_name"></a> [secretsmanager\_name](#input\_secretsmanager\_name) | Name of the new secret | `string` | n/a | yes |
| <a name="input_ssm_parameter_activation_key"></a> [ssm\_parameter\_activation\_key](#input\_ssm\_parameter\_activation\_key) | enter the value of activation key stored in ssm parameter | `string` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | {<br>  create : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 10m"<br>  update : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 10m"<br>  delete : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 15m"<br>} | <pre>object({<br>    create = string<br>    update = string<br>    delete = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name (ARN) of the gateway. |
| <a name="output_cache_id"></a> [cache\_id](#output\_cache\_id) | Combined gateway Amazon Resource Name (ARN) and local disk identifier. |
| <a name="output_ec2_instance_id"></a> [ec2\_instance\_id](#output\_ec2\_instance\_id) | The ID of the Amazon EC2 instance that was used to launch the gateway. |
| <a name="output_endpoint_type"></a> [endpoint\_type](#output\_endpoint\_type) | The type of endpoint for your gateway. |
| <a name="output_gateway_id"></a> [gateway\_id](#output\_gateway\_id) | Identifier of the gateway. |
| <a name="output_gateway_network_interface"></a> [gateway\_network\_interface](#output\_gateway\_network\_interface) | An array that contains descriptions of the gateway network interfaces. |
| <a name="output_host_environment"></a> [host\_environment](#output\_host\_environment) | The type of hypervisor environment used by the host. |
| <a name="output_id"></a> [id](#output\_id) | Amazon Resource Name (ARN) of the gateway. |
| <a name="output_nfs_file_share_arn"></a> [nfs\_file\_share\_arn](#output\_nfs\_file\_share\_arn) | Amazon Resource Name (ARN) of the NFS File Share. |
| <a name="output_nfs_file_share_id"></a> [nfs\_file\_share\_id](#output\_nfs\_file\_share\_id) | Amazon Resource Name (ARN) of the NFS File Share. |
| <a name="output_nfs_fileshare_id"></a> [nfs\_fileshare\_id](#output\_nfs\_fileshare\_id) | ID of the NFS File Share. |
| <a name="output_nfs_path"></a> [nfs\_path](#output\_nfs\_path) | File share path used by the NFS client to identify the mount point. |
| <a name="output_nfs_tags_all"></a> [nfs\_tags\_all](#output\_nfs\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->