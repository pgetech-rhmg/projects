# Canary 
* This module creates the canary itself and a cloudwatch alarm triggered when the canary fails
* It contains the node.js code executing the test.  
* This would be the code you would modify if you have to deal with APIs that are authenticated, for example.  
<!-- BEGIN_TF_DOCS -->
# AWS Cloudwatch synthetics module, this is used to create Clopudwatch Alarms
Terraform module which creates SAF2.0 Cloudwatch synthetics Alarms in AWS

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | 2.4.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.4.2 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.93.0 |

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
| [aws_synthetics_canary.canary_api_calls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/synthetics_canary) | resource |
| [archive_file.lambda_canary_zip](https://registry.terraform.io/providers/hashicorp/archive/2.4.2/docs/data-sources/file) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_s3_bucket.s3_canaries-reports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_hostname"></a> [api\_hostname](#input\_api\_hostname) | hostname to test | `string` | n/a | yes |
| <a name="input_api_path"></a> [api\_path](#input\_api\_path) | The path for the API call , ex: /path?param=value. | `string` | n/a | yes |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | Role to execute the canaries | `string` | n/a | yes |
| <a name="input_frequency"></a> [frequency](#input\_frequency) | frequency of tests in minutes | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the canary | `string` | n/a | yes |
| <a name="input_reports-bucket"></a> [reports-bucket](#input\_reports-bucket) | Name of the bucket storing canary results | `string` | n/a | yes |
| <a name="input_runtime_version"></a> [runtime\_version](#input\_runtime\_version) | Runtime version | `string` | n/a | yes |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Security Groups used by the canary | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs in which to execute the canary | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_take_screenshot"></a> [take\_screenshot](#input\_take\_screenshot) | If screenshot should be taken | `bool` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_synthetics_canary"></a> [aws\_synthetics\_canary](#output\_aws\_synthetics\_canary) | A map of aws synthetic canary resource |


<!-- END_TF_DOCS -->