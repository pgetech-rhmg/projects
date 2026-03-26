<!-- BEGIN_TF_DOCS -->
# AWS Transfer family server module.
Terraform module which creates SAF2.0 aws\_transfer\_server in AWS.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.93.0 |

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
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_transfer_server.transfer_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/transfer_server) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_directory_id"></a> [directory\_id](#input\_directory\_id) | The directory service ID of the directory service you want to connect to with an identity\_provider\_type of AWS\_DIRECTORY\_SERVICE. | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | The domain of the storage system that is used for file transfers. Valid values are: S3 and EFS. The default value is S3. | `string` | `"S3"` | no |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | endpoint\_type:<br>   The type of endpoint that you want your SFTP server connect to. If you connect to a VPC (or VPC\_ENDPOINT), your SFTP server isn't accessible over the public internet.<br>address\_allocation\_ids:<br>  A list of address allocation IDs that are required to attach an Elastic IP address to your SFTP server's endpoint. This property can only be used when endpoint\_type is set to VPC.<br>security\_group\_ids:<br>  A list of security groups IDs that are available to attach to your server's endpoint. If no security groups are specified, the VPC's default security groups are automatically assigned to your endpoint. This property can only be used when endpoint\_type is set to VPC.<br>subnet\_ids:<br>  A list of subnet IDs that are required to host your SFTP server endpoint in your VPC. This property can only be used when endpoint\_type is set to VPC.<br>vpc\_endpoint\_id:<br>  The ID of the VPC endpoint. This property can only be used when endpoint\_type is set to VPC\_ENDPOINT.<br>vpc\_id:<br>  The VPC ID of the virtual private cloud in which the SFTP server's endpoint will be hosted. This property can only be used when endpoint\_type is set to VPC. | <pre>object({<br>    endpoint_type          = string<br>    address_allocation_ids = optional(list(string))<br>    security_group_ids     = optional(list(string))<br>    subnet_ids             = optional(list(string))<br>    vpc_id                 = optional(string)<br>    vpc_endpoint_id        = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_host_key"></a> [host\_key](#input\_host\_key) | RSA private key. | `string` | `null` | no |
| <a name="input_logging_role"></a> [logging\_role](#input\_logging\_role) | Amazon Resource Name (ARN) of an IAM role that allows the service to write your SFTP users’ activity to your Amazon CloudWatch logs for monitoring and auditing purposes. | `string` | `null` | no |
| <a name="input_post_authentication_login_banner"></a> [post\_authentication\_login\_banner](#input\_post\_authentication\_login\_banner) | Specify a string to display when users connect to a server. This string is displayed after the user authenticates. The SFTP protocol does not support post-authentication display banners. | `string` | `null` | no |
| <a name="input_pre_authentication_login_banner"></a> [pre\_authentication\_login\_banner](#input\_pre\_authentication\_login\_banner) | Specify a string to display when users connect to a server. This string is displayed before the user authenticates. | `string` | `null` | no |
| <a name="input_security_policy_name"></a> [security\_policy\_name](#input\_security\_policy\_name) | Specifies the name of the security policy that is attached to the server. Possible values are TransferSecurityPolicy-2018-11, TransferSecurityPolicy-2020-06, TransferSecurityPolicy-FIPS-2020-06 and TransferSecurityPolicy-2022-03. Default value is: TransferSecurityPolicy-2018-11. | `string` | `"TransferSecurityPolicy-2018-11"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags. | `map(string)` | n/a | yes |
| <a name="input_workflow"></a> [workflow](#input\_workflow) | execution\_role:<br>   Includes the necessary permissions for S3, EFS, and Lambda operations that Transfer can assume, so that all workflow steps can operate on the required resources.<br>workflow\_id:<br>  A unique identifier for the workflow. | <pre>object({<br>    execution_role = string<br>    workflow_id    = string<br>  })</pre> | <pre>{<br>  "execution_role": null,<br>  "workflow_id": null<br>}</pre> | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_transfer_server_all"></a> [transfer\_server\_all](#output\_transfer\_server\_all) | Map of transfer\_server object |
| <a name="output_transfer_server_arn"></a> [transfer\_server\_arn](#output\_transfer\_server\_arn) | Amazon Resource Name (ARN) of Transfer Server. |
| <a name="output_transfer_server_endpoint"></a> [transfer\_server\_endpoint](#output\_transfer\_server\_endpoint) | The endpoint of the Transfer Server. |
| <a name="output_transfer_server_host_key_fingerprint"></a> [transfer\_server\_host\_key\_fingerprint](#output\_transfer\_server\_host\_key\_fingerprint) | This value contains the message-digest algorithm (MD5) hash of the server's host key. This value is equivalent to the output of the ssh-keygen -l -E md5 -f my-new-server-key command. |
| <a name="output_transfer_server_id"></a> [transfer\_server\_id](#output\_transfer\_server\_id) | The Server ID of the Transfer Server. |
| <a name="output_transfer_server_tags_all"></a> [transfer\_server\_tags\_all](#output\_transfer\_server\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->