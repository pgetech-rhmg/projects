<!-- BEGIN_TF_DOCS -->
# AWS Amplify Branch module.
Terraform module which creates SAF2.0 Amplify Branch in AWS.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.1 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_amplify_branch.amplify_branch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_branch) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | Unique ID for an Amplify app. | `string` | n/a | yes |
| <a name="input_backend_environment_arn"></a> [backend\_environment\_arn](#input\_backend\_environment\_arn) | ARN for a backend environment that is part of an Amplify app. | `string` | `null` | no |
| <a name="input_basic_auth_credentials"></a> [basic\_auth\_credentials](#input\_basic\_auth\_credentials) | Basic authorization credentials for the branch. | `string` | `null` | no |
| <a name="input_branch_name"></a> [branch\_name](#input\_branch\_name) | Name for the branch. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description for the branch. | `string` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Display name for a branch. This is used as the default domain prefix. | `string` | `null` | no |
| <a name="input_enable_auto_build"></a> [enable\_auto\_build](#input\_enable\_auto\_build) | Enables auto building for the branch. | `string` | `null` | no |
| <a name="input_enable_basic_auth"></a> [enable\_basic\_auth](#input\_enable\_basic\_auth) | Enables basic authorization for the branch. | `string` | `null` | no |
| <a name="input_enable_notification"></a> [enable\_notification](#input\_enable\_notification) | Enables notifications for the branch. | `string` | `null` | no |
| <a name="input_enable_performance_mode"></a> [enable\_performance\_mode](#input\_enable\_performance\_mode) | Enables performance mode for the branch. | `bool` | `null` | no |
| <a name="input_enable_pull_request_preview"></a> [enable\_pull\_request\_preview](#input\_enable\_pull\_request\_preview) | Enables pull request previews for this branch. | `bool` | `null` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables for the branch. | `map(string)` | `null` | no |
| <a name="input_framework"></a> [framework](#input\_framework) | Framework for the branch. | `string` | `null` | no |
| <a name="input_pull_request_environment_name"></a> [pull\_request\_environment\_name](#input\_pull\_request\_environment\_name) | Amplify environment name for the pull request. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Describes the current stage for the branch. Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL\_REQUEST. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags. | `map(string)` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | Content Time To Live (TTL) for the website in seconds. | `number` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amplify_branch"></a> [amplify\_branch](#output\_amplify\_branch) | A map of aws amplify branch |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN for the branch. |
| <a name="output_associated_resources"></a> [associated\_resources](#output\_associated\_resources) | A list of custom resources that are linked to this branch. |
| <a name="output_custom_domains"></a> [custom\_domains](#output\_custom\_domains) | Custom domains for the branch. |
| <a name="output_destination_branch"></a> [destination\_branch](#output\_destination\_branch) | Destination branch if the branch is a pull request branch. |
| <a name="output_source_branch"></a> [source\_branch](#output\_source\_branch) | Source branch if the branch is a pull request branch. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->