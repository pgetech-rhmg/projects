<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | >=2.3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.32.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.5 |

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
| [aws_redshiftserverless_namespace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshiftserverless_namespace) | resource |
| [aws_redshiftserverless_workgroup.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshiftserverless_workgroup) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_user_password"></a> [admin\_user\_password](#input\_admin\_user\_password) | The password of the administrator for the first database created in the namespace. | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The username of the administrator for the first database created in the namespace. | `string` | `null` | no |
| <a name="input_base_capacity"></a> [base\_capacity](#input\_base\_capacity) | The base data warehouse capacity of the workgroup in Redshift Processing Units (RPUs). | `number` | `128` | no |
| <a name="input_config_parameters"></a> [config\_parameters](#input\_config\_parameters) | An array of parameters to set for more control over a serverless database. | <pre>list(object({<br/>    parameter_key   = string<br/>    parameter_value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | The name of the first database created in the namespace. | `string` | `null` | no |
| <a name="input_default_iam_role_arn"></a> [default\_iam\_role\_arn](#input\_default\_iam\_role\_arn) | The Amazon Resource Name (ARN) of the IAM role to set as a default in the namespace. | `string` | `null` | no |
| <a name="input_enhanced_vpc_routing"></a> [enhanced\_vpc\_routing](#input\_enhanced\_vpc\_routing) | The value that specifies whether to turn on enhanced virtual private cloud (VPC) routing. | `bool` | `false` | no |
| <a name="input_iam_role_arns"></a> [iam\_role\_arns](#input\_iam\_role\_arns) | A list of IAM roles to associate with the namespace. | `list(string)` | `[]` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN of the Amazon Web Services Key Management Service key used to encrypt your data. | `string` | `null` | no |
| <a name="input_log_exports"></a> [log\_exports](#input\_log\_exports) | The types of logs the namespace can export. Available export types are userlog, connectionlog, and useractivitylog. | `list(string)` | `[]` | no |
| <a name="input_manage_admin_password"></a> [manage\_admin\_password](#input\_manage\_admin\_password) | Whether to use AWS SecretManager to manage namespace admin credentials. NOTE: Currently not supported - must be false. Use admin\_user\_password instead. | `bool` | `false` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | The maximum data warehouse capacity Amazon Redshift Serverless uses to serve queries, specified in Redshift Processing Units (RPUs). | `number` | `null` | no |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | The name of the namespace. Must be a lower case string. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | The port number on which the cluster accepts incoming connections. | `number` | `5439` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | A value that specifies whether the workgroup can be accessed from a public network. | `bool` | `false` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | An array of security group IDs to associate with the workgroup. | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | An array of VPC subnet IDs to associate with the workgroup. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | n/a | yes |
| <a name="input_workgroup_name"></a> [workgroup\_name](#input\_workgroup\_name) | The name of the workgroup. Must be a lower case string. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_namespace_admin_username"></a> [namespace\_admin\_username](#output\_namespace\_admin\_username) | The username of the administrator for the namespace. |
| <a name="output_namespace_arn"></a> [namespace\_arn](#output\_namespace\_arn) | Amazon Resource Name (ARN) of the Redshift Serverless Namespace. |
| <a name="output_namespace_db_name"></a> [namespace\_db\_name](#output\_namespace\_db\_name) | The name of the first database created in the namespace. |
| <a name="output_namespace_iam_roles"></a> [namespace\_iam\_roles](#output\_namespace\_iam\_roles) | List of IAM roles associated with the namespace. |
| <a name="output_namespace_id"></a> [namespace\_id](#output\_namespace\_id) | The Redshift Serverless Namespace ID. |
| <a name="output_namespace_kms_key_id"></a> [namespace\_kms\_key\_id](#output\_namespace\_kms\_key\_id) | The ARN of the KMS key used to encrypt the namespace. |
| <a name="output_namespace_name"></a> [namespace\_name](#output\_namespace\_name) | The Redshift Serverless Namespace Name. |
| <a name="output_workgroup_arn"></a> [workgroup\_arn](#output\_workgroup\_arn) | Amazon Resource Name (ARN) of the Redshift Serverless Workgroup. |
| <a name="output_workgroup_base_capacity"></a> [workgroup\_base\_capacity](#output\_workgroup\_base\_capacity) | The base data warehouse capacity of the workgroup in RPUs. |
| <a name="output_workgroup_endpoint"></a> [workgroup\_endpoint](#output\_workgroup\_endpoint) | The endpoint that is created from the workgroup. |
| <a name="output_workgroup_id"></a> [workgroup\_id](#output\_workgroup\_id) | The Redshift Serverless Workgroup ID. |
| <a name="output_workgroup_name"></a> [workgroup\_name](#output\_workgroup\_name) | The Redshift Serverless Workgroup Name. |
| <a name="output_workgroup_port"></a> [workgroup\_port](#output\_workgroup\_port) | The port number on which the workgroup accepts incoming connections. |
| <a name="output_workgroup_security_group_ids"></a> [workgroup\_security\_group\_ids](#output\_workgroup\_security\_group\_ids) | An array of security group IDs associated with the workgroup. |
| <a name="output_workgroup_subnet_ids"></a> [workgroup\_subnet\_ids](#output\_workgroup\_subnet\_ids) | An array of VPC subnet IDs associated with the workgroup. |

<!-- END_TF_DOCS -->