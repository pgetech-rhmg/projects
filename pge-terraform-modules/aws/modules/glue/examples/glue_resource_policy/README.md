<!-- BEGIN_TF_DOCS -->
*# AWS GLUE with usage example
*Terraform module which creates SAF2.0 Glue Resource Policy resources in AWS.

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
| <a name="module_glue_resource_policy"></a> [glue\_resource\_policy](#module\_glue\_resource\_policy) | ../../../glue/modules/glue_resource_policy | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_glue_enable_hybrid"></a> [glue\_enable\_hybrid](#input\_glue\_enable\_hybrid) | Indicates that you are using both methods to grant cross-account. Valid values are TRUE and FALSE. Note the terraform will not perform drift detetction on this field as its not return on read. | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | role name | `string` | n/a | yes |

## Outputs

No outputs.


<!-- END_TF_DOCS -->