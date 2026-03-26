<!-- BEGIN_TF_DOCS -->
# AWS Amplify Webhook module.
Terraform module which creates SAF2.0 Amplify Webhook in AWS.

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
| [aws_amplify_webhook.amplify_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_webhook) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | Unique ID for an Amplify app. | `string` | n/a | yes |
| <a name="input_branch_name"></a> [branch\_name](#input\_branch\_name) | Name for a branch that is part of the Amplify app. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description for a webhook. | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amplify_webhook"></a> [amplify\_webhook](#output\_amplify\_webhook) | A map of aws amplify webhook |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN for the webhook. |
| <a name="output_url"></a> [url](#output\_url) | URL of the webhook. |

<!-- END_TF_DOCS -->