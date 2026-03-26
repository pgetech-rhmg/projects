<!-- BEGIN_TF_DOCS -->
# AWS AppConfig module
Terraform module which creates SAF2.0 AppConfig deployment in AWS

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
| <a name="provider_external"></a> [external](#provider\_external) | ~> 2.0 |

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
| [aws_appconfig_deployment.pge_deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_deployment) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_id"></a> [application\_id](#input\_application\_id) | The id of the application to deploy. | `string` | n/a | yes |
| <a name="input_configuration_profile_id"></a> [configuration\_profile\_id](#input\_configuration\_profile\_id) | The id of the configuration profile to use. | `string` | n/a | yes |
| <a name="input_configuration_version"></a> [configuration\_version](#input\_configuration\_version) | The configuration version to deplopy. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | The description of the AppConfig application. | `string` | `null` | no |
| <a name="input_environment_id"></a> [environment\_id](#input\_environment\_id) | The id of the environment to use. | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The KMS key to be used for encryption. Can be a key ID, alias, or ARN of the key ID or alias. | `string` | `null` | no |
| <a name="input_strategy_id"></a> [strategy\_id](#input\_strategy\_id) | The id of the deployment strategy to use. | `string` | `"AppConfig.AllAtOnce"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the AppConfig Deployment. |
| <a name="output_id"></a> [id](#output\_id) | AppConfig Application ID, Environment ID, and deployment number separated by a slash. |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | ARN of the KMS key used to encrypt the configuration data. |
| <a name="output_number"></a> [number](#output\_number) | The deployment number |
| <a name="output_state"></a> [state](#output\_state) | State of the deployment. |
| <a name="output_tags"></a> [tags](#output\_tags) | A map of tags assigned to the resource. |

<!-- END_TF_DOCS -->