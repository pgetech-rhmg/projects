<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

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
| <a name="module_redshift_iam_role"></a> [redshift\_iam\_role](#module\_redshift\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_redshift_serverless"></a> [redshift\_serverless](#module\_redshift\_serverless) | ../../ | n/a |
| <a name="module_security_group_redshift"></a> [security\_group\_redshift](#module\_security\_group\_redshift) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_password.redshift_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
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
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID. Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Identify assets with compliance requirements (SOX, HIPAA, CCPA, etc.) | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance. One of the following: Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | `0` | no |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Lead | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Admin username for Redshift Serverless | `string` | `"admin"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_base_capacity"></a> [base\_capacity](#input\_base\_capacity) | Base capacity in RPUs | `number` | `128` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Database name | `string` | `"dev"` | no |
| <a name="input_enhanced_vpc_routing"></a> [enhanced\_vpc\_routing](#input\_enhanced\_vpc\_routing) | Enable enhanced VPC routing | `bool` | `false` | no |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_log_exports"></a> [log\_exports](#input\_log\_exports) | Types of logs to export | `list(string)` | `[]` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | Maximum capacity in RPUs | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the Redshift Serverless resources | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional additional tags | `map(string)` | `{}` | no |
| <a name="input_parameter_vpc_id_name"></a> [parameter\_vpc\_id\_name](#input\_parameter\_vpc\_id\_name) | ID of VPC stored in aws\_ssm\_parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | Enter the value of subnet id1 stored in SSM parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | Enter the value of subnet id2 stored in SSM parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | Enter the value of subnet id3 stored in SSM parameter | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | Admin password (sensitive) |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | IAM role ARN for Redshift Serverless |
| <a name="output_namespace_arn"></a> [namespace\_arn](#output\_namespace\_arn) | ARN of the Redshift Serverless namespace |
| <a name="output_namespace_id"></a> [namespace\_id](#output\_namespace\_id) | ID of the Redshift Serverless namespace |
| <a name="output_namespace_name"></a> [namespace\_name](#output\_namespace\_name) | Name of the Redshift Serverless namespace |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group ID for Redshift Serverless |
| <a name="output_workgroup_arn"></a> [workgroup\_arn](#output\_workgroup\_arn) | ARN of the Redshift Serverless workgroup |
| <a name="output_workgroup_endpoint"></a> [workgroup\_endpoint](#output\_workgroup\_endpoint) | Endpoint of the Redshift Serverless workgroup |
| <a name="output_workgroup_id"></a> [workgroup\_id](#output\_workgroup\_id) | ID of the Redshift Serverless workgroup |
| <a name="output_workgroup_port"></a> [workgroup\_port](#output\_workgroup\_port) | Port of the Redshift Serverless workgroup |

<!-- END_TF_DOCS -->