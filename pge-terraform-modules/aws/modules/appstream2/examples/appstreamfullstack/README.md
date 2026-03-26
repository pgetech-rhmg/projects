<!-- BEGIN_TF_DOCS -->
# AWS appstream2.0 with usage example
Terraform module which creates SAF2.0 appstream2.0 resources in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

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
| <a name="module_fleet"></a> [fleet](#module\_fleet) | ../../modules/fleet | n/a |
| <a name="module_fleet_stack"></a> [fleet\_stack](#module\_fleet\_stack) | ../../modules/fleet_stack_association | n/a |
| <a name="module_iam_role_appstream"></a> [iam\_role\_appstream](#module\_iam\_role\_appstream) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_security_group_appstream"></a> [security\_group\_appstream](#module\_security\_group\_appstream) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_stack_appstream"></a> [stack\_appstream](#module\_stack\_appstream) | ../../modules/stack | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/string) | resource |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.fleet_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.fleet_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.fleet_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

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
| <a name="input_description"></a> [description](#input\_description) | Description to display. | `string` | n/a | yes |
| <a name="input_desired_instances"></a> [desired\_instances](#input\_desired\_instances) | Desired number of streaming instances. | `number` | n/a | yes |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Human-readable friendly name for the AppStream resources. | `string` | n/a | yes |
| <a name="input_domain_join_info"></a> [domain\_join\_info](#input\_domain\_join\_info) | Configuration block for the name of the directory and organizational unit (OU) to use to join the image builder to a Microsoft Active Directory domain. | <pre>object({<br>    directory_name                         = string<br>    organizational_unit_distinguished_name = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_fleet_type"></a> [fleet\_type](#input\_fleet\_type) | Fleet type. Valid values are: ON\_DEMAND, ALWAYS\_ON,ELASTIC | `string` | n/a | yes |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Name of the image used to create the fleet. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use when launching fleet instances. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Unique name for the appstream resources. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_role_service"></a> [role\_service](#input\_role\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | enter the value of subnet id2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | enter the value of subnet id3 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appstream_stack_arn"></a> [appstream\_stack\_arn](#output\_appstream\_stack\_arn) | ARN of the appstream stack. |
| <a name="output_appstream_stack_created_time"></a> [appstream\_stack\_created\_time](#output\_appstream\_stack\_created\_time) | Date and time, in UTC and extended RFC 3339 format, when the stack was created. |
| <a name="output_appstream_stack_id"></a> [appstream\_stack\_id](#output\_appstream\_stack\_id) | Unique ID of the appstream stack. |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the appstream fleet. |
| <a name="output_compute_capacity"></a> [compute\_capacity](#output\_compute\_capacity) | Describes the capacity status for a fleet. |
| <a name="output_created_time"></a> [created\_time](#output\_created\_time) | Date and time, in UTC and extended RFC 3339 format, when the fleet was created. |
| <a name="output_id"></a> [id](#output\_id) | Unique identifier (ID) of the appstream fleet. |
| <a name="output_id_fleet_stack"></a> [id\_fleet\_stack](#output\_id\_fleet\_stack) | Unique ID of the appstream stack fleet association, composed of the fleet\_name and stack\_name separated by a slash (/). |
| <a name="output_state"></a> [state](#output\_state) | State of the fleet. Can be STARTING, RUNNING, STOPPING or STOPPED |


<!-- END_TF_DOCS -->