<!-- BEGIN_TF_DOCS -->
# AWS Redshift
Terraform module which creates SAF2.0 Redshift usage limits in AWS

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_redshift_usage_limit.usage-one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_usage_limit) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amount"></a> [amount](#input\_amount) | The limit amount. If time-based, this amount is in minutes. If data-based, this amount is in terabytes (TB). | `number` | n/a | yes |
| <a name="input_breach_action"></a> [breach\_action](#input\_breach\_action) | The action that Amazon Redshift takes when the limit is reached. The default is log. | `string` | `null` | no |
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | The identifier of the cluster that you want to limit usage. | `string` | n/a | yes |
| <a name="input_period"></a> [period](#input\_period) | The time period that the amount applies to. A weekly period begins on Sunday. The default is monthly. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_validate_feature_limit"></a> [validate\_feature\_limit](#input\_validate\_feature\_limit) | The type of limit. Depending on the feature type, this can be based on a time duration or data size. If FeatureType is spectrum, then LimitType must be data-scanned. If FeatureType is concurrency-scaling, then LimitType must be time. If FeatureType is cross-region-datasharing, then LimitType must be data-scanned. Valid values are data-scanned, and time. | <pre>object({<br/>    feature_type = string<br/>    limit_type   = string<br/>  })</pre> | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_redshift_usage_limit_all"></a> [aws\_redshift\_usage\_limit\_all](#output\_aws\_redshift\_usage\_limit\_all) | A map of aws redshift usage limit attribute references |
| <a name="output_usage_limit_arn"></a> [usage\_limit\_arn](#output\_usage\_limit\_arn) | Amazon Resource Name (ARN) of the Redshift Usage Limit. |
| <a name="output_usage_limit_id"></a> [usage\_limit\_id](#output\_usage\_limit\_id) | The Redshift Usage Limit ID. |

<!-- END_TF_DOCS -->