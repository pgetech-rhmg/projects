<!-- BEGIN_TF_DOCS -->
# AWS FIS Experiment Template Module
Terraform usage example which creates an FIS experiment template in AWS.
AWS FIS (Fault Injection Simulator) is a fully managed service
that enables you to perform fault injection experiments on your AWS workloads.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.25.0 |

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
| <a name="module_fis_role"></a> [fis\_role](#module\_fis\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_fis_experiment_template.experiment_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fis_experiment_template) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_log_group) | data source |
| [aws_iam_role.fis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_s3_bucket.fis_logs_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action"></a> [action](#input\_action) | List of fault injection actions to perform during the FIS experiment. Each action defines what fault to inject and on which targets. | <pre>list(object({<br/>    name        = string<br/>    action_id   = string<br/>    description = string<br/>    start_after = optional(list(string), [])<br/>    parameter   = optional(map(string), {})<br/>    target = list(object({<br/>      key   = string<br/>      value = string<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | List of AWS services that the IAM role will assume. Defaults to ['fis.amazonaws.com'] if not specified. | `list(string)` | `null` | no |
| <a name="input_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#input\_cloudwatch\_log\_group\_arn) | ARN of the CloudWatch Log Group to use for FIS experiment logs. If provided, takes precedence over cloudwatch\_log\_group\_name. | `string` | `""` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Name of the CloudWatch Log Group to use for FIS experiment logs. Required when log\_type is set to 'cloudwatch'. | `string` | `""` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the FIS experiment template that explains the purpose of the experiment. | `string` | `""` | no |
| <a name="input_experiment_options"></a> [experiment\_options](#input\_experiment\_options) | Configuration options for the FIS experiment, including account targeting and target resolution behavior. | <pre>object({<br/>    account_targeting            = string<br/>    empty_target_resolution_mode = string<br/>  })</pre> | n/a | yes |
| <a name="input_experiment_report_configuration"></a> [experiment\_report\_configuration](#input\_experiment\_report\_configuration) | Configuration for generating experiment reports after completion. Includes data sources and output destinations. Set to null to disable reports. | <pre>object({<br/>    data_sources = optional(object({<br/>      cloudwatch_dashboard = optional(list(object({<br/>        dashboard_arn = string<br/>      })), [])<br/>    }), {})<br/>    outputs = optional(object({<br/>      s3_configuration = optional(object({<br/>        bucket_name = string<br/>        prefix      = optional(string, "")<br/>      }))<br/>    }))<br/>    post_experiment_duration = optional(string, "PT5M")<br/>    pre_experiment_duration  = optional(string, "PT5M")<br/>  })</pre> | `null` | no |
| <a name="input_fis_experiment_name"></a> [fis\_experiment\_name](#input\_fis\_experiment\_name) | Name for the Fault Injection experiment, used for easier identification withing FIS. | `string` | n/a | yes |
| <a name="input_fis_role_name"></a> [fis\_role\_name](#input\_fis\_role\_name) | Name of an existing IAM role to use for FIS experiments. If empty, a new role will be generated with the following format 'fis-role-<fis\_experiment\_name>'. | `string` | `""` | no |
| <a name="input_inline_policy"></a> [inline\_policy](#input\_inline\_policy) | List of inline policy documents in JSON format to attach to the IAM role. These will be appended to the default FIS policy. | `list(string)` | `[]` | no |
| <a name="input_log_schema_version"></a> [log\_schema\_version](#input\_log\_schema\_version) | Version of the log schema for FIS experiment logs. Supported values: 1 or 2. | `number` | `1` | no |
| <a name="input_log_type"></a> [log\_type](#input\_log\_type) | Type of logging to use for FIS experiments. Valid values: 's3' or 'cloudwatch'. | `string` | `"s3"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the S3 bucket to use for FIS experiment logs. Required when log\_type is set to 's3'. | `string` | `""` | no |
| <a name="input_s3_logging"></a> [s3\_logging](#input\_s3\_logging) | Configuration object for S3 logging, including the prefix for log file organization. | <pre>object({<br/>    prefix = string<br/>  })</pre> | <pre>{<br/>  "prefix": ""<br/>}</pre> | no |
| <a name="input_stop_condition"></a> [stop\_condition](#input\_stop\_condition) | List of stop conditions that will halt the FIS experiment if triggered. Each condition has a source and value. | <pre>list(object({<br/>    source = string<br/>    value  = string<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_target"></a> [target](#input\_target) | List of target resources for the FIS experiment. Defines which AWS resources will be affected by the experiment actions. | <pre>list(object({<br/>    name           = string<br/>    resource_type  = string<br/>    selection_mode = string<br/><br/>    # Optional filter block<br/>    filter = optional(list(object({<br/>      path   = string<br/>      values = list(string)<br/>    })), [])<br/><br/>    # Optional resource ARNs<br/>    resource_arns = optional(list(string), [])<br/><br/>    # Optional parameters<br/>    parameters = optional(map(string), null)<br/><br/>    # Optional resource tags<br/>    resource_tags = optional(list(object({<br/>      key   = string<br/>      value = string<br/>    })), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_validate_s3_bucket"></a> [validate\_s3\_bucket](#input\_validate\_s3\_bucket) | Whether to validate that the S3 bucket exists. Set to false when the bucket is created in the same deployment. | `bool` | `false` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_iam_role"></a> [aws\_iam\_role](#output\_aws\_iam\_role) | Outputs the IAM role resource used for AWS Fault Injection Simulator (FIS) operations. |
| <a name="output_fis_experimental_template"></a> [fis\_experimental\_template](#output\_fis\_experimental\_template) | Outputs the experimental template resource for AWS Fault Injection Simulator (FIS). |

<!-- END_TF_DOCS -->