<!-- BEGIN_TF_DOCS -->
*#AWS Glue registry module.
*Terraform module which creates SAF2.0 Glue registry in AWS.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_glue_registry.glue_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_registry) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_glue_registry_description"></a> [glue\_registry\_description](#input\_glue\_registry\_description) | A description of the registry. | `string` | `null` | no |
| <a name="input_glue_registry_name"></a> [glue\_registry\_name](#input\_glue\_registry\_name) | The Name of the registry. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_registry"></a> [aws\_glue\_registry](#output\_aws\_glue\_registry) | A map of aws\_glue\_registry object. |
| <a name="output_glue_registry_arn"></a> [glue\_registry\_arn](#output\_glue\_registry\_arn) | Amazon Resource Name (ARN) of Glue Registry. |
| <a name="output_glue_registry_id"></a> [glue\_registry\_id](#output\_glue\_registry\_id) | Amazon Resource Name (ARN) of Glue Registry. |
| <a name="output_glue_registry_tags_all"></a> [glue\_registry\_tags\_all](#output\_glue\_registry\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->