<!-- BEGIN_TF_DOCS -->
# AWS AppSync module
# Terraform module which creates AppSync Datasource.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appsync_datasource.datasource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_datasource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_id"></a> [api\_id](#input\_api\_id) | API ID for the GraphQL API for the data source. | `string` | n/a | yes |
| <a name="input_config"></a> [config](#input\_config) | type:<br>  Type of the Data Source. Valid values: AWS\_LAMBDA, AMAZON\_DYNAMODB, AMAZON\_ELASTICSEARCH, HTTP, NONE, RELATIONAL\_DATABASE.<br>dynamodb\_config:<br>  table\_name:<br>   Name of the DynamoDB table.<br>  region:<br>   AWS region of the DynamoDB table. Defaults to current region.<br>  use\_caller\_credentials:<br>   Set to true to use Amazon Cognito credentials with this data source.<br>  versioned:<br>   Set to TRUE to use Conflict Detection and Resolution with this data source.<br>elasticsearch\_config:<br>  endpoint:<br>   HTTP endpoint of the Elasticsearch domain.<br>  region:<br>   AWS region of Elasticsearch domain. Defaults to current region.<br>http\_config:<br>  endpoint:<br>   HTTP URL.<br>  authentication\_type:<br>   Authorization type that the HTTP endpoint requires. Default values is AWS\_IAM.<br>  signing\_region:<br>   Signing Amazon Web Services Region for IAM authorization.<br>  signing\_service\_name:<br>   Signing service name for IAM authorization.<br>lambda\_config:<br>  function\_arn:<br>   ARN for the Lambda function.<br>relational\_database\_config:<br>  db\_cluster\_identifier:<br>   Amazon RDS cluster identifier.<br>  aws\_secret\_store\_arn:<br>   AWS secret store ARN for database credentials.<br>  source\_type:<br>   Source type for the relational database. Valid values: RDS\_HTTP\_ENDPOINT.<br>  region:<br>   AWS Region for RDS HTTP endpoint. Defaults to current region.<br>  schema:<br>   Logical schema name. | <pre>object({<br>    type = string<br>    dynamodb_config = optional(object({<br>      table_name             = string<br>      region                 = string<br>      use_caller_credentials = optional(bool)<br>      versioned              = optional(bool)<br>    }))<br>    elasticsearch_config = optional(object({<br>      endpoint = string<br>      region   = string<br>    }))<br>    http_config = optional(object({<br>      endpoint             = string<br>      authentication_type  = optional(string)<br>      signing_region       = optional(string)<br>      signing_service_name = optional(string)<br>    }))<br>    lambda_config = optional(object({<br>      function_arn = string<br>    }))<br>    relational_database_config = optional(object({<br>      source_type = optional(string, "RDS_HTTP_ENDPOINT")<br>    }))<br>    http_endpoint_config = optional(object({<br>      db_cluster_identifier = string<br>      aws_secret_store_arn  = string<br>      database_name         = optional(string)<br>      region                = optional(string)<br>      schema                = optional(string)<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the data source. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | User-supplied name for the data source. | `string` | n/a | yes |
| <a name="input_service_role_arn"></a> [service\_role\_arn](#input\_service\_role\_arn) | IAM service role ARN for the data source. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the appsync datasource. |
| <a name="output_aws_appsync_datasource_all"></a> [aws\_appsync\_datasource\_all](#output\_aws\_appsync\_datasource\_all) | Map of tws\_appsync\_datasource object. |
| <a name="output_name"></a> [name](#output\_name) | User-supplied name for the data source. |


<!-- END_TF_DOCS -->