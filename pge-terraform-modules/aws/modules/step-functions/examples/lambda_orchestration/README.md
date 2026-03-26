<!-- BEGIN_TF_DOCS -->
# AWS Step Functions Lambda Orchestration Example

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.0 |
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
| <a name="module_aws_lambda_iam_role"></a> [aws\_lambda\_iam\_role](#module\_aws\_lambda\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_aws_state_machine_iam_role"></a> [aws\_state\_machine\_iam\_role](#module\_aws\_state\_machine\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_cloudwatch_log-group"></a> [cloudwatch\_log-group](#module\_cloudwatch\_log-group) | app.terraform.io/pgetech/cloudwatch/aws//modules/log-group | 0.1.1 |
| <a name="module_lambda_approve_sqs"></a> [lambda\_approve\_sqs](#module\_lambda\_approve\_sqs) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_lambda_buy_stock"></a> [lambda\_buy\_stock](#module\_lambda\_buy\_stock) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_lambda_check_stock_price"></a> [lambda\_check\_stock\_price](#module\_lambda\_check\_stock\_price) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_lambda_event_source_mapping_sqs"></a> [lambda\_event\_source\_mapping\_sqs](#module\_lambda\_event\_source\_mapping\_sqs) | app.terraform.io/pgetech/lambda/aws//modules/event_source_mapping_sqs | 0.1.3 |
| <a name="module_lambda_generate_buy_sell_recommendation"></a> [lambda\_generate\_buy\_sell\_recommendation](#module\_lambda\_generate\_buy\_sell\_recommendation) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_lambda_orchestration"></a> [lambda\_orchestration](#module\_lambda\_orchestration) | ../.. | n/a |
| <a name="module_lambda_sell_stock"></a> [lambda\_sell\_stock](#module\_lambda\_sell\_stock) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_security_group_lambda"></a> [security\_group\_lambda](#module\_security\_group\_lambda) | app.terraform.io/pgetech/security-group/aws | 0.1.1 |
| <a name="module_sns_topic"></a> [sns\_topic](#module\_sns\_topic) | app.terraform.io/pgetech/sns/aws | 0.1.1 |
| <a name="module_sqs"></a> [sqs](#module\_sqs) | app.terraform.io/pgetech/sqs/aws//modules/sqs_standard_queue | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |
| <a name="module_vpc_endpoint"></a> [vpc\_endpoint](#module\_vpc\_endpoint) | app.terraform.io/pgetech/vpc-endpoint/aws | 0.1.1 |
| <a name="module_vpce_security_group"></a> [vpce\_security\_group](#module\_vpce\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.1 |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.subnet_id1_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####. | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one). | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud. | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance. One of the following: Public, Internal, Confidential, Restricted, Privileged (only one). | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3. | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume. | `string` | n/a | yes |
| <a name="input_cloudwatch_log_name_prefix"></a> [cloudwatch\_log\_name\_prefix](#input\_cloudwatch\_log\_name\_prefix) | A name for the log group. | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint in your code. | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS KMS role to assume. | `string` | n/a | yes |
| <a name="input_lambda_approve_sqs_directory"></a> [lambda\_approve\_sqs\_directory](#input\_lambda\_approve\_sqs\_directory) | Package entire contents of this directory into the archive. | `string` | n/a | yes |
| <a name="input_lambda_approve_sqs_name"></a> [lambda\_approve\_sqs\_name](#input\_lambda\_approve\_sqs\_name) | Unique name for your Lambda Function for approve\_sqs. | `string` | n/a | yes |
| <a name="input_lambda_buy_stock_directory"></a> [lambda\_buy\_stock\_directory](#input\_lambda\_buy\_stock\_directory) | Package entire contents of this directory into the archive. | `string` | n/a | yes |
| <a name="input_lambda_buy_stock_name"></a> [lambda\_buy\_stock\_name](#input\_lambda\_buy\_stock\_name) | Unique name for your Lambda Function for buy\_stock. | `string` | n/a | yes |
| <a name="input_lambda_check_stock_price_directory"></a> [lambda\_check\_stock\_price\_directory](#input\_lambda\_check\_stock\_price\_directory) | Package entire contents of this directory into the archive. | `string` | n/a | yes |
| <a name="input_lambda_check_stock_price_name"></a> [lambda\_check\_stock\_price\_name](#input\_lambda\_check\_stock\_price\_name) | Unique name for your Lambda Function for check\_stock\_price. | `string` | n/a | yes |
| <a name="input_lambda_generate_buy_sell_recommendation_directory"></a> [lambda\_generate\_buy\_sell\_recommendation\_directory](#input\_lambda\_generate\_buy\_sell\_recommendation\_directory) | Package entire contents of this directory into the archive. | `string` | n/a | yes |
| <a name="input_lambda_generate_buy_sell_recommendation_name"></a> [lambda\_generate\_buy\_sell\_recommendation\_name](#input\_lambda\_generate\_buy\_sell\_recommendation\_name) | Unique name for your Lambda Function for generate\_buy\_sell\_recommendation. | `string` | n/a | yes |
| <a name="input_lambda_iam_aws_service"></a> [lambda\_iam\_aws\_service](#input\_lambda\_iam\_aws\_service) | AWS service of the IAM role. | `list(string)` | n/a | yes |
| <a name="input_lambda_iam_role_name"></a> [lambda\_iam\_role\_name](#input\_lambda\_iam\_role\_name) | Name of the IAM role. | `string` | n/a | yes |
| <a name="input_lambda_sell_stock_directory"></a> [lambda\_sell\_stock\_directory](#input\_lambda\_sell\_stock\_directory) | Package entire contents of this directory into the archive. | `string` | n/a | yes |
| <a name="input_lambda_sell_stock_name"></a> [lambda\_sell\_stock\_name](#input\_lambda\_sell\_stock\_name) | Unique name for your Lambda Function for sell\_stock. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The common name for all the name arguments in resources. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional\_tags. | `map(string)` | `{}` | no |
| <a name="input_private_dns_enabled"></a> [private\_dns\_enabled](#input\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC. | `bool` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Identifier of the function's runtime. | `string` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The service name. For AWS services the service name is usually in the form com.amazonaws.<region>.<service>. | `string` | n/a | yes |
| <a name="input_state_machine_definition"></a> [state\_machine\_definition](#input\_state\_machine\_definition) | Name of the file which contains the state machine definition. | `string` | n/a | yes |
| <a name="input_state_machine_iam_aws_service"></a> [state\_machine\_iam\_aws\_service](#input\_state\_machine\_iam\_aws\_service) | AWS service of the IAM role. | `list(string)` | n/a | yes |
| <a name="input_state_machine_iam_role_name"></a> [state\_machine\_iam\_role\_name](#input\_state\_machine\_iam\_role\_name) | Name of the IAM role. | `string` | n/a | yes |
| <a name="input_subnet_id1_name"></a> [subnet\_id1\_name](#input\_subnet\_id1\_name) | The name given in the parameter store for the subnet id 1. | `string` | n/a | yes |
| <a name="input_vpc_id_name"></a> [vpc\_id\_name](#input\_vpc\_id\_name) | The name given in the parameter store for the vpc id. | `string` | n/a | yes |
| <a name="input_vpce_security_group_name"></a> [vpce\_security\_group\_name](#input\_vpce\_security\_group\_name) | Name of the security group. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_state_machine_arn"></a> [state\_machine\_arn](#output\_state\_machine\_arn) | The ARN of the state machine. |
| <a name="output_state_machine_status"></a> [state\_machine\_status](#output\_state\_machine\_status) | The current status of the state machine. Either ACTIVE or DELETING. |


<!-- END_TF_DOCS -->