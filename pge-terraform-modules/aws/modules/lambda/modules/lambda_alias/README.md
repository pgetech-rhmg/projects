<!-- BEGIN_TF_DOCS -->
# AWS Lambda alias
Terraform module which creates SAF2.0 Lambda alias in AWS

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
| [aws_lambda_alias.lambda_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_alias) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_lambda_alias_description"></a> [lambda\_alias\_description](#input\_lambda\_alias\_description) | Description of the alias | `string` | `null` | no |
| <a name="input_lambda_alias_function_name"></a> [lambda\_alias\_function\_name](#input\_lambda\_alias\_function\_name) | Lambda Function name or ARN | `string` | n/a | yes |
| <a name="input_lambda_alias_function_version"></a> [lambda\_alias\_function\_version](#input\_lambda\_alias\_function\_version) | Lambda function version for which you are creating the alias | `string` | n/a | yes |
| <a name="input_lambda_alias_name"></a> [lambda\_alias\_name](#input\_lambda\_alias\_name) | Name for the alias you are creating | `string` | n/a | yes |
| <a name="input_routing_config_additional_version_weights"></a> [routing\_config\_additional\_version\_weights](#input\_routing\_config\_additional\_version\_weights) | A map that defines the proportion of events that should be sent to different versions of a lambda function | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_alias_all"></a> [lambda\_alias\_all](#output\_lambda\_alias\_all) | Map of all Lambda object |
| <a name="output_lambda_alias_arn"></a> [lambda\_alias\_arn](#output\_lambda\_alias\_arn) | The Amazon Resource Name (ARN) identifying your Lambda function alias |
| <a name="output_lambda_alias_invoke_arn"></a> [lambda\_alias\_invoke\_arn](#output\_lambda\_alias\_invoke\_arn) | The ARN to be used for invoking Lambda Function from API Gateway - to be used in aws\_api\_gateway\_integration's uri |

<!-- END_TF_DOCS -->