<!-- BEGIN_TF_DOCS -->
# AWS Glue Crawler module Crawler example

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
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
| <a name="module_crawler_dynamodb"></a> [crawler\_dynamodb](#module\_crawler\_dynamodb) | ../../modules/crawler | n/a |
| <a name="module_crawler_s3"></a> [crawler\_s3](#module\_crawler\_s3) | ../../modules/crawler | n/a |
| <a name="module_crawler_s3_and_dynamodb"></a> [crawler\_s3\_and\_dynamodb](#module\_crawler\_s3\_and\_dynamodb) | ../../modules/crawler | n/a |
| <a name="module_glue_security_configuration"></a> [glue\_security\_configuration](#module\_glue\_security\_configuration) | ../../../glue/modules/security-configuration/ | n/a |
| <a name="module_iam_crawler_role"></a> [iam\_crawler\_role](#module\_iam\_crawler\_role) | app.terraform.io/pgetech/iam/aws | 0.1.0 |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | app.terraform.io/pgetech/kms/aws | 0.1.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_lakeformation_permissions.iam_crawler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lakeformation_permissions) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

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
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | A list of AWS services allowed to assume this role.  Required if the trusted\_aws\_principals variable is not provided. | `list(string)` | n/a | yes |
| <a name="input_database_catalog_id"></a> [database\_catalog\_id](#input\_database\_catalog\_id) | List of permissions granted to the principal. | `string` | n/a | yes |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | List of permissions granted to the principal. | `string` | n/a | yes |
| <a name="input_dynamodb_target"></a> [dynamodb\_target](#input\_dynamodb\_target) | List of nested DynamoDB target arguments. | `list(map(string))` | n/a | yes |
| <a name="input_glue_crawler_database_name"></a> [glue\_crawler\_database\_name](#input\_glue\_crawler\_database\_name) | Glue database where results are written. | `string` | n/a | yes |
| <a name="input_glue_crawler_lineage_configuration"></a> [glue\_crawler\_lineage\_configuration](#input\_glue\_crawler\_lineage\_configuration) | Specifies data lineage configuration settings for the crawler. | `map(string)` | n/a | yes |
| <a name="input_glue_crawler_recrawl_policy"></a> [glue\_crawler\_recrawl\_policy](#input\_glue\_crawler\_recrawl\_policy) | A policy that specifies whether to crawl the entire dataset again, or to crawl only folders that were added since the last crawler run. | `map(string)` | n/a | yes |
| <a name="input_glue_crawler_schedule"></a> [glue\_crawler\_schedule](#input\_glue\_crawler\_schedule) | A cron expression used to specify the schedule. For more information, see Time-Based Schedules for Jobs and Crawlers. | `string` | n/a | yes |
| <a name="input_glue_crawler_schema_change_policy"></a> [glue\_crawler\_schema\_change\_policy](#input\_glue\_crawler\_schema\_change\_policy) | Policy for the crawler's update and deletion behavior. | `map(string)` | n/a | yes |
| <a name="input_glue_crawler_table_prefix_dynamodb"></a> [glue\_crawler\_table\_prefix\_dynamodb](#input\_glue\_crawler\_table\_prefix\_dynamodb) | The table prefix used for catalog tables that are created. | `string` | n/a | yes |
| <a name="input_glue_crawler_table_prefix_s3"></a> [glue\_crawler\_table\_prefix\_s3](#input\_glue\_crawler\_table\_prefix\_s3) | The table prefix used for catalog tables that are created. | `string` | n/a | yes |
| <a name="input_glue_crawler_table_prefix_s3_dynamodb"></a> [glue\_crawler\_table\_prefix\_s3\_dynamodb](#input\_glue\_crawler\_table\_prefix\_s3\_dynamodb) | The table prefix used for catalog tables that are created. | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name you assign to the Glue resources. It must be unique in your account. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | List of permissions granted to the principal. | `list(string)` | n/a | yes |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | A list of managed IAM policies to attach to the IAM role | `list(string)` | n/a | yes |
| <a name="input_s3_target"></a> [s3\_target](#input\_s3\_target) | List of nested Amazon S3 target arguments. | `list(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_crawler_dynamodb_arn"></a> [crawler\_dynamodb\_arn](#output\_crawler\_dynamodb\_arn) | The ARN of the crawler |
| <a name="output_crawler_dynamodb_id"></a> [crawler\_dynamodb\_id](#output\_crawler\_dynamodb\_id) | Crawler name |
| <a name="output_crawler_dynamodb_tags_all"></a> [crawler\_dynamodb\_tags\_all](#output\_crawler\_dynamodb\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags |
| <a name="output_crawler_s3_arn"></a> [crawler\_s3\_arn](#output\_crawler\_s3\_arn) | The ARN of the crawler |
| <a name="output_crawler_s3_id"></a> [crawler\_s3\_id](#output\_crawler\_s3\_id) | Crawler name |
| <a name="output_crawler_s3_tags_all"></a> [crawler\_s3\_tags\_all](#output\_crawler\_s3\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags |


<!-- END_TF_DOCS -->