<!-- BEGIN_TF_DOCS -->
# AWS codepipeline webhook module which creates codepipeline webhook and wires into GitHub repository, make sure to add Github provider with token and owner.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_github"></a> [github](#provider\_github) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.0 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_codepipeline_webhook.codepipeline_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline_webhook) | resource |
| [github_repository_webhook.github_webhook](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_webhook) | resource |
| [random_password.webhook_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_codepipeline_name"></a> [codepipeline\_name](#input\_codepipeline\_name) | The name of the pipeline. | `string` | n/a | yes |
| <a name="input_github_webhook_content_type"></a> [github\_webhook\_content\_type](#input\_github\_webhook\_content\_type) | The content type for the payload | `string` | `"json"` | no |
| <a name="input_github_webhook_events"></a> [github\_webhook\_events](#input\_github\_webhook\_events) | Indicate Which events would you like to trigger this webhook | `list(string)` | <pre>[<br>  "push"<br>]</pre> | no |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Github repository to be integrated with webhook | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codepipeline_webhook"></a> [codepipeline\_webhook](#output\_codepipeline\_webhook) | Map of codebuild webhook |
| <a name="output_codepipeline_webhook_id"></a> [codepipeline\_webhook\_id](#output\_codepipeline\_webhook\_id) | codepipeline webhook id |
| <a name="output_codepipeline_webhook_url"></a> [codepipeline\_webhook\_url](#output\_codepipeline\_webhook\_url) | The URL to the webhook |
| <a name="output_github_webhook"></a> [github\_webhook](#output\_github\_webhook) | Map of Repository webhook |
| <a name="output_github_webhook_url"></a> [github\_webhook\_url](#output\_github\_webhook\_url) | URL of the webhook. This is a sensitive attribute because it may include basic auth credentials |

<!-- END_TF_DOCS -->