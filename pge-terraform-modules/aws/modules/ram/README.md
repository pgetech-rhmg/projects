<!-- BEGIN_TF_DOCS -->
# AWS Backup RAM module
Terraform module which creates SAF2.0  AWS RAM Share resources
AWS Resource Access Manager (AWS RAM) is a service that allows you to share resources that are created and managed by other AWS services.

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
| <a name="provider_external"></a> [external](#provider\_external) | n/a |

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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.0 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ram_resource_share.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_external_principals"></a> [allow\_external\_principals](#input\_allow\_external\_principal) | Change to true to  allow principals to be associated with the resource share | `bool` | `false` | no |
| <a name="input_permission_arns"></a> [permission\_arns](#permission\_arns) | List of RAM permission ARNs to be attached to resource share | `list(string)`  no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_share_name"></a> [share\_name](#input\_share\_name) | Name of the RAM Share to create | `string` | n/a | yes |  

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_share"></a> [resource\_share](#output\_resource\_share) | Map of Resource share object |
| <a name="output_name"></a> [name](#output\_name) | The name of the RAM share created |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) specifying the RAM share |

<!-- END_TF_DOCS -->