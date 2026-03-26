<!-- BEGIN_TF_DOCS -->
# AWS Lambda trigger module
Composite module usind SAF2.0 CCoE modules

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

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
| <a name="module_api_deployment_and_stage"></a> [api\_deployment\_and\_stage](#module\_api\_deployment\_and\_stage) | app.terraform.io/pgetech/api-gateway/aws//modules/rest_api_deployment_and_stage | 0.0.14 |
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | app.terraform.io/pgetech/api-gateway/aws//modules/rest_api | 0.0.14 |
| <a name="module_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#module\_cloudwatch\_log\_group) | app.terraform.io/pgetech/cloudwatch/aws//modules/log-group | 0.0.8 |
| <a name="module_sumo_logger"></a> [sumo\_logger](#module\_sumo\_logger) | app.terraform.io/pgetech/mrad-sumo/aws | 3.0.9-rc1 |

## Resources

| Name | Type |
|------|------|
| [aws_lambda_permission.apigw_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_vpc.mrad_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_vpc_endpoint.apigw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_api_gw_resource_policy"></a> [api\_gw\_resource\_policy](#input\_api\_gw\_resource\_policy) | The api gw policy | `string` | `"{}"` | no |
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | Aws account name, dev, qa, test, production. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | n/a | `string` | n/a | yes |
| <a name="input_binary_media_types"></a> [binary\_media\_types](#input\_binary\_media\_types) | List of binary media types supported by the REST API. | `list(any)` | `[]` | no |
| <a name="input_branch"></a> [branch](#input\_branch) | n/a | `string` | n/a | yes |
| <a name="input_deployment_triggers"></a> [deployment\_triggers](#input\_deployment\_triggers) | List of triggers for this deployment. Values of this list are used in hash function that triggers redeployment when changed. | `list(any)` | `[]` | no |
| <a name="input_filter_pattern"></a> [filter\_pattern](#input\_filter\_pattern) | The filter pattern for log pattern matching | `string` | `""` | no |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | The name of your Lambda function | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the API Gateway you're deploying | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to populate on the trigger resources. | `map(string)` | n/a | yes |
| <a name="input_tracing_enabled"></a> [tracing\_enabled](#input\_tracing\_enabled) | Enable xray tracing | `bool` | `true` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_deployment"></a> [deployment](#output\_deployment) | n/a |
| <a name="output_rest_api"></a> [rest\_api](#output\_rest\_api) | n/a |
| <a name="output_root_resource_id"></a> [root\_resource\_id](#output\_root\_resource\_id) | n/a |
| <a name="output_stage_name"></a> [stage\_name](#output\_stage\_name) | n/a |

<!-- END_TF_DOCS -->