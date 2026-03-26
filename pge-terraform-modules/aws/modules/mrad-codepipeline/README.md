<!-- BEGIN_TF_DOCS -->
# PG&E MRAD CodePipeline Module

This Terraform module provisions MRAD-compatible, SAF-compliant CodePipeline instances.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_github"></a> [github](#provider\_github) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

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
| <a name="module_codebuild_build"></a> [codebuild\_build](#module\_codebuild\_build) | app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project | 0.0.10 |
| <a name="module_codebuild_build_iam_role"></a> [codebuild\_build\_iam\_role](#module\_codebuild\_build\_iam\_role) | app.terraform.io/pgetech/iam/aws//modules/iam_role | 0.0.8 |
| <a name="module_codebuild_codescan"></a> [codebuild\_codescan](#module\_codebuild\_codescan) | app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project | 0.0.10 |
| <a name="module_codebuild_codescan_iam_role"></a> [codebuild\_codescan\_iam\_role](#module\_codebuild\_codescan\_iam\_role) | app.terraform.io/pgetech/iam/aws//modules/iam_role | 0.0.8 |
| <a name="module_codebuild_deploy"></a> [codebuild\_deploy](#module\_codebuild\_deploy) | app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project | 0.0.10 |
| <a name="module_codebuild_deploy_iam_role"></a> [codebuild\_deploy\_iam\_role](#module\_codebuild\_deploy\_iam\_role) | app.terraform.io/pgetech/iam/aws//modules/iam_role | 0.0.8 |
| <a name="module_codebuild_tfc"></a> [codebuild\_tfc](#module\_codebuild\_tfc) | app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project | 0.0.10 |
| <a name="module_codebuild_tfc_iam_role"></a> [codebuild\_tfc\_iam\_role](#module\_codebuild\_tfc\_iam\_role) | app.terraform.io/pgetech/iam/aws//modules/iam_role | 0.0.8 |
| <a name="module_codebuild_wiz"></a> [codebuild\_wiz](#module\_codebuild\_wiz) | app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project | 0.0.10 |
| <a name="module_codepipeline_iam_role"></a> [codepipeline\_iam\_role](#module\_codepipeline\_iam\_role) | app.terraform.io/pgetech/iam/aws//modules/iam_role | 0.0.8 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.0.14 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.0.7 |
| <a name="module_wiz_scanning_iam_role"></a> [wiz\_scanning\_iam\_role](#module\_wiz\_scanning\_iam\_role) | app.terraform.io/pgetech/iam/aws//modules/iam_role | 0.0.8 |

## Resources

| Name | Type |
|------|------|
| [aws_codebuild_project.codebuild_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_source_credential.codebuild_source_credential](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) | resource |
| [aws_codebuild_webhook.webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_webhook) | resource |
| [aws_codepipeline.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_codepipeline_webhook.pipeline_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline_webhook) | resource |
| [github_repository_webhook.repo_webhook](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_webhook) | resource |
| [random_password.arbitrary_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.allow_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssm_parameter.sonar_scanner_cli_zip_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.private1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.private2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.private3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.mrad_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_TFC_CONFIGURATION_VERSION_GIT_BRANCH"></a> [TFC\_CONFIGURATION\_VERSION\_GIT\_BRANCH](#input\_TFC\_CONFIGURATION\_VERSION\_GIT\_BRANCH) | n/a | `string` | `null` | no |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number - predefined in TFC | `string` | n/a | yes |
| <a name="input_account_num_r53"></a> [account\_num\_r53](#input\_account\_num\_r53) | Target AWS account number, mandatory for r53 | `string` | n/a | yes |
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | The name of the AWS account or environment. Should be one of: `Dev`, `Test`, `QA`, `Prod` | `string` | n/a | yes |
| <a name="input_aws_r53_role"></a> [aws\_r53\_role](#input\_aws\_r53\_role) | AWS role to assume for r53 | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume. This parameter is **deprecated.** | `string` | n/a | yes |
| <a name="input_branch"></a> [branch](#input\_branch) | The name of the git branch this CodePipeline is configured to build. Usually you should set this to `var.TFC_CONFIGURATION_VERSION_GIT_BRANCH`. See: https://developer.hashicorp.com/terraform/cloud-docs/run/run-environment | `string` | n/a | yes |
| <a name="input_buildspec_build"></a> [buildspec\_build](#input\_buildspec\_build) | The CodeBuild buildspec inside the repo used to build the app code and run tests. | `string` | `"buildspecs/buildspec-build.yml"` | no |
| <a name="input_buildspec_ci"></a> [buildspec\_ci](#input\_buildspec\_ci) | The buildspec to use for CI builds. Defaults to the same value as `buildspec_build`. | `string` | `null` | no |
| <a name="input_buildspec_deploy"></a> [buildspec\_deploy](#input\_buildspec\_deploy) | The type of deployment this CodePipeline instance will be configured to perform in the final step. `LAMBDA` and `ECS` are built-in, while `REPO` allows the repo owner to configure this as a custom step by adding `buildspecs/buildspec-deploy.yml` to the host repo. | `string` | n/a | yes |
| <a name="input_buildspec_wiz"></a> [buildspec\_wiz](#input\_buildspec\_wiz) | Optional override for the Wiz buildspec, which builds, scans and pushes Docker images | `string` | `null` | no |
| <a name="input_ci_compute_type"></a> [ci\_compute\_type](#input\_ci\_compute\_type) | The AWS CodeBuild Lambda compute type to use for CI builds. Must be compatible with `ci_type`. See: https://docs.aws.amazon.com/codebuild/latest/APIReference/API_ProjectEnvironment.html | `string` | `"BUILD_LAMBDA_1GB"` | no |
| <a name="input_ci_enable"></a> [ci\_enable](#input\_ci\_enable) | If true, enable CI. CodeBuild will run on every commit and inside PRs. | `bool` | `true` | no |
| <a name="input_ci_image"></a> [ci\_image](#input\_ci\_image) | The AWS CodeBuild Lambda image to use for CI builds. Must be compatible with `ci_type`. See: https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html#lambda-compute-images | `string` | `"aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs20"` | no |
| <a name="input_ci_type"></a> [ci\_type](#input\_ci\_type) | The AWS CodeBuild Lambda type to use for CI builds. You probably want `LINUX_LAMBDA_CONTAINER` (preferred) or `LINUX_CONTAINER` (for fallback to ECS). See: https://docs.aws.amazon.com/codebuild/latest/APIReference/API_ProjectEnvironment.html | `string` | `"LINUX_LAMBDA_CONTAINER"` | no |
| <a name="input_codebuild_image"></a> [codebuild\_image](#input\_codebuild\_image) | Docker image used inside CodeBuild. This limits the tooling you can use inside your pipeline steps. Learn more: https://docs.aws.amazon.com/codebuild/latest/userguide/available-runtimes.html | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:5.0"` | no |
| <a name="input_docker_node_base_image"></a> [docker\_node\_base\_image](#input\_docker\_node\_base\_image) | The base name for the current MRAD Docker node base image, i.e. `development` -> `990878119577.dkr.ecr.us-west-2.amazonaws.com/docker-node-baseimage-ecs-development:latest` | `string` | `"docker-node-baseimage-ecs"` | no |
| <a name="input_docker_node_base_image_tag"></a> [docker\_node\_base\_image\_tag](#input\_docker\_node\_base\_image\_tag) | The tag for the current MRAD Docker node base image, i.e. `latest` -> `990878119577.dkr.ecr.us-west-2.amazonaws.com/docker-node-baseimage-ecs-development:latest` | `string` | `"latest"` | no |
| <a name="input_ecr_repo_urls"></a> [ecr\_repo\_urls](#input\_ecr\_repo\_urls) | The ECR repos where we will push the container images after we build them | `map(any)` | `null` | no |
| <a name="input_enable_tfc_check"></a> [enable\_tfc\_check](#input\_enable\_tfc\_check) | If true, insert a step that waits for any TFC runs associated with this commit to complete before proceeding. If false, omit this step. If unset, this check will only be added to pipelines for dev/QA/prod environments. | `bool` | `null` | no |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | The GitHub organization that owns the repository. | `string` | `"PGEDigitalCatalyst"` | no |
| <a name="input_github_secret"></a> [github\_secret](#input\_github\_secret) | The name of the AWS Secrets Manager secret containing the GitHub Personal Access Token | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The ARN of the KMS key to use for encryption. Required if data classification is not Internal or Public. | `string` | `null` | no |
| <a name="input_partner"></a> [partner](#input\_partner) | The name of the partner team that owns this pipeline. | `string` | `"MRAD"` | no |
| <a name="input_poll_for_source_changes"></a> [poll\_for\_source\_changes](#input\_poll\_for\_source\_changes) | When true, AWS uses polling to discover changes to the source repository. See: https://docs.aws.amazon.com/codepipeline/latest/userguide/update-change-detection.html | `bool` | `false` | no |
| <a name="input_privileged_deploy_stage"></a> [privileged\_deploy\_stage](#input\_privileged\_deploy\_stage) | If true, use privileged mode for the deploy stage. Required when building a Docker image. | `bool` | `false` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the project. | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | The name of the GitHub repository inside the PGEDigitalCatalyst organization. If unset, defaults to `project_name`. | `string` | `""` | no |
| <a name="input_sonar_host"></a> [sonar\_host](#input\_sonar\_host) | The SonarQube host to which we submit code for analysis. | `string` | `"https://sonarqube.io.pge.com"` | no |
| <a name="input_sonar_project_key_prefix"></a> [sonar\_project\_key\_prefix](#input\_sonar\_project\_key\_prefix) | The project key used to prefix our SonarQube reports. | `string` | `"mrad"` | no |
| <a name="input_sonar_scanner_cli_zip_url"></a> [sonar\_scanner\_cli\_zip\_url](#input\_sonar\_scanner\_cli\_zip\_url) | The URL for the `sonar-scanner-cli` zip for Linux hosted on `binaries.sonarsource.com`. If unset, fetch this URL from AWSSM Parameter Store. Example value: `https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip` | `string` | `""` | no |
| <a name="input_sonarqube_secret_name"></a> [sonarqube\_secret\_name](#input\_sonarqube\_secret\_name) | The ID of the AWS Secrets Manager entry that contains the SonarQube token. | `string` | `"sonarqube-mrad"` | no |
| <a name="input_subnet1"></a> [subnet1](#input\_subnet1) | The name of the first subnet to use for each CodeBuild step. | `string` | `""` | no |
| <a name="input_subnet2"></a> [subnet2](#input\_subnet2) | The name of the second subnet to use for each CodeBuild step. | `string` | `""` | no |
| <a name="input_subnet3"></a> [subnet3](#input\_subnet3) | The name of the third subnet to use for each CodeBuild step. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to these resources which indicates their provenance. | `map(string)` | `{}` | no |
| <a name="input_tfc_token_secret_name"></a> [tfc\_token\_secret\_name](#input\_tfc\_token\_secret\_name) | The name of the AWS Secrets Manager secret containing the Terraform Cloud API token. | `string` | `"mrad-tfc-token"` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | If `partner` is not MRAD, the name of the VPC to use for each CodeBuild step. | `string` | `""` | no | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->
