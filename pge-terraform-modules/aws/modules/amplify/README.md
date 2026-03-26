<!-- BEGIN_TF_DOCS -->
# AWS Amplify App module.
Terraform module which creates SAF2.0 Amplify App in AWS.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.73.0 |

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
| [aws_amplify_app.amplify_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_app) | resource |
| [aws_secretsmanager_secret.basic_auth_cred](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.github_access_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.basic_auth_cred_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.github_access_token_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_branch_creation_config"></a> [auto\_branch\_creation\_config](#input\_auto\_branch\_creation\_config) | {<br>  build\_spec                    : Build specification (build spec) for the autocreated branch.<br>  enable\_auto\_build             : Enables auto building for the autocreated branch.<br>  enable\_performance\_mode       : Enables performance mode for the branch.<br>  enable\_pull\_request\_preview   : Enables pull request previews for the autocreated branch.<br>  environment\_variables         : Environment variables for the autocreated branch.<br>  framework                     : Framework for the autocreated branch.<br>  pull\_request\_environment\_name : Amplify environment name for the pull request.<br>  stage                         : Describes the current stage for the autocreated branch. Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL\_REQUEST.<br>} | <pre>object({<br>    build_spec                    = string<br>    enable_auto_build             = bool<br>    enable_performance_mode       = bool<br>    enable_pull_request_preview   = bool<br>    environment_variables         = map(string)<br>    framework                     = string<br>    pull_request_environment_name = string<br>    stage                         = string<br>  })</pre> | <pre>{<br>  "build_spec": null,<br>  "enable_auto_build": null,<br>  "enable_performance_mode": null,<br>  "enable_pull_request_preview": null,<br>  "environment_variables": null,<br>  "framework": null,<br>  "pull_request_environment_name": null,<br>  "stage": null<br>}</pre> | no |
| <a name="input_auto_branch_creation_patterns"></a> [auto\_branch\_creation\_patterns](#input\_auto\_branch\_creation\_patterns) | Automated branch creation glob patterns for an Amplify app. | `list(string)` | `null` | no |
| <a name="input_build_spec"></a> [build\_spec](#input\_build\_spec) | The build specification (build spec) for an Amplify app. | `string` | `null` | no |
| <a name="input_custom_rule"></a> [custom\_rule](#input\_custom\_rule) | Custom rewrite and redirect rules for an Amplify app.<br>{<br> condition : Condition for a URL rewrite or redirect rule, such as a country code.<br> source    : Source pattern for a URL rewrite or redirect rule.<br> status    : Status code for a URL rewrite or redirect rule. Valid values: 200, 301, 302, 404, 404-200.<br> target    : Target pattern for a URL rewrite or redirect rule.<br>} | <pre>object({<br>    condition = string<br>    source    = string<br>    status    = string<br>    target    = string<br>  })</pre> | <pre>{<br>  "condition": null,<br>  "source": null,<br>  "status": null,<br>  "target": null<br>}</pre> | no |
| <a name="input_description"></a> [description](#input\_description) | Description for an Amplify app. | `string` | `null` | no |
| <a name="input_enable_auto_branch_creation"></a> [enable\_auto\_branch\_creation](#input\_enable\_auto\_branch\_creation) | Enables automated branch creation for an Amplify app. | `bool` | `null` | no |
| <a name="input_enable_branch_auto_build"></a> [enable\_branch\_auto\_build](#input\_enable\_branch\_auto\_build) | Enables auto-building of branches for the Amplify App. | `bool` | `null` | no |
| <a name="input_enable_branch_auto_deletion"></a> [enable\_branch\_auto\_deletion](#input\_enable\_branch\_auto\_deletion) | Automatically disconnects a branch in the Amplify Console when you delete a branch from your Git repository. | `bool` | `null` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables map for an Amplify app. | `map(string)` | `null` | no |
| <a name="input_github_repository_name"></a> [github\_repository\_name](#input\_github\_repository\_name) | Repository for an Amplify app. The github repository should be created under PGE organization. | `string` | n/a | yes |
| <a name="input_iam_service_role_arn"></a> [iam\_service\_role\_arn](#input\_iam\_service\_role\_arn) | AWS Identity and Access Management (IAM) service role for an Amplify app. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for an Amplify app. | `string` | n/a | yes |
| <a name="input_platform"></a> [platform](#input\_platform) | Platform or framework for an Amplify app. Valid values: WEB. | `string` | `"WEB"` | no |
| <a name="input_secretsmanager_basic_auth_cred_secret_name"></a> [secretsmanager\_basic\_auth\_cred\_secret\_name](#input\_secretsmanager\_basic\_auth\_cred\_secret\_name) | Enter the name of secrets manager for basic auth crentials | `string` | n/a | yes |
| <a name="input_secretsmanager_github_access_token_secret_name"></a> [secretsmanager\_github\_access\_token\_secret\_name](#input\_secretsmanager\_github\_access\_token\_secret\_name) | Enter the name of secrets manager for amplify personal access token. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amplify_app_all"></a> [amplify\_app\_all](#output\_amplify\_app\_all) | A map of aws amplify app |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the Amplify app. |
| <a name="output_default_domain"></a> [default\_domain](#output\_default\_domain) | Default domain for the Amplify app. |
| <a name="output_id"></a> [id](#output\_id) | Unique ID of the Amplify app. |
| <a name="output_production_branch"></a> [production\_branch](#output\_production\_branch) | Describes the information about a production branch for an Amplify app. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->