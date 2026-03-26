<!-- BEGIN_TF_DOCS -->
# AWS module that creates a codepipeline, ecr, and lambda function for Locate & Mark
Terraform module which creates SAF2.0 Lambda function in AWS

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.94.0 |

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
| <a name="module_codebuild_build"></a> [codebuild\_build](#module\_codebuild\_build) | app.terraform.io/pgetech/codebuild/aws | 0.1.11 |
| <a name="module_codebuild_build_iam_role"></a> [codebuild\_build\_iam\_role](#module\_codebuild\_build\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_codebuild_deploy"></a> [codebuild\_deploy](#module\_codebuild\_deploy) | app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project | 0.0.10 |
| <a name="module_codebuild_sonar"></a> [codebuild\_sonar](#module\_codebuild\_sonar) | app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project | 0.0.10 |
| <a name="module_codepipeline_iam_role"></a> [codepipeline\_iam\_role](#module\_codepipeline\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | app.terraform.io/pgetech/ecr/aws | 0.1.3 |
| <a name="module_lambda_function_image"></a> [lambda\_function\_image](#module\_lambda\_function\_image) | ../lm-lambda | n/a |
| <a name="module_lambda_role"></a> [lambda\_role](#module\_lambda\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_lambda_security_group"></a> [lambda\_security\_group](#module\_lambda\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/lm-tags/aws | ~> 0.1.5 |

## Resources

| Name | Type |
|------|------|
| [aws_codepipeline.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecr_image.placeholder_image](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_image) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssm_parameter.archive_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_codebuild_image"></a> [codebuild\_image](#input\_codebuild\_image) | Image used inside CodeBuild. This limits the tooling you can use inside your pipeline steps. Learn more: https://docs.aws.amazon.com/codebuild/latest/userguide/available-runtimes.html | `string` | `"aws/codebuild/standard:7.0"` | no |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | The GitHub organization that owns the repository. | `string` | `"PGEDigitalCatalyst"` | no |
| <a name="input_github_secret"></a> [github\_secret](#input\_github\_secret) | Github secret name | `string` | `"system/github"` | no |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | Name of the lambda function | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | The name of the repository that Terraform is deploying to AWS | `string` | n/a | yes |
| <a name="input_runtime_version"></a> [runtime\_version](#input\_runtime\_version) | Node.js runtime version | `string` | `"22"` | no |
| <a name="input_sonar_cli_download_url"></a> [sonar\_cli\_download\_url](#input\_sonar\_cli\_download\_url) | SonarQube CLI download URL | `string` | `"https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip"` | no |
| <a name="input_sonar_token"></a> [sonar\_token](#input\_sonar\_token) | SonarQube token secret name | `string` | `"lm/sonarqube"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | The name of the SSM Parameters that comtain the subnet ids to use for each CodeBuild step. | `list(string)` | <pre>[<br/>  "/vpc/privatesubnet1/id",<br/>  "/vpc/privatesubnet2/id",<br/>  "/vpc/privatesubnet3/id"<br/>]</pre> | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | The name of the SSM Parameter that has the VPC id to use for each CodeBuild step. | `string` | `"/vpc/id"` | no |
| <a name="input_wiz_secret"></a> [wiz\_secret](#input\_wiz\_secret) | WIZ cli secret name | `string` | `"shared-wiz-access"` | no | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->
