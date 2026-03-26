<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
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
| <a name="module_emr_instance_fleet"></a> [emr\_instance\_fleet](#module\_emr\_instance\_fleet) | ../.. | n/a |
| <a name="module_emr_vpc_endpoint"></a> [emr\_vpc\_endpoint](#module\_emr\_vpc\_endpoint) | app.terraform.io/pgetech/vpc-endpoint/aws | n/a |
| <a name="module_s3_logbucket"></a> [s3\_logbucket](#module\_s3\_logbucket) | app.terraform.io/pgetech/s3/aws | 0.1.3 |
| <a name="module_s3_vpc_endpoint"></a> [s3\_vpc\_endpoint](#module\_s3\_vpc\_endpoint) | app.terraform.io/pgetech/vpc-endpoint/aws//modules/vpce_gateway | 0.1.1 |
| <a name="module_sts_vpc_endpoint"></a> [sts\_vpc\_endpoint](#module\_sts\_vpc\_endpoint) | app.terraform.io/pgetech/vpc-endpoint/aws | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |
| <a name="module_vpc_endpoints_sg"></a> [vpc\_endpoints\_sg](#module\_vpc\_endpoints\_sg) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.subnet1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.subnet2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.subnet3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

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
| <a name="input_applications"></a> [applications](#input\_applications) | A case-insensitive list of applications for Amazon EMR to install and configure when launching the cluster | `list(string)` | `[]` | no |
| <a name="input_auto_termination_policy"></a> [auto\_termination\_policy](#input\_auto\_termination\_policy) | An auto-termination policy for an Amazon EMR cluster. An auto-termination policy defines the amount of idle time in seconds after which a cluster automatically terminates | <pre>object({<br/>    idle_timeout = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_bootstrap_action"></a> [bootstrap\_action](#input\_bootstrap\_action) | Map of EMR bootstrap actions with name, path, and arguments | <pre>map(object({<br/>    path = string<br/>    name = string<br/>    args = optional(list(string))<br/>  }))</pre> | `null` | no |
| <a name="input_configurations_json"></a> [configurations\_json](#input\_configurations\_json) | JSON string for supplying list of configurations for the EMR cluster | `string` | `null` | no |
| <a name="input_core_instance_fleet"></a> [core\_instance\_fleet](#input\_core\_instance\_fleet) | Configuration block to use an [Instance Fleet](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html) for the core node type. Cannot be specified if any `core_instance_group` configuration blocks are set | `any` | `null` | no |
| <a name="input_ebs_root_volume_size"></a> [ebs\_root\_volume\_size](#input\_ebs\_root\_volume\_size) | Size in GiB of the EBS root device volume of the Linux AMI that is used for each EC2 instance. Available in Amazon EMR version 4.x and later | `number` | `null` | no |
| <a name="input_ec2_attributes"></a> [ec2\_attributes](#input\_ec2\_attributes) | Attributes for the Amazon EC2 instances running the EMR job flow. | <pre>object({<br/>    additional_master_security_groups = optional(string)<br/>    additional_slave_security_groups  = optional(string)<br/>    emr_managed_master_security_group = optional(string)<br/>    emr_managed_slave_security_group  = optional(string)<br/>    instance_profile                  = optional(string)<br/>    key_name                          = optional(string)<br/>    service_access_security_group     = optional(string)<br/>    subnet_id                         = optional(string)<br/>    subnet_ids                        = optional(list(string))<br/>  })</pre> | `{}` | no |
| <a name="input_iam_instance_profile_policies"></a> [iam\_instance\_profile\_policies](#input\_iam\_instance\_profile\_policies) | Map of IAM policies to attach to the EC2 IAM role/instance profile | `map(string)` | `{}` | no |
| <a name="input_instance_profile"></a> [instance\_profile](#input\_instance\_profile) | IAM instance profile name for EC2 instances | `string` | `"EMR_EC2_DefaultRole"` | no |
| <a name="input_keep_job_flow_alive_when_no_steps"></a> [keep\_job\_flow\_alive\_when\_no\_steps](#input\_keep\_job\_flow\_alive\_when\_no\_steps) | Switch on/off run cluster with no steps or when all steps are complete (default is on) | `bool` | `null` | no |
| <a name="input_list_steps_states"></a> [list\_steps\_states](#input\_list\_steps\_states) | List of [step states](https://docs.aws.amazon.com/emr/latest/APIReference/API_StepStatus.html) used to filter returned steps | `list(string)` | `[]` | no |
| <a name="input_log_uri"></a> [log\_uri](#input\_log\_uri) | S3 bucket to write the log files of the job flow. If a value is not provided, logs are not created | `string` | `null` | no |
| <a name="input_master_instance_fleet"></a> [master\_instance\_fleet](#input\_master\_instance\_fleet) | Configuration block to use an [Instance Fleet](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html) for the master node type. Cannot be specified if any `master_instance_group` configuration blocks are set | <pre>object({<br/>    name                       = optional(string)<br/>    target_on_demand_capacity = optional(number)<br/>    target_spot_capacity      = optional(number)<br/><br/>    instance_type_configs = optional(list(object({<br/>      instance_type                             = string<br/>      weighted_capacity                         = optional(number)<br/>      bid_price                                 = optional(string)<br/>      bid_price_as_percentage_of_on_demand_price = optional(number)<br/><br/>      configurations = optional(list(object({<br/>        classification = optional(string)<br/>        properties     = optional(map(string))<br/>      })))<br/><br/>      ebs_config = optional(list(object({<br/>        iops                 = optional(number)<br/>        size                 = optional(number)<br/>        type                 = optional(string)<br/>        volumes_per_instance = optional(number)<br/>      })))<br/>    })))<br/><br/>    launch_specifications = optional(object({<br/>      on_demand_specification = optional(object({<br/>        allocation_strategy = optional(string)<br/>      }))<br/>      spot_specification = optional(object({<br/>        allocation_strategy      = optional(string)<br/>        block_duration_minutes   = optional(number)<br/>        timeout_action           = optional(string)<br/>        timeout_duration_minutes = optional(number)<br/>      }))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the job flow | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags for resources | `map(string)` | `{}` | no |
| <a name="input_private_dns_enabled_emr"></a> [private\_dns\_enabled\_emr](#input\_private\_dns\_enabled\_emr) | Whether or not to associate a private hosted zone with the specified VPC | `bool` | n/a | yes |
| <a name="input_private_dns_enabled_sts"></a> [private\_dns\_enabled\_sts](#input\_private\_dns\_enabled\_sts) | Whether or not to associate a private hosted zone with the specified VPC | `bool` | n/a | yes |
| <a name="input_release_label_filters"></a> [release\_label\_filters](#input\_release\_label\_filters) | Map of release label filters used to lookup a release label | <pre>map(object({<br/>    application = optional(string)<br/>    prefix      = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_route_table_ids"></a> [route\_table\_ids](#input\_route\_table\_ids) | The route table ids | `list(any)` | `null` | no |
| <a name="input_scale_down_behavior"></a> [scale\_down\_behavior](#input\_scale\_down\_behavior) | Way that individual Amazon EC2 instances terminate when an automatic scale-in activity occurs or an instance group is resized | `string` | `"TERMINATE_AT_TASK_COMPLETION"` | no |
| <a name="input_service_iam_role_policies"></a> [service\_iam\_role\_policies](#input\_service\_iam\_role\_policies) | Map of IAM policies to attach to the EMR service role | `map(string)` | `{}` | no |
| <a name="input_service_name_emr"></a> [service\_name\_emr](#input\_service\_name\_emr) | The service name.For AWS services the service name is usually in the form com.amazonaws.<region>.<service>.The SageMaker Notebook service is an exception to this rule, the service name is in the form aws.sagemaker.<region>.notebook | `string` | `null` | no |
| <a name="input_service_name_s3"></a> [service\_name\_s3](#input\_service\_name\_s3) | The service name.For AWS services the service name is usually in the form com.amazonaws.<region>.<service>.The SageMaker Notebook service is an exception to this rule, the service name is in the form aws.sagemaker.<region>.notebook | `string` | `null` | no |
| <a name="input_service_name_sts"></a> [service\_name\_sts](#input\_service\_name\_sts) | The service name.For AWS services the service name is usually in the form com.amazonaws.<region>.<service>.The SageMaker Notebook service is an exception to this rule, the service name is in the form aws.sagemaker.<region>.notebook | `string` | `null` | no |
| <a name="input_step_concurrency_level"></a> [step\_concurrency\_level](#input\_step\_concurrency\_level) | Number of steps that can be executed concurrently. You can specify a maximum of 256 steps. Only valid for EMR clusters with `release_label` 5.28.0 or greater (default is 1) | `number` | `null` | no |
| <a name="input_subnet_id1_name"></a> [subnet\_id1\_name](#input\_subnet\_id1\_name) | The name given in the parameter store for the subnet id 1 | `string` | n/a | yes |
| <a name="input_subnet_id2_name"></a> [subnet\_id2\_name](#input\_subnet\_id2\_name) | The name given in the parameter store for the subnet id 2 | `string` | n/a | yes |
| <a name="input_subnet_id3_name"></a> [subnet\_id3\_name](#input\_subnet\_id3\_name) | The name given in the parameter store for the subnet id 3 | `string` | n/a | yes |
| <a name="input_task_instance_fleet"></a> [task\_instance\_fleet](#input\_task\_instance\_fleet) | Configuration block to use an [Instance Fleet](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html) for the task node type. Cannot be specified if any `task_instance_group` configuration blocks are set | <pre>object({<br/>    name                      = optional(string)<br/>    target_on_demand_capacity = optional(number)<br/>    target_spot_capacity      = optional(number)<br/><br/>    instance_type_configs = optional(list(object({<br/>      instance_type                              = string<br/>      weighted_capacity                          = optional(number)<br/>      bid_price                                  = optional(string)<br/>      bid_price_as_percentage_of_on_demand_price = optional(number)<br/><br/>      configurations = optional(list(object({<br/>        classification = optional(string)<br/>        properties     = optional(map(string))<br/>      })))<br/><br/>      ebs_config = optional(list(object({<br/>        iops                 = optional(number)<br/>        size                 = optional(number)<br/>        type                 = optional(string)<br/>        volumes_per_instance = optional(number)<br/>      })))<br/>    })))<br/><br/>    launch_specifications = optional(object({<br/>      on_demand_specification = optional(object({<br/>        allocation_strategy = optional(string)<br/>      }))<br/>      spot_specification = optional(object({<br/>        allocation_strategy      = optional(string)<br/>        block_duration_minutes   = optional(number)<br/>        timeout_action           = optional(string)<br/>        timeout_duration_minutes = optional(number)<br/>      }))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_termination_protection"></a> [termination\_protection](#input\_termination\_protection) | Switch on/off termination protection (default is `false`, except when using multiple master nodes). Before attempting to destroy the resource when termination protection is enabled, this configuration must be applied with its value set to `false` | `bool` | `null` | no |
| <a name="input_unhealthy_node_replacement"></a> [unhealthy\_node\_replacement](#input\_unhealthy\_node\_replacement) | Whether whether Amazon EMR should gracefully replace core nodes that have degraded within the cluster. Default value is `false` | `bool` | `null` | no |
| <a name="input_visible_to_all_users"></a> [visible\_to\_all\_users](#input\_visible\_to\_all\_users) | Whether the job flow is visible to all IAM users of the AWS account associated with the job flow. Default value is `true` | `bool` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Id of vpc stored in aws\_ssm\_parameter | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fleet_autoscaling_iam_role_arn"></a> [fleet\_autoscaling\_iam\_role\_arn](#output\_fleet\_autoscaling\_iam\_role\_arn) | Autoscaling IAM role ARN |
| <a name="output_fleet_autoscaling_iam_role_name"></a> [fleet\_autoscaling\_iam\_role\_name](#output\_fleet\_autoscaling\_iam\_role\_name) | Autoscaling IAM role name |
| <a name="output_fleet_autoscaling_iam_role_unique_id"></a> [fleet\_autoscaling\_iam\_role\_unique\_id](#output\_fleet\_autoscaling\_iam\_role\_unique\_id) | Stable and unique string identifying the autoscaling IAM role |
| <a name="output_fleet_cluster_arn"></a> [fleet\_cluster\_arn](#output\_fleet\_cluster\_arn) | The ARN of the cluster |
| <a name="output_fleet_cluster_core_instance_group_id"></a> [fleet\_cluster\_core\_instance\_group\_id](#output\_fleet\_cluster\_core\_instance\_group\_id) | Core node type Instance Group ID, if using Instance Group for this node type |
| <a name="output_fleet_cluster_id"></a> [fleet\_cluster\_id](#output\_fleet\_cluster\_id) | The ID of the cluster |
| <a name="output_fleet_cluster_master_instance_group_id"></a> [fleet\_cluster\_master\_instance\_group\_id](#output\_fleet\_cluster\_master\_instance\_group\_id) | Master node type Instance Group ID, if using Instance Group for this node type |
| <a name="output_fleet_cluster_master_public_dns"></a> [fleet\_cluster\_master\_public\_dns](#output\_fleet\_cluster\_master\_public\_dns) | The DNS name of the master node. If the cluster is on a private subnet, this is the private DNS name. On a public subnet, this is the public DNS name |
| <a name="output_fleet_iam_instance_profile_arn"></a> [fleet\_iam\_instance\_profile\_arn](#output\_fleet\_iam\_instance\_profile\_arn) | ARN assigned by AWS to the instance profile |
| <a name="output_fleet_iam_instance_profile_iam_role_arn"></a> [fleet\_iam\_instance\_profile\_iam\_role\_arn](#output\_fleet\_iam\_instance\_profile\_iam\_role\_arn) | Instance profile IAM role ARN |
| <a name="output_fleet_iam_instance_profile_iam_role_name"></a> [fleet\_iam\_instance\_profile\_iam\_role\_name](#output\_fleet\_iam\_instance\_profile\_iam\_role\_name) | Instance profile IAM role name |
| <a name="output_fleet_iam_instance_profile_iam_role_unique_id"></a> [fleet\_iam\_instance\_profile\_iam\_role\_unique\_id](#output\_fleet\_iam\_instance\_profile\_iam\_role\_unique\_id) | Stable and unique string identifying the instance profile IAM role |
| <a name="output_fleet_iam_instance_profile_id"></a> [fleet\_iam\_instance\_profile\_id](#output\_fleet\_iam\_instance\_profile\_id) | Instance profile's ID |
| <a name="output_fleet_iam_instance_profile_unique"></a> [fleet\_iam\_instance\_profile\_unique](#output\_fleet\_iam\_instance\_profile\_unique) | Stable and unique string identifying the IAM instance profile |
| <a name="output_fleet_managed_master_security_group_arn"></a> [fleet\_managed\_master\_security\_group\_arn](#output\_fleet\_managed\_master\_security\_group\_arn) | Amazon Resource Name (ARN) of the managed master security group |
| <a name="output_fleet_managed_master_security_group_id"></a> [fleet\_managed\_master\_security\_group\_id](#output\_fleet\_managed\_master\_security\_group\_id) | ID of the managed master security group |
| <a name="output_fleet_managed_service_access_security_group_arn"></a> [fleet\_managed\_service\_access\_security\_group\_arn](#output\_fleet\_managed\_service\_access\_security\_group\_arn) | Amazon Resource Name (ARN) of the managed service access security group |
| <a name="output_fleet_managed_service_access_security_group_id"></a> [fleet\_managed\_service\_access\_security\_group\_id](#output\_fleet\_managed\_service\_access\_security\_group\_id) | ID of the managed service access security group |
| <a name="output_fleet_managed_slave_security_group_arn"></a> [fleet\_managed\_slave\_security\_group\_arn](#output\_fleet\_managed\_slave\_security\_group\_arn) | Amazon Resource Name (ARN) of the managed slave security group |
| <a name="output_fleet_managed_slave_security_group_id"></a> [fleet\_managed\_slave\_security\_group\_id](#output\_fleet\_managed\_slave\_security\_group\_id) | ID of the managed slave security group |
| <a name="output_fleet_security_configuration_id"></a> [fleet\_security\_configuration\_id](#output\_fleet\_security\_configuration\_id) | The ID of the security configuration |
| <a name="output_fleet_security_configuration_name"></a> [fleet\_security\_configuration\_name](#output\_fleet\_security\_configuration\_name) | The name of the security configuration |
| <a name="output_fleet_service_iam_role_arn"></a> [fleet\_service\_iam\_role\_arn](#output\_fleet\_service\_iam\_role\_arn) | Service IAM role ARN |
| <a name="output_fleet_service_iam_role_name"></a> [fleet\_service\_iam\_role\_name](#output\_fleet\_service\_iam\_role\_name) | Service IAM role name |
| <a name="output_fleet_service_iam_role_unique_id"></a> [fleet\_service\_iam\_role\_unique\_id](#output\_fleet\_service\_iam\_role\_unique\_id) | Stable and unique string identifying the service IAM role |

<!-- END_TF_DOCS -->