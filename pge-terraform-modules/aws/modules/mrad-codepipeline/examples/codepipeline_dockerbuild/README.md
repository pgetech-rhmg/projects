<!-- BEGIN_TF_DOCS -->
# MRAD Example CodePipline
Terraform module which creates SAF2.0 ECS with EC2 in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.64.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.2 |

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
| <a name="module_mrad-common"></a> [mrad-common](#module\_mrad-common) | app.terraform.io/pgetech/mrad-common/aws | ~> 1.0 |
| <a name="module_pipeline"></a> [pipeline](#module\_pipeline) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [random_id.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_secretsmanager_secret.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_TFC_CONFIGURATION_VERSION_GIT_BRANCH"></a> [TFC\_CONFIGURATION\_VERSION\_GIT\_BRANCH](#input\_TFC\_CONFIGURATION\_VERSION\_GIT\_BRANCH) | n/a | `string` | `"development"` | no |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_account_num_r53"></a> [account\_num\_r53](#input\_account\_num\_r53) | Target AWS account number, mandatory for r53 | `string` | n/a | yes |
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | The aws account/environment (Dev/Test/QA/Prod) | `string` | n/a | yes |
| <a name="input_aws_r53_role"></a> [aws\_r53\_role](#input\_aws\_r53\_role) | AWS role to assume for r53 | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_codebuild_image"></a> [codebuild\_image](#input\_codebuild\_image) | Docker image used inside CodeBuild. This limits the tooling you can use inside your pipeline steps. Learn more: https://docs.aws.amazon.com/codebuild/latest/userguide/available-runtimes.html | `string` | n/a | yes |
| <a name="input_github_secret"></a> [github\_secret](#input\_github\_secret) | The name of the AWS Secrets Manager secret containing the GitHub Personal Access Token | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the project | `string` | n/a | yes | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->