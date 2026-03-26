<!-- BEGIN_TF_DOCS -->
# AWS Glue Trigger module.
Terraform module which creates SAF2.0 Glue Trigger in AWS.

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
| [aws_glue_trigger.glue_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_trigger) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_event_batching_condition"></a> [event\_batching\_condition](#input\_event\_batching\_condition) | Batch condition that must be met (specified number of events received or batch time window expired) before EventBridge event trigger fires. | `map(number)` | `{}` | no |
| <a name="input_glue_trigger_actions"></a> [glue\_trigger\_actions](#input\_glue\_trigger\_actions) | List of actions initiated by this trigger when it fires. | `list(map(string))` | n/a | yes |
| <a name="input_glue_trigger_description"></a> [glue\_trigger\_description](#input\_glue\_trigger\_description) | A description of the glue trigger. | `string` | `null` | no |
| <a name="input_glue_trigger_enabled"></a> [glue\_trigger\_enabled](#input\_glue\_trigger\_enabled) | Start the trigger. Defaults to true. | `bool` | `true` | no |
| <a name="input_glue_trigger_name"></a> [glue\_trigger\_name](#input\_glue\_trigger\_name) | The name of the trigger. | `string` | n/a | yes |
| <a name="input_glue_trigger_predicate"></a> [glue\_trigger\_predicate](#input\_glue\_trigger\_predicate) | A predicate to specify when the new trigger should fire.Required when trigger type is CONDITIONAL. | `list(map(string))` | `[]` | no |
| <a name="input_glue_trigger_schedule"></a> [glue\_trigger\_schedule](#input\_glue\_trigger\_schedule) | A cron expression used to specify the schedule. | `string` | `null` | no |
| <a name="input_glue_trigger_start_on_creation"></a> [glue\_trigger\_start\_on\_creation](#input\_glue\_trigger\_start\_on\_creation) | Set to true to start SCHEDULED and CONDITIONAL triggers when created. True is not supported for ON\_DEMAND triggers. | `bool` | `null` | no |
| <a name="input_glue_trigger_type"></a> [glue\_trigger\_type](#input\_glue\_trigger\_type) | The type of trigger.Valid values are CONDITIONAL, ON\_DEMAND, and SCHEDULED. | `string` | n/a | yes |
| <a name="input_glue_trigger_workflow_name"></a> [glue\_trigger\_workflow\_name](#input\_glue\_trigger\_workflow\_name) | A workflow to which the trigger should be associated to. Every workflow graph (DAG) needs a starting trigger (ON\_DEMAND or SCHEDULED type) and can contain multiple additional CONDITIONAL triggers. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_trigger"></a> [aws\_glue\_trigger](#output\_aws\_glue\_trigger) | A map of aws\_glue\_trigger object |
| <a name="output_glue_trigger_arn"></a> [glue\_trigger\_arn](#output\_glue\_trigger\_arn) | Amazon Resource Name (ARN) of Glue Trigger |
| <a name="output_glue_trigger_id"></a> [glue\_trigger\_id](#output\_glue\_trigger\_id) | Trigger name |
| <a name="output_glue_trigger_state"></a> [glue\_trigger\_state](#output\_glue\_trigger\_state) | The current state of the trigger. |
| <a name="output_glue_trigger_tags_all"></a> [glue\_trigger\_tags\_all](#output\_glue\_trigger\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags |


<!-- END_TF_DOCS -->