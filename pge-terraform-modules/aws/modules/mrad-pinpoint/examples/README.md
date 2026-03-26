<!-- BEGIN_TF_DOCS -->
# AWS Pinpoint usage example.
Terraform module which creates SAF2.0 Pinpoint resources in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

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
| <a name="module_mrad-common"></a> [mrad-common](#module\_mrad-common) | app.terraform.io/pgetech/mrad-common/aws | ~> 1.0 |
| <a name="module_pinpoint"></a> [pinpoint](#module\_pinpoint) | ../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number - predefined in TFC | `string` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name of the Pinpoint application | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume - predefined in TFC | `string` | n/a | yes |
| <a name="input_enable_email"></a> [enable\_email](#input\_enable\_email) | Enable Email channel | `bool` | `false` | no |
| <a name="input_enable_push"></a> [enable\_push](#input\_enable\_push) | Enable Push Notifications | `bool` | `false` | no |
| <a name="input_enable_sms"></a> [enable\_sms](#input\_enable\_sms) | Enable SMS channel | `bool` | `false` | no | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->