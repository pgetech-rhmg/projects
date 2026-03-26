<!-- BEGIN_TF_DOCS -->
# AWS GLUE Job, Glue Connection, Glue Dev EndPoint, Glue Security Configuration and Glue Trigger with usage example
Terraform module which creates SAF2.0 Glue Job with Glue Connection, Glue Security Configuration Glue Dev Endpoint and Glue Trigger resources in AWS.
S3 VPC Gateway endpoint is a pre-requisite and must be existing to run this example.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

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
| <a name="module_Scheduled_glue_trigger"></a> [Scheduled\_glue\_trigger](#module\_Scheduled\_glue\_trigger) | ../../../glue/modules/glue-trigger/ | n/a |
| <a name="module_glue_connection"></a> [glue\_connection](#module\_glue\_connection) | ../../../glue/modules/glue-connection/ | n/a |
| <a name="module_glue_dev_endpoint"></a> [glue\_dev\_endpoint](#module\_glue\_dev\_endpoint) | ../../../glue/modules/dev-endpoint | n/a |
| <a name="module_glue_job"></a> [glue\_job](#module\_glue\_job) | ../../../glue | n/a |
| <a name="module_glue_job_iam_role"></a> [glue\_job\_iam\_role](#module\_glue\_job\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.0 |
| <a name="module_glue_security_configuration"></a> [glue\_security\_configuration](#module\_glue\_security\_configuration) | ../../../glue/modules/security-configuration/ | n/a |
| <a name="module_glue_trigger"></a> [glue\_trigger](#module\_glue\_trigger) | ../../../glue/modules/glue-trigger/ | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | app.terraform.io/pgetech/kms/aws | 0.1.0 |
| <a name="module_security_group_glue"></a> [security\_group\_glue](#module\_security\_group\_glue) | app.terraform.io/pgetech/security-group/aws | 0.1.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

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
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The availability zone for the glue connection. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_cidr_blocks"></a> [cidr\_blocks](#input\_cidr\_blocks) | List of CIDR blocks. | `list(string)` | n/a | yes |
| <a name="input_glue_connection_type"></a> [glue\_connection\_type](#input\_glue\_connection\_type) | The type of the connection. Supported are: JDBC, MONGODB, KAFKA, and NETWORK. Defaults to JBDC. | `string` | n/a | yes |
| <a name="input_glue_dev_endpoint_arguments"></a> [glue\_dev\_endpoint\_arguments](#input\_glue\_dev\_endpoint\_arguments) | A map of arguments used to configure the endpoint. | `map(string)` | n/a | yes |
| <a name="input_glue_dev_endpoint_extra_jars_s3_path"></a> [glue\_dev\_endpoint\_extra\_jars\_s3\_path](#input\_glue\_dev\_endpoint\_extra\_jars\_s3\_path) | Path to one or more Java Jars in an S3 bucket that should be loaded in this endpoint. | `string` | n/a | yes |
| <a name="input_glue_dev_endpoint_extra_python_libs_s3_path"></a> [glue\_dev\_endpoint\_extra\_python\_libs\_s3\_path](#input\_glue\_dev\_endpoint\_extra\_python\_libs\_s3\_path) | Path(s) to one or more Python libraries in an S3 bucket that should be loaded in this endpoint. Multiple values must be complete paths separated by a comma. | `string` | n/a | yes |
| <a name="input_glue_dev_endpoint_glue_version"></a> [glue\_dev\_endpoint\_glue\_version](#input\_glue\_dev\_endpoint\_glue\_version) | Specifies the versions of Python and Apache Spark to use. Defaults to AWS Glue version 0.9. | `string` | n/a | yes |
| <a name="input_glue_dev_endpoint_number_of_nodes"></a> [glue\_dev\_endpoint\_number\_of\_nodes](#input\_glue\_dev\_endpoint\_number\_of\_nodes) | The number of AWS Glue Data Processing Units (DPUs) to allocate to this endpoint. | `number` | n/a | yes |
| <a name="input_glue_dev_endpoint_number_of_workers"></a> [glue\_dev\_endpoint\_number\_of\_workers](#input\_glue\_dev\_endpoint\_number\_of\_workers) | The number of workers of a defined worker type that are allocated to this endpoint. This field is available only when you choose worker type G.1X or G.2X. | `number` | n/a | yes |
| <a name="input_glue_dev_endpoint_public_key"></a> [glue\_dev\_endpoint\_public\_key](#input\_glue\_dev\_endpoint\_public\_key) | The public key to be used by this endpoint for authentication. | `string` | n/a | yes |
| <a name="input_glue_dev_endpoint_public_keys"></a> [glue\_dev\_endpoint\_public\_keys](#input\_glue\_dev\_endpoint\_public\_keys) | A list of public keys to be used by this endpoint for authentication. | `list(string)` | n/a | yes |
| <a name="input_glue_dev_endpoint_worker_type"></a> [glue\_dev\_endpoint\_worker\_type](#input\_glue\_dev\_endpoint\_worker\_type) | The type of predefined worker that is allocated to this endpoint. Accepts a value of Standard, G.1X, or G.2X. | `string` | n/a | yes |
| <a name="input_glue_job_command"></a> [glue\_job\_command](#input\_glue\_job\_command) | The command of the job. Includes 'name', 'script\_location' and 'python\_version'. | `list(map(string))` | n/a | yes |
| <a name="input_glue_trigger_predicate"></a> [glue\_trigger\_predicate](#input\_glue\_trigger\_predicate) | A predicate to specify when the new trigger should fire.Required when trigger type is CONDITIONAL. | `list(map(string))` | n/a | yes |
| <a name="input_glue_trigger_type"></a> [glue\_trigger\_type](#input\_glue\_trigger\_type) | The type of trigger.Valid values are CONDITIONAL, ON\_DEMAND, and SCHEDULED. | `string` | n/a | yes |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | Policy arn for the iam role | `list(string)` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name you assign to the Glue resources. It must be unique in your account. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_role_service"></a> [role\_service](#input\_role\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id\_1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_glue_connection_arn"></a> [glue\_connection\_arn](#output\_glue\_connection\_arn) | The ARN of the Glue Connection. |
| <a name="output_glue_connection_id"></a> [glue\_connection\_id](#output\_glue\_connection\_id) | Catalog ID and name of the connection |
| <a name="output_glue_connections_tags_all"></a> [glue\_connections\_tags\_all](#output\_glue\_connections\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags |
| <a name="output_glue_dev_endpoint_arn"></a> [glue\_dev\_endpoint\_arn](#output\_glue\_dev\_endpoint\_arn) | The ARN of the endpoint. |
| <a name="output_glue_dev_endpoint_availability_zone"></a> [glue\_dev\_endpoint\_availability\_zone](#output\_glue\_dev\_endpoint\_availability\_zone) | The AWS availability zone where this endpoint is located. |
| <a name="output_glue_dev_endpoint_failure_reason"></a> [glue\_dev\_endpoint\_failure\_reason](#output\_glue\_dev\_endpoint\_failure\_reason) | The reason for a current failure in this endpoint. |
| <a name="output_glue_dev_endpoint_name"></a> [glue\_dev\_endpoint\_name](#output\_glue\_dev\_endpoint\_name) | The name of the new endpoint. |
| <a name="output_glue_dev_endpoint_private_address"></a> [glue\_dev\_endpoint\_private\_address](#output\_glue\_dev\_endpoint\_private\_address) | A private IP address to access the endpoint within a VPC, if this endpoint is created within one. |
| <a name="output_glue_dev_endpoint_public_address"></a> [glue\_dev\_endpoint\_public\_address](#output\_glue\_dev\_endpoint\_public\_address) | The public IP address used by this endpoint. The PublicAddress field is present only when you create a non-VPC endpoint. |
| <a name="output_glue_dev_endpoint_status"></a> [glue\_dev\_endpoint\_status](#output\_glue\_dev\_endpoint\_status) | The current status of this endpoint. |
| <a name="output_glue_dev_endpoint_tags_all"></a> [glue\_dev\_endpoint\_tags\_all](#output\_glue\_dev\_endpoint\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider. |
| <a name="output_glue_dev_endpoint_vpc_id"></a> [glue\_dev\_endpoint\_vpc\_id](#output\_glue\_dev\_endpoint\_vpc\_id) | The ID of the VPC used by this endpoint. |
| <a name="output_glue_dev_endpoint_yarn_endpoint_address"></a> [glue\_dev\_endpoint\_yarn\_endpoint\_address](#output\_glue\_dev\_endpoint\_yarn\_endpoint\_address) | The YARN endpoint address used by this endpoint. |
| <a name="output_glue_dev_endpoint_zeppelin_remote_spark_interpreter_port"></a> [glue\_dev\_endpoint\_zeppelin\_remote\_spark\_interpreter\_port](#output\_glue\_dev\_endpoint\_zeppelin\_remote\_spark\_interpreter\_port) | The Apache Zeppelin port for the remote Apache Spark interpreter. |
| <a name="output_glue_job_arn"></a> [glue\_job\_arn](#output\_glue\_job\_arn) | Amazon Resource Name (ARN) of Glue Job |
| <a name="output_glue_job_id"></a> [glue\_job\_id](#output\_glue\_job\_id) | Job name |
| <a name="output_glue_job_tags_all"></a> [glue\_job\_tags\_all](#output\_glue\_job\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags |
| <a name="output_glue_security_configuration_id"></a> [glue\_security\_configuration\_id](#output\_glue\_security\_configuration\_id) | Glue security configuration name |
| <a name="output_glue_trigger_arn"></a> [glue\_trigger\_arn](#output\_glue\_trigger\_arn) | Amazon Resource Name (ARN) of Glue Trigger |
| <a name="output_glue_trigger_id"></a> [glue\_trigger\_id](#output\_glue\_trigger\_id) | Trigger name |
| <a name="output_glue_trigger_state"></a> [glue\_trigger\_state](#output\_glue\_trigger\_state) | The current state of the trigger. |
| <a name="output_glue_trigger_tags_all"></a> [glue\_trigger\_tags\_all](#output\_glue\_trigger\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags |


<!-- END_TF_DOCS -->