<!-- BEGIN_TF_DOCS -->
# PG&E Mrad Lambda Module
 MRAD specific composite Terraform Lambda module to provision SAF compliant resources

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.2.0 |
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
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | app.terraform.io/pgetech/kms/aws | 0.1.2 |
| <a name="module_lambda-mrad"></a> [lambda-mrad](#module\_lambda-mrad) | app.terraform.io/pgetech/lambda/aws//modules/lambda_s3_bucket | 0.1.4 |
| <a name="module_lambda-mrad-alias"></a> [lambda-mrad-alias](#module\_lambda-mrad-alias) | app.terraform.io/pgetech/lambda/aws//modules/lambda_alias | 0.1.3 |
| <a name="module_lambda-s3"></a> [lambda-s3](#module\_lambda-s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_lambda_iam_role"></a> [lambda\_iam\_role](#module\_lambda\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_mrad-common"></a> [mrad-common](#module\_mrad-common) | app.terraform.io/pgetech/mrad-common/aws | ~> 1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_lambda_function_event_invoke_config.lambda_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_event_invoke_config) | resource |
| [aws_s3_object.object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [archive_file.lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.bucket_ssl_only_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_s3_bucket.logging_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |
| [aws_security_groups.lambda_sgs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_groups) | data source |
| [aws_subnet.private1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.private2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.private3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_TFC_CONFIGURATION_VERSION_GIT_BRANCH"></a> [TFC\_CONFIGURATION\_VERSION\_GIT\_BRANCH](#input\_TFC\_CONFIGURATION\_VERSION\_GIT\_BRANCH) | n/a | `string` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_additional_security_groups"></a> [additional\_security\_groups](#input\_additional\_security\_groups) | Any additional security groups to be added to the Lambda Function | `list(string)` | `[]` | no |
| <a name="input_archive_path"></a> [archive\_path](#input\_archive\_path) | The path to the Lambda for the archive provider | `string` | n/a | yes |
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | Aws account name, dev, qa, test, production. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"us-west-2"` | no |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | n/a | `string` | n/a | yes |
| <a name="input_dead_letter_queue_arn"></a> [dead\_letter\_queue\_arn](#input\_dead\_letter\_queue\_arn) | ARN of an SNS topic or SQS queue to notify when an invocation fails. | `string` | `null` | no |
| <a name="input_envvars"></a> [envvars](#input\_envvars) | Environment variables, like github tokens | `map(string)` | <pre>{<br/>  "DEFAULT_ENVARS": "TRUE"<br/>}</pre> | no |
| <a name="input_handler"></a> [handler](#input\_handler) | Where the handler function lives | `string` | `"src/index.handler"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | kms key arn used to encrypt lambda environment variables | `string` | `null` | no |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | n/a | `string` | n/a | yes |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | The name of the Lambda | `string` | n/a | yes |
| <a name="input_layers"></a> [layers](#input\_layers) | Layer that the lambda contains; default gives git | `list(string)` | <pre>[<br/>  "arn:aws:lambda:us-west-2:553035198032:layer:git:6"<br/>]</pre> | no |
| <a name="input_maximum_retry_attempts"></a> [maximum\_retry\_attempts](#input\_maximum\_retry\_attempts) | Maximum number of times to retry when the function returns an error. Valid values between 0 and 2. Defaults to 2. | `number` | `2` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory for the Lambda Function | `number` | `1024` | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_partner"></a> [partner](#input\_partner) | partner team name | `string` | `"MRAD"` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | The runtime the Lambda is executing in | `string` | `"nodejs14.x"` | no |
| <a name="input_service"></a> [service](#input\_service) | n/a | `list(string)` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | security group name | `string` | `"terraform-template-lambda-sg"` | no |
| <a name="input_subnet1"></a> [subnet1](#input\_subnet1) | subnet1 name | `string` | `""` | no |
| <a name="input_subnet2"></a> [subnet2](#input\_subnet2) | subnet2 name | `string` | `""` | no |
| <a name="input_subnet3"></a> [subnet3](#input\_subnet3) | subnet3 name | `string` | `""` | no |
| <a name="input_subnet_qualifier"></a> [subnet\_qualifier](#input\_subnet\_qualifier) | The subnet qualifier | `map(any)` | <pre>{<br/>  "Dev": "Dev-2",<br/>  "Prod": "Prod",<br/>  "QA": "QA",<br/>  "Test": "Test-2"<br/>}</pre> | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout for the Lambda Function | `number` | `60` | no |
| <a name="input_tracing_enabled"></a> [tracing\_enabled](#input\_tracing\_enabled) | Enable xray tracing | `bool` | `true` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | n/a |
| <a name="output_lambda_alias_arn"></a> [lambda\_alias\_arn](#output\_lambda\_alias\_arn) | n/a |
| <a name="output_lambda_alias_invoke_arn"></a> [lambda\_alias\_invoke\_arn](#output\_lambda\_alias\_invoke\_arn) | n/a |
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | n/a |
| <a name="output_lambda_invoke_arn"></a> [lambda\_invoke\_arn](#output\_lambda\_invoke\_arn) | n/a |
| <a name="output_lambda_qualified_arn"></a> [lambda\_qualified\_arn](#output\_lambda\_qualified\_arn) | n/a |

<!-- END_TF_DOCS -->