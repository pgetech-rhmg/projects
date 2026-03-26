<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.0 |

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
| [aws_redshift_event_subscription.redshift_event_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_event_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enabled"></a> [enabled](#input\_enabled) | A boolean flag to enable/disable the subscription.Defaults to true. | `bool` | `true` | no |
| <a name="input_event_categories"></a> [event\_categories](#input\_event\_categories) | A list of event categories for a SourceType that you want to subscribe to. | `list(string)` | `null` | no |
| <a name="input_event_subscription_name"></a> [event\_subscription\_name](#input\_event\_subscription\_name) | The name of the Redshift event subscription. | `string` | n/a | yes |
| <a name="input_redshift_source"></a> [redshift\_source](#input\_redshift\_source) | source\_ids:<br/>   A list of identifiers of the event sources for which events will be returned. If not specified, then all sources are included in the response. If specified, a source\_type must also be specified.<br/>source\_type:<br/>  The type of source that will be generating the events. Valid options are cluster,cluster-parameter-group,cluster-security-group,cluster-snapshot,scheduled-action. If not set, all sources will be subscribed to. | <pre>object({<br/>    source_ids  = list(string)<br/>    source_type = string<br/>  })</pre> | <pre>{<br/>  "source_ids": null,<br/>  "source_type": null<br/>}</pre> | no |
| <a name="input_severity"></a> [severity](#input\_severity) | The event severity to be published by the notification subscription. | `string` | `"INFO"` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | The ARN of the SNS topic to send events to. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_redshift_event_subscription_all"></a> [aws\_redshift\_event\_subscription\_all](#output\_aws\_redshift\_event\_subscription\_all) | A map of aws redshift event subscription attributes references |
| <a name="output_redshift_event_subscription_arn"></a> [redshift\_event\_subscription\_arn](#output\_redshift\_event\_subscription\_arn) | Amazon Resource Name (ARN) of the Redshift event notification subscription |
| <a name="output_redshift_event_subscription_customer_aws_id"></a> [redshift\_event\_subscription\_customer\_aws\_id](#output\_redshift\_event\_subscription\_customer\_aws\_id) | The AWS customer account associated with the Redshift event notification subscription |
| <a name="output_redshift_event_subscription_id"></a> [redshift\_event\_subscription\_id](#output\_redshift\_event\_subscription\_id) | The name of the Redshift event notification subscription |
| <a name="output_redshift_event_subscription_tags_all"></a> [redshift\_event\_subscription\_tags\_all](#output\_redshift\_event\_subscription\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider. |

<!-- END_TF_DOCS -->