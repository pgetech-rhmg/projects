<!-- BEGIN_TF_DOCS -->
# AWS Lambda Function with Vpc-Endpoint User module example

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
| <a name="module_aws_lambda_iam_role"></a> [aws\_lambda\_iam\_role](#module\_aws\_lambda\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | ../../ | n/a |
| <a name="module_security_group_lambda"></a> [security\_group\_lambda](#module\_security\_group\_lambda) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_security_group_vpc_endpoint"></a> [security\_group\_vpc\_endpoint](#module\_security\_group\_vpc\_endpoint) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |
| <a name="module_vpc_endpoint"></a> [vpc\_endpoint](#module\_vpc\_endpoint) | app.terraform.io/pgetech/vpc-endpoint/aws | 0.1.1 |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
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
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of what your Lambda Function does | `string` | n/a | yes |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Unique name for your Lambda Function | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint in your code | `string` | n/a | yes |
| <a name="input_iam_aws_service"></a> [iam\_aws\_service](#input\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_iam_name"></a> [iam\_name](#input\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | Policy arn for the iam role | `list(string)` | n/a | yes |
| <a name="input_lambda_cidr_egress_rules"></a> [lambda\_cidr\_egress\_rules](#input\_lambda\_cidr\_egress\_rules) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_lambda_cidr_ingress_rules"></a> [lambda\_cidr\_ingress\_rules](#input\_lambda\_cidr\_ingress\_rules) | variables for security\_group\_lambda | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_lambda_sg_description"></a> [lambda\_sg\_description](#input\_lambda\_sg\_description) | description for security group associated with lambda | `string` | n/a | yes |
| <a name="input_lambda_sg_name"></a> [lambda\_sg\_name](#input\_lambda\_sg\_name) | name of the security group associated with lambda | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Identifier of the function's runtime | `string` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The service name.For AWS services the service name is usually in the form com.amazonaws.<region>.<service>.The SageMaker Notebook service is an exception to this rule, the service name is in the form aws.sagemaker.<region>.notebook | `string` | n/a | yes |
| <a name="input_source_dir"></a> [source\_dir](#input\_source\_dir) | Package entire contents of this directory into the archive. | `string` | n/a | yes |
| <a name="input_subnet_id1_name"></a> [subnet\_id1\_name](#input\_subnet\_id1\_name) | The name given in the parameter store for the subnet id 1 | `string` | n/a | yes |
| <a name="input_vpc_endpoint_cidr_egress_rules"></a> [vpc\_endpoint\_cidr\_egress\_rules](#input\_vpc\_endpoint\_cidr\_egress\_rules) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_vpc_endpoint_cidr_ingress_rules"></a> [vpc\_endpoint\_cidr\_ingress\_rules](#input\_vpc\_endpoint\_cidr\_ingress\_rules) | variables for security\_group\_vpc\_endpoint | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_vpc_endpoint_sg_description"></a> [vpc\_endpoint\_sg\_description](#input\_vpc\_endpoint\_sg\_description) | description for security group associated with endpoint | `string` | n/a | yes |
| <a name="input_vpc_endpoint_sg_name"></a> [vpc\_endpoint\_sg\_name](#input\_vpc\_endpoint\_sg\_name) | name of the security group associated with endpoint | `string` | n/a | yes |
| <a name="input_vpc_id_name"></a> [vpc\_id\_name](#input\_vpc\_id\_name) | The name given in the parameter store for the vpc id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | Amazon Resource Name (ARN) identifying your Lambda Function |
| <a name="output_lambda_invoke_arn"></a> [lambda\_invoke\_arn](#output\_lambda\_invoke\_arn) | ARN to be used for invoking Lambda Function from API Gateway - to be used in aws\_api\_gateway\_integration's uri |
| <a name="output_lambda_last_modified"></a> [lambda\_last\_modified](#output\_lambda\_last\_modified) | Date this resource was last modified |
| <a name="output_lambda_qualified_arn"></a> [lambda\_qualified\_arn](#output\_lambda\_qualified\_arn) | ARN identifying your Lambda Function Version (if versioning is enabled via publish = true) |
| <a name="output_lambda_signing_job_arn"></a> [lambda\_signing\_job\_arn](#output\_lambda\_signing\_job\_arn) | ARN of the signing job |
| <a name="output_lambda_signing_profile_version_arn"></a> [lambda\_signing\_profile\_version\_arn](#output\_lambda\_signing\_profile\_version\_arn) | ARN of the signing profile version |
| <a name="output_lambda_source_code_size"></a> [lambda\_source\_code\_size](#output\_lambda\_source\_code\_size) | Size in bytes of the function .zip file |
| <a name="output_lambda_tags_all"></a> [lambda\_tags\_all](#output\_lambda\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_lambda_version"></a> [lambda\_version](#output\_lambda\_version) | Latest published version of your Lambda Function |
| <a name="output_lambda_vpc_config_vpc_id"></a> [lambda\_vpc\_config\_vpc\_id](#output\_lambda\_vpc\_config\_vpc\_id) | ID of the VPC |

<!-- END_TF_DOCS -->