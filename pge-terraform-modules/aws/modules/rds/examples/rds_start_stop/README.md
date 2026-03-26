<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

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
| <a name="module_iam_role_rds_auto_start_stop"></a> [iam\_role\_rds\_auto\_start\_stop](#module\_iam\_role\_rds\_auto\_start\_stop) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_rds_start_stop"></a> [rds\_start\_stop](#module\_rds\_start\_stop) | ../../modules/rds-start-stop | n/a |
| <a name="module_security_group_lambda"></a> [security\_group\_lambda](#module\_security\_group\_lambda) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |
| <a name="module_vpc_endpoint_rds"></a> [vpc\_endpoint\_rds](#module\_vpc\_endpoint\_rds) | app.terraform.io/pgetech/vpc-endpoint/aws | 0.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_canonical_user_id.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_iam_policy_document.inline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.private_subnet1_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.private_subnet2_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.private_subnet3_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_cidr_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_cidr_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
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
| <a name="input_Order"></a> [Order](#input\_Order) | Order must be a  number between 7 and 9 Digits. This is used to identify the order in which the assets are created. | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | Unique name for the role | `string` | n/a | yes |
| <a name="input_domain_iam_role_name"></a> [domain\_iam\_role\_name](#input\_domain\_iam\_role\_name) | (Required if domain is provided) The name of the IAM role to be used when making API calls to the Directory Service | `string` | `"rds-directoryservice-kerberos-access-role"` | no |
| <a name="input_iam_policy_arns_rds_auto_start_stop"></a> [iam\_policy\_arns\_rds\_auto\_start\_stop](#input\_iam\_policy\_arns\_rds\_auto\_start\_stop) | Policy arn for the iam role | `list(string)` | n/a | yes |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | Identifier of the function's runtime | `string` | n/a | yes |
| <a name="input_lambda_sg_description"></a> [lambda\_sg\_description](#input\_lambda\_sg\_description) | vpc id for security group | `string` | n/a | yes |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Lambda timeout in seconds | `number` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_rds_auto_control_service_name"></a> [rds\_auto\_control\_service\_name](#input\_rds\_auto\_control\_service\_name) | RDS auto control service name | `string` | n/a | yes |
| <a name="input_role_service_rds_auto_start_stop"></a> [role\_service\_rds\_auto\_start\_stop](#input\_role\_service\_rds\_auto\_start\_stop) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_schedule_rds_auto_start"></a> [schedule\_rds\_auto\_start](#input\_schedule\_rds\_auto\_start) | Cron schedule to trigger lambda function | `string` | n/a | yes |
| <a name="input_schedule_rds_auto_stop"></a> [schedule\_rds\_auto\_stop](#input\_schedule\_rds\_auto\_stop) | Cron schedule to trigger lambda function | `string` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | service name to be associated with vpce | `string` | n/a | yes |
| <a name="input_user"></a> [user](#input\_user) | User id for aws session | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_rds_auto_start_stop_arn"></a> [iam\_role\_rds\_auto\_start\_stop\_arn](#output\_iam\_role\_rds\_auto\_start\_stop\_arn) | Map of values of the iam\_role\_rds\_auto\_start\_stop module arn |
| <a name="output_rds_start_stop_module_id"></a> [rds\_start\_stop\_module\_id](#output\_rds\_start\_stop\_module\_id) | Map of values of the rds\_start\_stop module |
| <a name="output_security_group_lambda_id"></a> [security\_group\_lambda\_id](#output\_security\_group\_lambda\_id) | Map of values of the security\_group\_lambda module id |
| <a name="output_vpc_endpoint_rds_id"></a> [vpc\_endpoint\_rds\_id](#output\_vpc\_endpoint\_rds\_id) | Map of values of the vpc\_endpoint\_rds module id |


<!-- END_TF_DOCS -->