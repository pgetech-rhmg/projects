<!-- BEGIN_TF_DOCS -->
# AWS AppConfig simple module
Terraform module which creates SAF2.0 simplified, full Appconfig resource in AWS

This module is to create a rapid, simple deployment of a single AppConfig application, environment,
configuration profile, and hosted configuration version. See the "appconfig\_simple" example for usage.
If you need more flexibility (like multiple of any resource) see the "appconfig\_complete" example for
how to create a modularized deployment.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.91.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.4 |

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
| <a name="module_application"></a> [application](#module\_application) | ./modules/application | n/a |
| <a name="module_configuration_profile"></a> [configuration\_profile](#module\_configuration\_profile) | ./modules/configuration_profile | n/a |
| <a name="module_environment"></a> [environment](#module\_environment) | ./modules/environment | n/a |
| <a name="module_hosted_configuration_version"></a> [hosted\_configuration\_version](#module\_hosted\_configuration\_version) | ./modules/hosted_configuration_version | n/a |
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_profile_description"></a> [config\_profile\_description](#input\_config\_profile\_description) | The description of the AppConfig configuration profile. | `string` | n/a | yes |
| <a name="input_config_profile_name"></a> [config\_profile\_name](#input\_config\_profile\_name) | The name of the AppConfig configuration profile. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | The description of the AppConfig application. | `string` | `null` | no |
| <a name="input_env_description"></a> [env\_description](#input\_env\_description) | The description of the AppConfig environment. | `string` | `null` | no |
| <a name="input_env_monitors"></a> [env\_monitors](#input\_env\_monitors) | A map of monitors for your environment. | `set(any)` | `[]` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | The name of the AppConfig environment. | `string` | n/a | yes |
| <a name="input_hosted_config_content"></a> [hosted\_config\_content](#input\_hosted\_config\_content) | Content of the configuration data | `string` | n/a | yes |
| <a name="input_hosted_config_content_type"></a> [hosted\_config\_content\_type](#input\_hosted\_config\_content\_type) | Standard MIME type describing the format of the configuration content. | `string` | `"application/json"` | no |
| <a name="input_hosted_config_description"></a> [hosted\_config\_description](#input\_hosted\_config\_description) | The description of the AppConfig Configuration Profile description. | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The KMS key to be used for encryption. Can be a key ID, alias, or ARN of the key ID or alias. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the AppConfig application. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_arn"></a> [application\_arn](#output\_application\_arn) | The AppConfig application ARN |
| <a name="output_application_id"></a> [application\_id](#output\_application\_id) | The AppConfig application ID |
| <a name="output_application_tags"></a> [application\_tags](#output\_application\_tags) | All tags associated with the application. |
| <a name="output_configuration_profile_arn"></a> [configuration\_profile\_arn](#output\_configuration\_profile\_arn) | The ARN generated by AWS |
| <a name="output_configuration_profile_id"></a> [configuration\_profile\_id](#output\_configuration\_profile\_id) | The AppConfig configuration profile ID |
| <a name="output_configuration_profile_tags"></a> [configuration\_profile\_tags](#output\_configuration\_profile\_tags) | A map of all tags associated with the resource. |
| <a name="output_environment_arn"></a> [environment\_arn](#output\_environment\_arn) | ARN of the AppConfig Environment. |
| <a name="output_environment_id"></a> [environment\_id](#output\_environment\_id) | The AppConfig environment ID |
| <a name="output_environment_state"></a> [environment\_state](#output\_environment\_state) | State of the environment. |
| <a name="output_environment_tags"></a> [environment\_tags](#output\_environment\_tags) | A map of all tags assigned to the environment. |
| <a name="output_hosted_configuration_arn"></a> [hosted\_configuration\_arn](#output\_hosted\_configuration\_arn) | The ARN generated by AWS |
| <a name="output_hosted_configuration_id"></a> [hosted\_configuration\_id](#output\_hosted\_configuration\_id) | The Configuration Profile ID generated by AWS |
| <a name="output_hosted_configuration_version"></a> [hosted\_configuration\_version](#output\_hosted\_configuration\_version) | Version number of the hosted configuration. |

<!-- END_TF_DOCS -->