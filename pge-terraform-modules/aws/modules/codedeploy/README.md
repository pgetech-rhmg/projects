# AWS CodeDeploy Terraform module

 Terraform base module for deploying and managing CodeDeploy modules () on Amazon Web Services (AWS). 

 CodeDeploy Modules can be found at `codedeploy/modules/*`

 CodeDeploy Modules examples can be found at `codedeploy/examples/*`
<!-- BEGIN_TF_DOCS -->
# AWS CodeDeploy Application module
Terraform module which creates SAF2.0 CodeDeploy Application in AWS

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.94.1 |

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
| [aws_codedeploy_app.codedeploy_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_codedeploy_app_compute_platform"></a> [codedeploy\_app\_compute\_platform](#input\_codedeploy\_app\_compute\_platform) | The compute platform can either be ECS, Lambda, or Server | `string` | `"Server"` | no |
| <a name="input_codedeploy_app_name"></a> [codedeploy\_app\_name](#input\_codedeploy\_app\_name) | The name of the application. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codedeploy_app"></a> [codedeploy\_app](#output\_codedeploy\_app) | Map of codedeploy app. |
| <a name="output_codedeploy_app_application_id"></a> [codedeploy\_app\_application\_id](#output\_codedeploy\_app\_application\_id) | The application ID. |
| <a name="output_codedeploy_app_arn"></a> [codedeploy\_app\_arn](#output\_codedeploy\_app\_arn) | The ARN of the CodeDeploy application. |
| <a name="output_codedeploy_app_github_account_name"></a> [codedeploy\_app\_github\_account\_name](#output\_codedeploy\_app\_github\_account\_name) | The name for a connection to a GitHub account. |
| <a name="output_codedeploy_app_id"></a> [codedeploy\_app\_id](#output\_codedeploy\_app\_id) | Amazon's assigned ID for the application. |
| <a name="output_codedeploy_app_linked_to_github"></a> [codedeploy\_app\_linked\_to\_github](#output\_codedeploy\_app\_linked\_to\_github) | Whether the user has authenticated with GitHub for the specified application. |
| <a name="output_codedeploy_app_name"></a> [codedeploy\_app\_name](#output\_codedeploy\_app\_name) | The application's name. |
| <a name="output_codedeploy_app_tags_all"></a> [codedeploy\_app\_tags\_all](#output\_codedeploy\_app\_tags\_all) | A map of tags assigned to the resource. |

<!-- END_TF_DOCS -->