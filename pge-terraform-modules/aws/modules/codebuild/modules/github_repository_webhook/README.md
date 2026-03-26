<!-- BEGIN_TF_DOCS -->
# Prerequesties

### AWS Secrets Manager - GitHub Token
# For testing this example, you need to create a GitHub token and store it in AWS Secrets Manager.
# Provide the **ARN** of the secret in the variable "secretsmanager_github_token_secret_arn".
#
# Note: Previously, this variable used the secret name. It has now been updated to use the full ARN.
#
# Steps to create the secret in AWS Secrets Manager:
# 1. Create a plain text secret with the following key-value pairs:
#    - ServerType = GITHUB
#    - AuthType = PERSONAL_ACCESS_TOKEN
#    - Token = "your_personal_access_token"

# AWS Codebuild module creating Codebuild webhook and Github repository webhook
Terraform module which creates SAF2.0 Codebuild webhook and Github repository webhook.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_github"></a> [github](#provider\_github) | ~> 5.0 |

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
| [aws_codebuild_webhook.codebuild_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_webhook) | resource |
| [github_repository_webhook.repository_webhook](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_webhook) | resource |
| [aws_secretsmanager_secret.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_codebuild_webhook_branch_filter"></a> [codebuild\_webhook\_branch\_filter](#input\_codebuild\_webhook\_branch\_filter) | A regular expression used to determine which branches get built. Default is all branches are built | `string` | `null` | no |
| <a name="input_codebuild_webhook_build_type"></a> [codebuild\_webhook\_build\_type](#input\_codebuild\_webhook\_build\_type) | The type of build this webhook will trigger | `string` | `null` | no |
| <a name="input_codebuild_webhook_project_name"></a> [codebuild\_webhook\_project\_name](#input\_codebuild\_webhook\_project\_name) | The name of the build project. | `string` | n/a | yes |
| <a name="input_filter"></a> [filter](#input\_filter) | List of nested attributes | `any` | `[]` | no |
| <a name="input_github_active"></a> [github\_active](#input\_github\_active) | Indicate if the webhook should receive events | `bool` | `true` | no |
| <a name="input_github_base_url"></a> [github\_base\_url](#input\_github\_base\_url) | GitHub target API endpoint | `string` | n/a | yes |
| <a name="input_github_content_type"></a> [github\_content\_type](#input\_github\_content\_type) | The content type for the payload | `string` | n/a | yes |
| <a name="input_github_events"></a> [github\_events](#input\_github\_events) | Indicate if the webhook should receive events | `list(string)` | n/a | yes |
| <a name="input_github_insecure_ssl"></a> [github\_insecure\_ssl](#input\_github\_insecure\_ssl) | Insecure SSL boolean toggle | `bool` | `false` | no |
| <a name="input_github_name"></a> [github\_name](#input\_github\_name) | The type of the webhook | `string` | `null` | no |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | The repository of the webhook | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | ARN of the GitHub Secrets Manager containing the OAUTH or PAT | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codebuild_webhook"></a> [codebuild\_webhook](#output\_codebuild\_webhook) | Map of codebuild webhook |
| <a name="output_codebuild_webhook_id"></a> [codebuild\_webhook\_id](#output\_codebuild\_webhook\_id) | The name of the build project |
| <a name="output_codebuild_webhook_payload_url"></a> [codebuild\_webhook\_payload\_url](#output\_codebuild\_webhook\_payload\_url) | The CodeBuild endpoint where webhook events are sent |
| <a name="output_codebuild_webhook_secret"></a> [codebuild\_webhook\_secret](#output\_codebuild\_webhook\_secret) | The secret token of the associated repository. Not returned by the CodeBuild API for all source types |
| <a name="output_codebuild_webhook_url"></a> [codebuild\_webhook\_url](#output\_codebuild\_webhook\_url) | The URL to the webhook |
| <a name="output_repository_webhook"></a> [repository\_webhook](#output\_repository\_webhook) | Map of Repository webhook |
| <a name="output_repository_webhook_url"></a> [repository\_webhook\_url](#output\_repository\_webhook\_url) | URL of the webhook. This is a sensitive attribute because it may include basic auth credentials |

<!-- END_TF_DOCS -->