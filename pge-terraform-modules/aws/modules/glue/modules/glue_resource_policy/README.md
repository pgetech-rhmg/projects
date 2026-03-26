<!-- BEGIN_TF_DOCS -->
*# AWS Glue resource policy module.
*Terraform module which creates SAF2.0 Glue resource policy in AWS.

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
| [aws_glue_resource_policy.glue_resource_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_resource_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_glue_enable_hybrid"></a> [glue\_enable\_hybrid](#input\_glue\_enable\_hybrid) | Indicates that you are using both methods to grant cross-account. Valid values are TRUE and FALSE. Note the terraform will not perform drift detetction on this field as its not return on read. | `string` | `null` | no |
| <a name="input_glue_resource_policy"></a> [glue\_resource\_policy](#input\_glue\_resource\_policy) | The policy to be applied to the aws glue data catalog. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_resource_policy"></a> [aws\_glue\_resource\_policy](#output\_aws\_glue\_resource\_policy) | The map of aws\_glue\_resource\_policy. |


<!-- END_TF_DOCS -->