<!-- BEGIN_TF_DOCS -->
# AWS SNS Subscription module
Terraform module which creates SAF2.0 SNS Subscription in AWS

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
| [aws_sns_topic_subscription.sns_topic_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_confirmation_timeout_in_minutes"></a> [confirmation\_timeout\_in\_minutes](#input\_confirmation\_timeout\_in\_minutes) | Integer indicating number of minutes to wait in retrying mode for fetching subscription arn before marking it as failure. Only applicable for http and https protocols | `number` | `null` | no |
| <a name="input_delivery_policy"></a> [delivery\_policy](#input\_delivery\_policy) | JSON String with the delivery policy (retries, backoff, etc.) that will be used in the subscription - this only applies to HTTP/S subscriptions | `string` | `null` | no |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Endpoint to send data to. The contents vary with the protocol | `list(string)` | n/a | yes |
| <a name="input_endpoint_auto_confirms"></a> [endpoint\_auto\_confirms](#input\_endpoint\_auto\_confirms) | Whether the endpoint is capable of auto confirming subscription | `bool` | `false` | no |
| <a name="input_filter_policy"></a> [filter\_policy](#input\_filter\_policy) | JSON String with the filter policy that will be used in the subscription to filter messages seen by the target resource | `string` | `null` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application.Protocols email, email-json, http and https are also valid but partially supported. | `string` | `"email"` | no |
| <a name="input_raw_message_delivery"></a> [raw\_message\_delivery](#input\_raw\_message\_delivery) | Whether to enable raw message delivery (the original message is directly passed, not wrapped in JSON with the original message in the message property) | `bool` | `false` | no |
| <a name="input_redrive_policy"></a> [redrive\_policy](#input\_redrive\_policy) | JSON String with the redrive policy that will be used in the subscription | `string` | `null` | no |
| <a name="input_subscription_role_arn"></a> [subscription\_role\_arn](#input\_subscription\_role\_arn) | ARN of the IAM role to publish to Kinesis Data Firehose delivery stream | `string` | `null` | no |
| <a name="input_topic_arn"></a> [topic\_arn](#input\_topic\_arn) | ARN of the SNS topic to subscribe to. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sns_subscription_arn"></a> [sns\_subscription\_arn](#output\_sns\_subscription\_arn) | ARN of the subscription |
| <a name="output_sns_subscription_confirmation_was_authenticated"></a> [sns\_subscription\_confirmation\_was\_authenticated](#output\_sns\_subscription\_confirmation\_was\_authenticated) | Whether the subscription confirmation request was authenticated |
| <a name="output_sns_subscription_owner_id"></a> [sns\_subscription\_owner\_id](#output\_sns\_subscription\_owner\_id) | AWS account ID of the subscription's owner |
| <a name="output_sns_subscription_pending_confirmation"></a> [sns\_subscription\_pending\_confirmation](#output\_sns\_subscription\_pending\_confirmation) | Whether the subscription has not been confirmed |
| <a name="output_sns_topic_subscription_all"></a> [sns\_topic\_subscription\_all](#output\_sns\_topic\_subscription\_all) | A map of aws sns topic subscription |

<!-- END_TF_DOCS -->