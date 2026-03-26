<!-- BEGIN_TF_DOCS -->
# AWS Redshift

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.9 |

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
| <a name="module_cluster"></a> [cluster](#module\_cluster) | ../../ | n/a |
| <a name="module_cluster_roles"></a> [cluster\_roles](#module\_cluster\_roles) | ../../modules/cluster_iam_roles | n/a |
| <a name="module_parameter_group"></a> [parameter\_group](#module\_parameter\_group) | ../../modules/parameter_group | n/a |
| <a name="module_redshift_iam_role"></a> [redshift\_iam\_role](#module\_redshift\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_redshift_subnet_group"></a> [redshift\_subnet\_group](#module\_redshift\_subnet\_group) | ../../modules/subnet_group | n/a |
| <a name="module_scheduled_action"></a> [scheduled\_action](#module\_scheduled\_action) | ../../modules/scheduled_actions | n/a |
| <a name="module_scheduled_actions_iam_role"></a> [scheduled\_actions\_iam\_role](#module\_scheduled\_actions\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_security_group_redshift"></a> [security\_group\_redshift](#module\_security\_group\_redshift) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_password.redshift_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.redshift_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.redshift_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.redshift_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

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
| <a name="input_classic"></a> [classic](#input\_classic) | A boolean value indicating whether the resize operation is using the classic resize process. | `bool` | n/a | yes |
| <a name="input_cluster_role_service"></a> [cluster\_role\_service](#input\_cluster\_role\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_cluster_type"></a> [cluster\_type](#input\_cluster\_type) | The cluster type to use. Either single-node or multi-node | `string` | `null` | no |
| <a name="input_create_duration"></a> [create\_duration](#input\_create\_duration) | Time duration to delay resource creation. For example, 30s for 30 seconds or 5m for 5 minutes. Updating this value by itself will not trigger a delay. | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Redshift parameter group. | `string` | n/a | yes |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | The node type to be provisioned for the cluster. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_parameter_vpc_id_name"></a> [parameter\_vpc\_id\_name](#input\_parameter\_vpc\_id\_name) | Id of vpc stored in aws\_ssm\_parameter | `string` | n/a | yes |
| <a name="input_pause_cluster_schedule"></a> [pause\_cluster\_schedule](#input\_pause\_cluster\_schedule) | The schedule of action.The schedule is defined format of 'at expression' or 'cron expression', for example at(2016-03-04T17:27:00) or cron(0 10 ? * MON *). | `string` | n/a | yes |
| <a name="input_resize_cluster_schedule"></a> [resize\_cluster\_schedule](#input\_resize\_cluster\_schedule) | The schedule of action.The schedule is defined format of 'at expression' or 'cron expression', for example at(2016-03-04T17:27:00) or cron(0 10 ? * MON *). | `string` | n/a | yes |
| <a name="input_resize_cluster_type"></a> [resize\_cluster\_type](#input\_resize\_cluster\_type) | The new cluster type for the specified cluster. | `string` | n/a | yes |
| <a name="input_resize_node_type"></a> [resize\_node\_type](#input\_resize\_node\_type) | The new node type for the nodes you are adding. | `string` | n/a | yes |
| <a name="input_resize_number_of_nodes"></a> [resize\_number\_of\_nodes](#input\_resize\_number\_of\_nodes) | The new number of nodes for the cluster. | `number` | n/a | yes |
| <a name="input_resume_cluster_schedule"></a> [resume\_cluster\_schedule](#input\_resume\_cluster\_schedule) | The schedule of action.The schedule is defined format of 'at expression' or 'cron expression', for example at(2016-03-04T17:27:00) or cron(0 10 ? * MON *). | `string` | n/a | yes |
| <a name="input_role_service"></a> [role\_service](#input\_role\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | The prefix applied to the log file names. | `string` | n/a | yes |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | The schedule of action.The schedule is defined format of 'at expression' or 'cron expression', for example at(2016-03-04T17:27:00) or cron(0 10 ? * MON *). | `string` | n/a | yes |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final snapshot of the cluster is created before Amazon Redshift deletes the cluster. | `bool` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | enter the value of subnet id2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | enter the value of subnet id3 stored in ssm parameter | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | Amazon Resource Name (ARN) of cluster. |
| <a name="output_cluster_automated_snapshot_retention_period"></a> [cluster\_automated\_snapshot\_retention\_period](#output\_cluster\_automated\_snapshot\_retention\_period) | The backup retention period. |
| <a name="output_cluster_availability_zone"></a> [cluster\_availability\_zone](#output\_cluster\_availability\_zone) | The availability zone of the Cluster. |
| <a name="output_cluster_cluster_identifier"></a> [cluster\_cluster\_identifier](#output\_cluster\_cluster\_identifier) | The Cluster Identifier. |
| <a name="output_cluster_cluster_nodes"></a> [cluster\_cluster\_nodes](#output\_cluster\_cluster\_nodes) | The nodes in the cluster. Cluster node blocks are documented below. |
| <a name="output_cluster_cluster_parameter_group_name"></a> [cluster\_cluster\_parameter\_group\_name](#output\_cluster\_cluster\_parameter\_group\_name) | The name of the parameter group to be associated with this cluster. |
| <a name="output_cluster_cluster_public_key"></a> [cluster\_cluster\_public\_key](#output\_cluster\_cluster\_public\_key) | The public key for the cluster. |
| <a name="output_cluster_cluster_revision_number"></a> [cluster\_cluster\_revision\_number](#output\_cluster\_cluster\_revision\_number) | The specific revision number of the database in the cluster. |
| <a name="output_cluster_cluster_subnet_group_name"></a> [cluster\_cluster\_subnet\_group\_name](#output\_cluster\_cluster\_subnet\_group\_name) | The name of a cluster subnet group to be associated with this cluster. |
| <a name="output_cluster_cluster_type"></a> [cluster\_cluster\_type](#output\_cluster\_cluster\_type) | The cluster type. |
| <a name="output_cluster_cluster_version"></a> [cluster\_cluster\_version](#output\_cluster\_cluster\_version) | The version of Redshift engine software. |
| <a name="output_cluster_database_name"></a> [cluster\_database\_name](#output\_cluster\_database\_name) | The name of the default database in the Cluster. |
| <a name="output_cluster_dns_name"></a> [cluster\_dns\_name](#output\_cluster\_dns\_name) | The DNS name of the cluster. |
| <a name="output_cluster_encrypted"></a> [cluster\_encrypted](#output\_cluster\_encrypted) | Whether the data in the cluster is encrypted. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | The connection endpoint. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The Redshift Cluster ID. |
| <a name="output_cluster_node_type"></a> [cluster\_node\_type](#output\_cluster\_node\_type) | The type of nodes in the cluster. |
| <a name="output_cluster_port"></a> [cluster\_port](#output\_cluster\_port) | The Port the cluster responds on. |
| <a name="output_cluster_preferred_maintenance_window"></a> [cluster\_preferred\_maintenance\_window](#output\_cluster\_preferred\_maintenance\_window) | The backup window. |
| <a name="output_cluster_tags_all"></a> [cluster\_tags\_all](#output\_cluster\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_cluster_vpc_security_group_ids"></a> [cluster\_vpc\_security\_group\_ids](#output\_cluster\_vpc\_security\_group\_ids) | The VPC security group Ids associated with the cluster. |
| <a name="output_parameter_group_arn"></a> [parameter\_group\_arn](#output\_parameter\_group\_arn) | Amazon Resource Name (ARN) of parameter group. |
| <a name="output_parameter_group_id"></a> [parameter\_group\_id](#output\_parameter\_group\_id) | The Redshift parameter group name. |
| <a name="output_redshift_subnet_group_arn"></a> [redshift\_subnet\_group\_arn](#output\_redshift\_subnet\_group\_arn) | Amazon Resource Name (ARN) of the Redshift Subnet group name |
| <a name="output_redshift_subnet_group_id"></a> [redshift\_subnet\_group\_id](#output\_redshift\_subnet\_group\_id) | The Redshift Subnet group ID. |
| <a name="output_redshift_subnet_group_tags_all"></a> [redshift\_subnet\_group\_tags\_all](#output\_redshift\_subnet\_group\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_scheduled_action"></a> [scheduled\_action](#output\_scheduled\_action) | The Redshift Scheduled Action name. |

<!-- END_TF_DOCS -->