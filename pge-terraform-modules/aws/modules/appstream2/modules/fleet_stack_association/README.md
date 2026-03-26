<!-- BEGIN_TF_DOCS -->
# AWS AppStream2.0 fleet\_stack\_association module
Terraform module which creates fleet\_stack\_association for AppStream2.0

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
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
| [aws_appstream_fleet_stack_association.fleet_stack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appstream_fleet_stack_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_fleet_name"></a> [fleet\_name](#input\_fleet\_name) | Name of the fleet. | `string` | n/a | yes |
| <a name="input_stack_name"></a> [stack\_name](#input\_stack\_name) | Name of the stack. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id_fleet_all"></a> [id\_fleet\_all](#output\_id\_fleet\_all) | Map of all id\_fleet attributes |
| <a name="output_id_fleet_stack"></a> [id\_fleet\_stack](#output\_id\_fleet\_stack) | Unique ID of the appstream stack fleet association, composed of the fleet\_name and stack\_name separated by a slash (/). |


<!-- END_TF_DOCS -->