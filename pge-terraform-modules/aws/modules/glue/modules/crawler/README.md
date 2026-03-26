<!-- BEGIN_TF_DOCS -->
# AWS Glue Crawler module.
Terraform module which creates SAF2.0 Glue Crawler in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

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
| [aws_glue_crawler.glue_crawler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_catalog_target"></a> [catalog\_target](#input\_catalog\_target) | List of nested Amazon catalog target arguments. | `list(map(string))` | `[]` | no |
| <a name="input_delta_target"></a> [delta\_target](#input\_delta\_target) | List nested delta target arguments. | `list(map(string))` | `[]` | no |
| <a name="input_dynamodb_target"></a> [dynamodb\_target](#input\_dynamodb\_target) | List of nested DynamoDB target arguments. | `list(map(string))` | `[]` | no |
| <a name="input_glue_crawler_classifiers"></a> [glue\_crawler\_classifiers](#input\_glue\_crawler\_classifiers) | List of custom classifiers. By default, all AWS classifiers are included in a crawl, but these custom classifiers always override the default classifiers for a given classification. | `list(string)` | `null` | no |
| <a name="input_glue_crawler_configuration"></a> [glue\_crawler\_configuration](#input\_glue\_crawler\_configuration) | JSON string of configuration information. | `string` | `null` | no |
| <a name="input_glue_crawler_database_name"></a> [glue\_crawler\_database\_name](#input\_glue\_crawler\_database\_name) | Glue database where results are written. | `string` | n/a | yes |
| <a name="input_glue_crawler_description"></a> [glue\_crawler\_description](#input\_glue\_crawler\_description) | Description of the crawler. | `string` | `null` | no |
| <a name="input_glue_crawler_lineage_configuration"></a> [glue\_crawler\_lineage\_configuration](#input\_glue\_crawler\_lineage\_configuration) | Specifies data lineage configuration settings for the crawler. | `map(string)` | `{}` | no |
| <a name="input_glue_crawler_name"></a> [glue\_crawler\_name](#input\_glue\_crawler\_name) | Name of the crawler. | `string` | n/a | yes |
| <a name="input_glue_crawler_recrawl_policy"></a> [glue\_crawler\_recrawl\_policy](#input\_glue\_crawler\_recrawl\_policy) | A policy that specifies whether to crawl the entire dataset again, or to crawl only folders that were added since the last crawler run. | `map(string)` | `{}` | no |
| <a name="input_glue_crawler_role"></a> [glue\_crawler\_role](#input\_glue\_crawler\_role) | The IAM role friendly name (including path without leading slash), or ARN of an IAM role, used by the crawler to access other resources. | `string` | n/a | yes |
| <a name="input_glue_crawler_schedule"></a> [glue\_crawler\_schedule](#input\_glue\_crawler\_schedule) | A cron expression used to specify the schedule. For more information, see Time-Based Schedules for Jobs and Crawlers. | `string` | `null` | no |
| <a name="input_glue_crawler_schema_change_policy"></a> [glue\_crawler\_schema\_change\_policy](#input\_glue\_crawler\_schema\_change\_policy) | Policy for the crawler's update and deletion behavior. | `map(string)` | `{}` | no |
| <a name="input_glue_crawler_security_configuration"></a> [glue\_crawler\_security\_configuration](#input\_glue\_crawler\_security\_configuration) | The name of Security Configuration to be used by the crawler | `string` | `null` | no |
| <a name="input_glue_crawler_table_prefix"></a> [glue\_crawler\_table\_prefix](#input\_glue\_crawler\_table\_prefix) | The table prefix used for catalog tables that are created. | `string` | `null` | no |
| <a name="input_jdbc_target"></a> [jdbc\_target](#input\_jdbc\_target) | List of nested JDBC target arguments. | `list(any)` | `[]` | no |
| <a name="input_mongodb_target"></a> [mongodb\_target](#input\_mongodb\_target) | List nested MongoDB target arguments. | `list(map(string))` | `[]` | no |
| <a name="input_s3_target"></a> [s3\_target](#input\_s3\_target) | List of nested Amazon S3 target arguments. | `list(any)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_crawler"></a> [aws\_glue\_crawler](#output\_aws\_glue\_crawler) | A map of aws\_glue\_crawler |
| <a name="output_crawler_arn"></a> [crawler\_arn](#output\_crawler\_arn) | The ARN of the crawler |
| <a name="output_crawler_id"></a> [crawler\_id](#output\_crawler\_id) | Crawler name |
| <a name="output_crawler_tags_all"></a> [crawler\_tags\_all](#output\_crawler\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags |


<!-- END_TF_DOCS -->