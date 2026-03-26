<!-- BEGIN_TF_DOCS -->
# AWS storagegateway file\_gateway module
# Terraform module which creates aws\_storagegateway\_gateway

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.94.1 |

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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_storagegateway_gateway.gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activation_gateway"></a> [activation\_gateway](#input\_activation\_gateway) | activation\_key<br>    Gateway activation key during resource creation.<br>gateway\_ip\_address<br>    Gateway IP address to retrieve activation key during resource creation. Conflicts with activation\_key. Gateway must be accessible on port 80 from where Terraform is running. | <pre>object({<br>    activation_key     = string<br>    gateway_ip_address = string<br>  })</pre> | <pre>{<br>  "activation_key": null,<br>  "gateway_ip_address": null<br>}</pre> | no |
| <a name="input_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#input\_cloudwatch\_log\_group\_arn) | The Amazon Resource Name (ARN) of the Amazon CloudWatch log group to use to monitor and log events in the gateway. | `string` | n/a | yes |
| <a name="input_gateway_name"></a> [gateway\_name](#input\_gateway\_name) | Name of the gateway. | `string` | n/a | yes |
| <a name="input_gateway_timezone"></a> [gateway\_timezone](#input\_gateway\_timezone) | Time zone for the gateway. The time zone is of the format 'GMT', 'GMT-hr:mm', or 'GMT+hr:mm'. For example, GMT-4:00 indicates the time is 4 hours behind GMT. The time zone is used, for example, for scheduling snapshots and your gateway's maintenance schedule. | `string` | n/a | yes |
| <a name="input_gateway_type"></a> [gateway\_type](#input\_gateway\_type) | Type of the gateway. The default value is STORED. | `string` | `null` | no |
| <a name="input_gateway_vpc_endpoint"></a> [gateway\_vpc\_endpoint](#input\_gateway\_vpc\_endpoint) | VPC endpoint address to be used when activating your gateway. This should be used when your instance is in a private subnet. Requires HTTP access from client computer running terraform. | `string` | n/a | yes |
| <a name="input_maintenance_start_time"></a> [maintenance\_start\_time](#input\_maintenance\_start\_time) | {<br>maintenance\_start\_time : "The gateway's weekly maintenance start time information, including day and time of the week. The maintenance time is the time in your gateway's time zone."<br>day\_of\_month           : (Optional) The day of the month component of the maintenance start time represented as an ordinal number from 1 to 28, where 1 represents the first day of the month and 28 represents the last day of the month.<br>day\_of\_week            : (Optional) The day of the week component of the maintenance start time week represented as an ordinal number from 0 to 6, where 0 represents Sunday and 6 Saturday.<br>hour\_of\_day            : (Required) The hour component of the maintenance start time represented as hh, where hh is the hour (00 to 23). The hour of the day is in the time zone of the gateway.<br>minute\_of\_hour         : (Required) The minute component of the maintenance start time represented as mm, where mm is the minute (00 to 59). The minute of the hour is in the time zone of the gateway.<br>} | <pre>object({<br>    day_of_month   = optional(number)<br>    day_of_week    = optional(number)<br>    hour_of_day    = number<br>    minute_of_hour = number<br>  })</pre> | <pre>{<br>  "day_of_month": null,<br>  "day_of_week": null,<br>  "hour_of_day": null,<br>  "minute_of_hour": null<br>}</pre> | no |
| <a name="input_smb_active_directory_settings"></a> [smb\_active\_directory\_settings](#input\_smb\_active\_directory\_settings) | {<br>smb\_active\_directory\_settings : "Nested argument with Active Directory domain join information for Server Message Block (SMB) file shares. Only valid for FILE\_S3 and FILE\_FSX\_SMB gateway types. Must be set before creating ActiveDirectory authentication SMB file shares."<br>domain\_name         : (Required) The name of the domain that you want the gateway to join.<br>password            : (Required) The password of the user who has permission to add the gateway to the Active Directory domain.<br>username            : (Required) The user name of user who has permission to add the gateway to the Active Directory domain.<br>timeout\_in\_seconds  : (Optional) Specifies the time in seconds, in which the JoinDomain operation must complete. The default is 20 seconds.<br>organizational\_unit : (Optional) The organizational unit (OU) is a container in an Active Directory that can hold users, groups, computers, and other OUs and this parameter specifies the OU that the gateway will join within the AD domain.<br>domain\_controllers  : (Optional) List of IPv4 addresses, NetBIOS names, or host names of your domain server. If you need to specify the port number include it after the colon (“:”). For example, mydc.mydomain.com:389.<br>} | <pre>object({<br>    domain_name         = string<br>    password            = string<br>    username            = string<br>    timeout_in_seconds  = optional(number)<br>    organizational_unit = optional(string)<br>    domain_controllers  = optional(list(string))<br>  })</pre> | <pre>{<br>  "domain_controllers": null,<br>  "domain_name": null,<br>  "organizational_unit": null,<br>  "password": null,<br>  "timeout_in_seconds": null,<br>  "username": null<br>}</pre> | no |
| <a name="input_smb_file_share_visibility"></a> [smb\_file\_share\_visibility](#input\_smb\_file\_share\_visibility) | Specifies whether the shares on this gateway appear when listing shares. | `bool` | `false` | no |
| <a name="input_smb_security_strategy"></a> [smb\_security\_strategy](#input\_smb\_security\_strategy) | Specifies the type of security strategy. Valid values are: ClientSpecified, MandatorySigning, and MandatoryEncryption. | `string` | `"ClientSpecified"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags | `map(string)` | n/a | yes |
| <a name="input_timeout_create"></a> [timeout\_create](#input\_timeout\_create) | Timeout for Creating file system | `string` | `"10m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name (ARN) of the gateway. |
| <a name="output_ec2_instance_id"></a> [ec2\_instance\_id](#output\_ec2\_instance\_id) | The ID of the Amazon EC2 instance that was used to launch the gateway. |
| <a name="output_endpoint_type"></a> [endpoint\_type](#output\_endpoint\_type) | The type of endpoint for your gateway. |
| <a name="output_gateway_id"></a> [gateway\_id](#output\_gateway\_id) | Identifier of the gateway. |
| <a name="output_gateway_network_interface"></a> [gateway\_network\_interface](#output\_gateway\_network\_interface) | An array that contains descriptions of the gateway network interfaces. |
| <a name="output_host_environment"></a> [host\_environment](#output\_host\_environment) | The type of hypervisor environment used by the host. |
| <a name="output_id"></a> [id](#output\_id) | Amazon Resource Name (ARN) of the gateway. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->