<!-- BEGIN_TF_DOCS -->
# AWS AppConfig module
Terraform module which creates SAF2.0 AppConfig environment in AWS

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.0 |

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
| [aws_appconfig_environment.pge_env](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_environment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_id"></a> [application\_id](#input\_application\_id) | An application ID | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | The description of the AppConfig application. | `string` | `null` | no |
| <a name="input_monitors"></a> [monitors](#input\_monitors) | A map of monitors for your deployment. | `set(any)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the AppConfig application. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the AppConfig Environment. |
| <a name="output_id"></a> [id](#output\_id) | The environment\_id generatd by AWS |
| <a name="output_state"></a> [state](#output\_state) | State of the environment. |
| <a name="output_tags"></a> [tags](#output\_tags) | A map of all tags assigned to the environment. |

<!-- END_TF_DOCS -->