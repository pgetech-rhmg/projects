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
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

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
| <a name="module_lambda-mrad-alias"></a> [lambda-mrad-alias](#module\_lambda-mrad-alias) | app.terraform.io/pgetech/lambda/aws//modules/lambda_alias | 0.1.3 |
| <a name="module_lambda-s3"></a> [lambda-s3](#module\_lambda-s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_lambda_iam_policy"></a> [lambda\_iam\_policy](#module\_lambda\_iam\_policy) | app.terraform.io/pgetech/iam/aws//modules/iam_policy | 0.0.8 |
| <a name="module_lambda_iam_role"></a> [lambda\_iam\_role](#module\_lambda\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_log_group"></a> [log\_group](#module\_log\_group) | app.terraform.io/pgetech/cloudwatch/aws//modules/log-group | 0.1.3 |
| <a name="module_sumo_logger"></a> [sumo\_logger](#module\_sumo\_logger) | app.terraform.io/pgetech/mrad-sumo/aws | 3.0.9-rc2 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role_policy_attachment.attach_managed_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_event_invoke_config.lambda_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_event_invoke_config) | resource |
| [aws_lambda_provisioned_concurrency_config.warmer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_provisioned_concurrency_config) | resource |
| [aws_s3_object.object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [null_resource.lambda_name_length_validation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [archive_file.lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.bucket_ssl_only_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_s3_bucket.logging_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |
| [aws_security_groups.lambda_sgs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_groups) | data source |
| [aws_subnet.private1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.private2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.private3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_TFC_CONFIGURATION_VERSION_GIT_BRANCH"></a> [TFC\_CONFIGURATION\_VERSION\_GIT\_BRANCH](#input\_TFC\_CONFIGURATION\_VERSION\_GIT\_BRANCH) | The current Git branch, set by Terraform. See: https://developer.hashicorp.com/terraform/cloud-docs/run/run-environment | `string` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | The AWS account number. | `string` | `null` | no |
| <a name="input_additional_security_groups"></a> [additional\_security\_groups](#input\_additional\_security\_groups) | Any additional security groups to be added to the Lambda function. | `list(string)` | `[]` | no |
| <a name="input_alias_name"></a> [alias\_name](#input\_alias\_name) | An optional custom alias name for this Lambda function. | `string` | `null` | no |
| <a name="input_archive_path"></a> [archive\_path](#input\_archive\_path) | The path to the Lambda source code directory. | `string` | n/a | yes |
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | The name of the AWS account or environment. Should be one of: `Dev`, `Test`, `QA`, `Prod` | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to use for storing logs and Lambda Insights. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | The AWS role used for the Sumo logger module. | `string` | n/a | yes |
| <a name="input_bucket_versioning"></a> [bucket\_versioning](#input\_bucket\_versioning) | Set whether bucket versioning is on of off for the bucket containing Lambda source code. | `string` | `"Disabled"` | no |
| <a name="input_dead_letter_queue_arn"></a> [dead\_letter\_queue\_arn](#input\_dead\_letter\_queue\_arn) | ARN of an SNS topic or SQS queue to notify when an invocation fails. | `string` | `null` | no |
| <a name="input_disable_warmer"></a> [disable\_warmer](#input\_disable\_warmer) | Disable the Lambda concurrency warmer. This is a workaround for an AWS resource config issue: `InvalidParameterValueException: Provisioned Concurrency Configs cannot be applied to unpublished function versions.` | `bool` | `false` | no |
| <a name="input_envvars"></a> [envvars](#input\_envvars) | Environment variables to pass into the Lambda function. | `map(string)` | <pre>{<br/>  "DEFAULT_ENVARS": "TRUE"<br/>}</pre> | no |
| <a name="input_filter_pattern"></a> [filter\_pattern](#input\_filter\_pattern) | The CloudWatch Logs filter pattern for pattern matching logs to send to Sumo Logic. Applies to an `aws_cloudwatch_log_subscription_filter`. See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter#filter_pattern | `string` | `""` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | The handler function for this Lambda. Default of `src/index.handler` means that the handler will be located in `src/index.js` and the exported function is named `handler`. | `string` | `"src/index.handler"` | no |
| <a name="input_ignore_name_length_check"></a> [ignore\_name\_length\_check](#input\_ignore\_name\_length\_check) | If true, ignore the pre-deploy length check for the Lambda function name. This is intended for use by existing repos which already rely on names that are too long to define a valid warmer. | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The ARN of the KMS key to use for encryption. Required if data classification is not Internal or Public. | `string` | `null` | no |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | This value is UNUSED and should be left as `null`. It remains here for backward compatibility. | `string` | `null` | no |
| <a name="input_lambda_additional_iam_managed_policy_arns"></a> [lambda\_additional\_iam\_managed\_policy\_arns](#input\_lambda\_additional\_iam\_managed\_policy\_arns) | Allows a managed IAM policy to be added to the default policy, by ARN. | `list(string)` | `[]` | no |
| <a name="input_lambda_additional_iam_policy"></a> [lambda\_additional\_iam\_policy](#input\_lambda\_additional\_iam\_policy) | Allows a custom IAM policy to be added to the default policy. | `string` | `null` | no |
| <a name="input_lambda_insights"></a> [lambda\_insights](#input\_lambda\_insights) | If true, enable Lambda Insights for this function. | `bool` | `false` | no |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | The name of the Lambda function. | `string` | n/a | yes |
| <a name="input_layers"></a> [layers](#input\_layers) | Lambda layer version ARNs to attach to the Lambda function. See: https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html | `list(string)` | <pre>[<br/>  "arn:aws:lambda:us-west-2:553035198032:layer:git:6"<br/>]</pre> | no |
| <a name="input_maximum_retry_attempts"></a> [maximum\_retry\_attempts](#input\_maximum\_retry\_attempts) | Maximum number of times to retry when the function returns an error, from 0 to 2. | `number` | `2` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount of memory provided to the Lambda function, in MiB. | `number` | `1024` | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags to add to these resources. | `map(string)` | `{}` | no |
| <a name="input_partner"></a> [partner](#input\_partner) | If `partner` is not MRAD, the name of the VPC to use for this Lambda function. | `string` | `"MRAD"` | no |
| <a name="input_publish"></a> [publish](#input\_publish) | If true, publish this creation/change as a new Lambda function version. | `bool` | `false` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | The runtime used to run Lambda code. See: https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html#runtimes-supported | `string` | `"nodejs22.x"` | no |
| <a name="input_service"></a> [service](#input\_service) | A list of AWS services allowed to assume the generated IAM role. | `list(string)` | <pre>[<br/>  "lambda.amazonaws.com"<br/>]</pre> | no |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | The name of the security group to use for this Lambda function. | `string` | `"terraform-template-lambda-sg"` | no |
| <a name="input_subnet1"></a> [subnet1](#input\_subnet1) | The name of the first subnet to use for this Lambda function. | `string` | `""` | no |
| <a name="input_subnet2"></a> [subnet2](#input\_subnet2) | The name of the second subnet to use for this Lambda function. | `string` | `""` | no |
| <a name="input_subnet3"></a> [subnet3](#input\_subnet3) | The name of the third subnet to use for this Lambda function. | `string` | `""` | no |
| <a name="input_subnet_qualifier"></a> [subnet\_qualifier](#input\_subnet\_qualifier) | If `partner != MRAD`, this is used to select a subnet by environment. | `map(any)` | <pre>{<br/>  "Dev": "Dev-2",<br/>  "Prod": "Prod",<br/>  "QA": "QA",<br/>  "Test": "Test-2"<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to these resources which indicates their provenance. | `map(string)` | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Execution timeout for the Lambda function, in seconds. | `number` | `60` | no |
| <a name="input_tracing_enabled"></a> [tracing\_enabled](#input\_tracing\_enabled) | If true, use Active mode for function tracing; otherwise, use PassThrough mode. See: https://docs.aws.amazon.com/vsts/latest/userguide/lambda-deploy.html | `bool` | `true` | no |
| <a name="input_use_aws_managed_s3_kms"></a> [use\_aws\_managed\_s3\_kms](#input\_use\_aws\_managed\_s3\_kms) | If true, use AWS-managed KMS (aws/s3) for S3 bucket encryption instead of customer-managed key. Lambda environment variables will still use customer-managed KMS if kms\_key\_arn is null. | `bool` | `false` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | n/a |
| <a name="output_lambda_alias_arn"></a> [lambda\_alias\_arn](#output\_lambda\_alias\_arn) | n/a |
| <a name="output_lambda_alias_invoke_arn"></a> [lambda\_alias\_invoke\_arn](#output\_lambda\_alias\_invoke\_arn) | n/a |
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | n/a |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | n/a |
| <a name="output_lambda_invoke_arn"></a> [lambda\_invoke\_arn](#output\_lambda\_invoke\_arn) | n/a |
| <a name="output_lambda_qualified_arn"></a> [lambda\_qualified\_arn](#output\_lambda\_qualified\_arn) | n/a |

<!-- END_TF_DOCS -->
