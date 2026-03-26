<!-- BEGIN_TF_DOCS -->
# AWS dms replication instance and subnet groups
Terraform module which creates SAF2.0 codepipeline in AWS

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.1.0 |
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
| [aws_dms_event_subscription.eventone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_event_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_event_categories"></a> [event\_categories](#input\_event\_categories) | List of event categories to listen for, see DescribeEventCategories for a canonical list. | `list(string)` | `null` | no |
| <a name="input_event_enabled"></a> [event\_enabled](#input\_event\_enabled) | Whether the event subscription should be enabled. | `bool` | `null` | no |
| <a name="input_event_name"></a> [event\_name](#input\_event\_name) | Name of event subscription. | `string` | n/a | yes |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | SNS topic arn to send events on. | `string` | n/a | yes |
| <a name="input_source_ids"></a> [source\_ids](#input\_source\_ids) | Ids of sources to listen to. | `list(string)` | n/a | yes |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | Type of source for events. Valid values: replication-instance or replication-task | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_timeouts_create"></a> [timeouts\_create](#input\_timeouts\_create) | Used for Creating Instances | `string` | `"40m"` | no |
| <a name="input_timeouts_delete"></a> [timeouts\_delete](#input\_timeouts\_delete) | Used for destroying databases | `string` | `"80m"` | no |
| <a name="input_timeouts_update"></a> [timeouts\_update](#input\_timeouts\_update) | Used for Database modifications | `string` | `"80m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dms_event_subscription_all"></a> [dms\_event\_subscription\_all](#output\_dms\_event\_subscription\_all) | A map of aws dms event subscription |
| <a name="output_event_subscription_arn"></a> [event\_subscription\_arn](#output\_event\_subscription\_arn) | Amazon Resource Name (ARN) of the DMS Event Subscription. |


<!-- END_TF_DOCS -->