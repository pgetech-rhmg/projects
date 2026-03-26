<!-- BEGIN_TF_DOCS -->
# AWS Step Functions State Machine
Terraform module which creates SAF2.0 step functions state machine in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.93.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.1 |

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
| [aws_sfn_state_machine.state_machine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_include_execution_data"></a> [include\_execution\_data](#input\_include\_execution\_data) | Determines whether execution data is included in your log. When set to false, data is excluded. | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The KMS key to be used for encryption. Can be a key ID, alias, or ARN of the key ID or alias. | `string` | `null` | no |
| <a name="input_kms_key_type"></a> [kms\_key\_type](#input\_kms\_key\_type) | The encryption option specified for the state machine | `string` | `"AWS_OWNED_KEY"` | no |
| <a name="input_level"></a> [level](#input\_level) | Defines which category of execution history events are logged. Valid values: ALL, ERROR & FATAL. | `string` | `"ALL"` | no |
| <a name="input_log_destination"></a> [log\_destination](#input\_log\_destination) | Amazon Resource Name (ARN) of a CloudWatch log group. Make sure the State Machine has the correct IAM policies for logging. | `string` | n/a | yes |
| <a name="input_publish"></a> [publish](#input\_publish) | Boolean flag to control whether to publish a version of the state machine during creation. | `bool` | `false` | no |
| <a name="input_state_machine_definition"></a> [state\_machine\_definition](#input\_state\_machine\_definition) | The Amazon States Language definition of the state machine. | `string` | n/a | yes |
| <a name="input_state_machine_name"></a> [state\_machine\_name](#input\_state\_machine\_name) | The name of the state machine. To enable logging with CloudWatch Logs, the name should only contain 0-9, A-Z, a-z, - and \_. | `string` | n/a | yes |
| <a name="input_state_machine_role_arn"></a> [state\_machine\_role\_arn](#input\_state\_machine\_role\_arn) | The Amazon Resource Name (ARN) of the IAM role to use for this state machine. | `string` | n/a | yes |
| <a name="input_state_machine_type"></a> [state\_machine\_type](#input\_state\_machine\_type) | Determines whether a Standard or Express state machine is created. The default is STANDARD. | `string` | `"STANDARD"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags. | `map(string)` | n/a | yes |
| <a name="input_tracing_configuration_enabled"></a> [tracing\_configuration\_enabled](#input\_tracing\_configuration\_enabled) | When set to true, AWS X-Ray tracing is enabled. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sfn_state_machine_all"></a> [sfn\_state\_machine\_all](#output\_sfn\_state\_machine\_all) | A map of aws sfn state machine |
| <a name="output_state_machine_arn"></a> [state\_machine\_arn](#output\_state\_machine\_arn) | The ARN of the state machine. |
| <a name="output_state_machine_creation_date"></a> [state\_machine\_creation\_date](#output\_state\_machine\_creation\_date) | The date the state machine was created. |
| <a name="output_state_machine_id"></a> [state\_machine\_id](#output\_state\_machine\_id) | The ARN of the state machine. |
| <a name="output_state_machine_status"></a> [state\_machine\_status](#output\_state\_machine\_status) | The current status of the state machine. Either ACTIVE or DELETING. |
| <a name="output_state_machine_tags_all"></a> [state\_machine\_tags\_all](#output\_state\_machine\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_state_machine_version_arn"></a> [state\_machine\_version\_arn](#output\_state\_machine\_version\_arn) | The ARN of the state machine version. |


<!-- END_TF_DOCS -->