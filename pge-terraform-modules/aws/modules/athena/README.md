<!-- BEGIN_TF_DOCS -->
Athena Workgroup Module

Description:
  Provisions an AWS Athena Workgroup with configurable
  result output location, optional KMS encryption,
  and CloudWatch metrics publishing.

This module intentionally deploys only the base Athena
workgroup resource. Optional integrations such as
AWS Glue databases, tables, or federated connectors
are implemented as separate submodules for composability.

Resources Created:
  - aws\_athena\_workgroup

Module Path:
  aws/modules/athena

Author:
  PG&E

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
| [aws_athena_workgroup.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_athena_workgroup_name"></a> [athena\_workgroup\_name](#input\_athena\_workgroup\_name) | Name of the Athena Workgroup to be created. | `string` | n/a | yes |
| <a name="input_enforce_workgroup_configuration"></a> [enforce\_workgroup\_configuration](#input\_enforce\_workgroup\_configuration) | If true, enforces Workgroup settings and prevents client overrides. | `bool` | `true` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Optional KMS key ARN used to encrypt Athena query results. | `string` | `null` | no |
| <a name="input_output_location"></a> [output\_location](#input\_output\_location) | S3 path where Athena query results will be stored (e.g., s3://bucket/prefix/). | `string` | n/a | yes |
| <a name="input_publish_cloudwatch_metrics_enabled"></a> [publish\_cloudwatch\_metrics\_enabled](#input\_publish\_cloudwatch\_metrics\_enabled) | Enables publishing of Athena Workgroup metrics to CloudWatch. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the Athena Workgroup, typically merged from PG&E standard tags. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_workgroup_arn"></a> [workgroup\_arn](#output\_workgroup\_arn) | ARN of the Athena Workgroup, used for referencing and IAM permissions. |
| <a name="output_workgroup_name"></a> [workgroup\_name](#output\_workgroup\_name) | Name of the Athena Workgroup created by this module. |

<!-- END_TF_DOCS -->