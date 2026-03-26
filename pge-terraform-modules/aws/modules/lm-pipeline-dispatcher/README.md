

<!-- BEGIN_TF_DOCS -->
# AWS module that creates a dispatcher to trigger codepipeline based on files changed
Terraform module which creates a SAF2.0 Codebuild Dispacther in AWS

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

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
| <a name="module_codebuild_build_iam_role"></a> [codebuild\_build\_iam\_role](#module\_codebuild\_build\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_security_group_project"></a> [security\_group\_project](#module\_security\_group\_project) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/lm-tags/aws | 0.1.5 |

## Resources

| Name | Type |
|------|------|
| [aws_codebuild_project.dispatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_source_credential.codebuild_source_credential](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) | resource |
| [aws_codebuild_webhook.webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_webhook) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_secretsmanager_secret.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssm_parameter.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compute_type"></a> [compute\_type](#input\_compute\_type) | The AWS CodeBuild Lambda compute type to use for CI builds. See: https://docs.aws.amazon.com/codebuild/latest/APIReference/API_ProjectEnvironment.html | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | The GitHub organization that owns the repository. | `string` | `"PGEDigitalCatalyst"` | no |
| <a name="input_github_secret"></a> [github\_secret](#input\_github\_secret) | Github secret name | `string` | `"system/github"` | no |
| <a name="input_image"></a> [image](#input\_image) | The AWS CodeBuild Lambda image to use for CI builds. See: https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html#lambda-compute-images | `string` | `"aws/codebuild/standard:7.0"` | no |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | The name of the GitHub repo to use for this pipeline. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | The name of the SSM Parameters that comtain the subnet ids to use for each CodeBuild step. | `list(string)` | <pre>[<br/>  "/vpc/privatesubnet1/id",<br/>  "/vpc/privatesubnet2/id",<br/>  "/vpc/privatesubnet3/id"<br/>]</pre> | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | The name of the SSM Parameter that has the VPC id to use for each CodeBuild step. | `string` | `"/vpc/id"` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codebuild_arn"></a> [codebuild\_arn](#output\_codebuild\_arn) | Codebuild ARN |
| <a name="output_codebuild_iam_role"></a> [codebuild\_iam\_role](#output\_codebuild\_iam\_role) | Codebuild IAM Role |

<!-- END_TF_DOCS -->
