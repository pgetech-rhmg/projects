<!-- BEGIN_TF_DOCS -->
# AWS codepipeline lambda module for .NET
Terraform module which creates SAF2.0 codepipeline in AWS

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
| <a name="provider_external"></a> [external](#provider\_external) | n/a |

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
| <a name="module_codebuild_codepublish"></a> [codebuild\_codepublish](#module\_codebuild\_codepublish) | app.terraform.io/pgetech/codebuild/aws | 0.1.4 |
| <a name="module_codebuild_codescan"></a> [codebuild\_codescan](#module\_codebuild\_codescan) | app.terraform.io/pgetech/codebuild/aws | 0.1.4 |
| <a name="module_codebuild_iam_role"></a> [codebuild\_iam\_role](#module\_codebuild\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.0 |
| <a name="module_codebuild_project"></a> [codebuild\_project](#module\_codebuild\_project) | app.terraform.io/pgetech/codebuild/aws | 0.1.4 |
| <a name="module_codepublish_iam_role"></a> [codepublish\_iam\_role](#module\_codepublish\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.0 |
| <a name="module_codescan_iam_role"></a> [codescan\_iam\_role](#module\_codescan\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.0 |
| <a name="module_security-group"></a> [security-group](#module\_security-group) | app.terraform.io/pgetech/security-group/aws | 0.1.1 |
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.0 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_codepipeline.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.github_token_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifact_bucket_owner_access"></a> [artifact\_bucket\_owner\_access](#input\_artifact\_bucket\_owner\_access) | Enter the artifact bucket owner access | `string` | n/a | yes |
| <a name="input_artifact_location"></a> [artifact\_location](#input\_artifact\_location) | Enter the bucket name used for artifact storage | `string` | n/a | yes |
| <a name="input_artifact_path"></a> [artifact\_path](#input\_artifact\_path) | Enter the path to store artifact - S3 | `string` | n/a | yes |
| <a name="input_artifact_store_location_bucket"></a> [artifact\_store\_location\_bucket](#input\_artifact\_store\_location\_bucket) | The location where AWS CodePipeline stores artifacts for a pipeline; currently only S3 is supported. | `string` | n/a | yes |
| <a name="input_artifact_store_region"></a> [artifact\_store\_region](#input\_artifact\_store\_region) | The region where the artifact store is located. Required for a cross-region CodePipeline, do not provide for a single-region CodePipeline. | `string` | `null` | no |
| <a name="input_artifactory_host"></a> [artifactory\_host](#input\_artifactory\_host) | Enter the name of jfrog artifactory host - environment variable used in buildspec yml | `string` | n/a | yes |
| <a name="input_artifactory_repo_name"></a> [artifactory\_repo\_name](#input\_artifactory\_repo\_name) | Enter the artifact repo name of jfrog - environment variable used in buildspec yml | `string` | n/a | yes |
| <a name="input_branch"></a> [branch](#input\_branch) | Branch of the GitHub repository, e.g 'master | `string` | n/a | yes |
| <a name="input_cache_location_codebuild"></a> [cache\_location\_codebuild](#input\_cache\_location\_codebuild) | Location where the AWS CodeBuild project stores cached resources | `string` | `null` | no |
| <a name="input_cache_location_codepublish"></a> [cache\_location\_codepublish](#input\_cache\_location\_codepublish) | Location where the AWS CodeBuild project stores cached resources | `string` | `null` | no |
| <a name="input_cache_location_codescan"></a> [cache\_location\_codescan](#input\_cache\_location\_codescan) | Location where the AWS CodeBuild project stores cached resources | `string` | `null` | no |
| <a name="input_cache_modes_codebuild"></a> [cache\_modes\_codebuild](#input\_cache\_modes\_codebuild) | Specifies settings that AWS CodeBuild uses to store and reuse build dependencies | `string` | `"LOCAL_SOURCE_CACHE"` | no |
| <a name="input_cache_modes_codepublish"></a> [cache\_modes\_codepublish](#input\_cache\_modes\_codepublish) | Specifies settings that AWS CodeBuild uses to store and reuse build dependencies | `string` | `"LOCAL_SOURCE_CACHE"` | no |
| <a name="input_cache_modes_codescan"></a> [cache\_modes\_codescan](#input\_cache\_modes\_codescan) | Specifies settings that AWS CodeBuild uses to store and reuse build dependencies | `string` | `"LOCAL_SOURCE_CACHE"` | no |
| <a name="input_cache_type_codebuild"></a> [cache\_type\_codebuild](#input\_cache\_type\_codebuild) | Type of storage that will be used for the AWS CodeBuild project cache | `string` | `"NO_CACHE"` | no |
| <a name="input_cache_type_codepublish"></a> [cache\_type\_codepublish](#input\_cache\_type\_codepublish) | Type of storage that will be used for the AWS CodeBuild project cache | `string` | `"NO_CACHE"` | no |
| <a name="input_cache_type_codescan"></a> [cache\_type\_codescan](#input\_cache\_type\_codescan) | Type of storage that will be used for the AWS CodeBuild project cache | `string` | `"NO_CACHE"` | no |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | variables for security\_group\_project | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_codebuild_role_service"></a> [codebuild\_role\_service](#input\_codebuild\_role\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_codebuild_sc_token"></a> [codebuild\_sc\_token](#input\_codebuild\_sc\_token) | For GitHub or GitHub Enterprise, this is the personal access token. | `string` | n/a | yes |
| <a name="input_codepipeline_name"></a> [codepipeline\_name](#input\_codepipeline\_name) | The name of the pipeline. | `string` | n/a | yes |
| <a name="input_compute_type_codebuild"></a> [compute\_type\_codebuild](#input\_compute\_type\_codebuild) | Information about the compute resources the build project will use in codebuild project | `string` | n/a | yes |
| <a name="input_compute_type_codepublish"></a> [compute\_type\_codepublish](#input\_compute\_type\_codepublish) | Information about the compute resources the build project will use in codepublish project | `string` | n/a | yes |
| <a name="input_compute_type_codescan"></a> [compute\_type\_codescan](#input\_compute\_type\_codescan) | Information about the compute resources the build project will use in codescan project | `string` | n/a | yes |
| <a name="input_concurrent_build_limit_codebuild"></a> [concurrent\_build\_limit\_codebuild](#input\_concurrent\_build\_limit\_codebuild) | Maximum number of concurrent builds for the project in codebuild project | `number` | n/a | yes |
| <a name="input_concurrent_build_limit_codepublish"></a> [concurrent\_build\_limit\_codepublish](#input\_concurrent\_build\_limit\_codepublish) | Maximum number of concurrent builds for the codepublish project | `number` | n/a | yes |
| <a name="input_concurrent_build_limit_codescan"></a> [concurrent\_build\_limit\_codescan](#input\_concurrent\_build\_limit\_codescan) | Maximum number of concurrent builds for the codescan project | `number` | n/a | yes |
| <a name="input_custom_codebuild_policy_file"></a> [custom\_codebuild\_policy\_file](#input\_custom\_codebuild\_policy\_file) | add custom codebuild policy file for codebuild project, if needed | `string` | `null` | no |
| <a name="input_custom_codepublish_policy_file"></a> [custom\_codepublish\_policy\_file](#input\_custom\_codepublish\_policy\_file) | add custom codepublish policy file for codebuild project, if needed | `string` | `null` | no |
| <a name="input_custom_codescan_policy_file"></a> [custom\_codescan\_policy\_file](#input\_custom\_codescan\_policy\_file) | add custom codescan policy file for codebuild project, if needed | `string` | `null` | no |
| <a name="input_dependency_files_location"></a> [dependency\_files\_location](#input\_dependency\_files\_location) | Enter the dependency file location - environment variable used in buildspec yml | `string` | `""` | no |
| <a name="input_dotnet_project_metadata_file"></a> [dotnet\_project\_metadata\_file](#input\_dotnet\_project\_metadata\_file) | Name of the file that includes dotnet project's metadata and dependencies | `string` | `"appsettings.json"` | no |
| <a name="input_dotnet_runtime"></a> [dotnet\_runtime](#input\_dotnet\_runtime) | Enter the dotnet version to compile application code - variable in buildspec yml | `string` | n/a | yes |
| <a name="input_encryption_key_id"></a> [encryption\_key\_id](#input\_encryption\_key\_id) | The KMS key ARN or ID for artifact store | `string` | `null` | no |
| <a name="input_environment_image_codebuild"></a> [environment\_image\_codebuild](#input\_environment\_image\_codebuild) | Docker image to use for codebuild project. Valid values include Docker images provided by codebuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | n/a | yes |
| <a name="input_environment_image_codepublish"></a> [environment\_image\_codepublish](#input\_environment\_image\_codepublish) | Docker image to use for this codepublish project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | n/a | yes |
| <a name="input_environment_image_codescan"></a> [environment\_image\_codescan](#input\_environment\_image\_codescan) | Docker image to use for this codescan project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | n/a | yes |
| <a name="input_environment_type_codebuild"></a> [environment\_type\_codebuild](#input\_environment\_type\_codebuild) | Type of build environment to use for codebuild project related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | n/a | yes |
| <a name="input_environment_type_codepublish"></a> [environment\_type\_codepublish](#input\_environment\_type\_codepublish) | Type of build environment to use for codepublish project related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | n/a | yes |
| <a name="input_environment_type_codescan"></a> [environment\_type\_codescan](#input\_environment\_type\_codescan) | Type of build environment to use for codescan related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | n/a | yes |
| <a name="input_environment_variables_codebuild_stage"></a> [environment\_variables\_codebuild\_stage](#input\_environment\_variables\_codebuild\_stage) | Provide the list of environment variables required for codebuild stage | `list(any)` | `[]` | no |
| <a name="input_environment_variables_codepublish_stage"></a> [environment\_variables\_codepublish\_stage](#input\_environment\_variables\_codepublish\_stage) | Provide the list of environment variables required for codepublish stage | `list(any)` | `[]` | no |
| <a name="input_environment_variables_codescan_stage"></a> [environment\_variables\_codescan\_stage](#input\_environment\_variables\_codescan\_stage) | Provide the list of environment variables required for codescan stage | `list(any)` | `[]` | no |
| <a name="input_exclude_files"></a> [exclude\_files](#input\_exclude\_files) | space separated files/folders that should not be added to the Lambda function | `string` | `""` | no |
| <a name="input_github_branch"></a> [github\_branch](#input\_github\_branch) | Enter the value of github repo branch - environment variable used in buildspec yml | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | Github organization name of the repository, pgetech, DigitalCatalyst, etc | `string` | n/a | yes |
| <a name="input_github_repo_url"></a> [github\_repo\_url](#input\_github\_repo\_url) | Enter the github repo url - environment variable used in buildspec yml | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Enter the KMS key arn for encryption - codebuild | `string` | `null` | no |
| <a name="input_lambda_alias_name"></a> [lambda\_alias\_name](#input\_lambda\_alias\_name) | Enter the name of the Lambda alias | `string` | n/a | yes |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | Enter the name of the Lambda Function | `string` | n/a | yes |
| <a name="input_lambda_update"></a> [lambda\_update](#input\_lambda\_update) | Input from the user to update lambda function with zip created or not | `bool` | `true` | no |
| <a name="input_pollchanges"></a> [pollchanges](#input\_pollchanges) | Periodically check the location of your source content and run the pipeline if changes are detected, this uses Codepipeline Polling. default to false to use webhook | `string` | `"false"` | no |
| <a name="input_project_key"></a> [project\_key](#input\_project\_key) | A unique identifier of your project inside SonarQube | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The display name visible in SonarQube dashboard. Example: My Project | `string` | n/a | yes |
| <a name="input_project_root_directory"></a> [project\_root\_directory](#input\_project\_root\_directory) | Enter the project root directory value | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region of pipeline stages | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Github repository name of the application to be built | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | A service role Amazon Resource Name (ARN) that grants AWS CodePipeline permission to make calls to AWS services on your behalf. | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_token"></a> [secretsmanager\_artifactory\_token](#input\_secretsmanager\_artifactory\_token) | Enter the token value of jfrog artifactory stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_user"></a> [secretsmanager\_artifactory\_user](#input\_secretsmanager\_artifactory\_user) | Enter the name of jfrog artifactory user stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_github_token_secret_name"></a> [secretsmanager\_github\_token\_secret\_name](#input\_secretsmanager\_github\_token\_secret\_name) | secret manager path of the github OAUTH or PAT | `string` | n/a | yes |
| <a name="input_secretsmanager_sonar_token"></a> [secretsmanager\_sonar\_token](#input\_secretsmanager\_sonar\_token) | Enter the token of SonarQube stored in secrets manager | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | vpc id for security group | `string` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | name of the security group | `string` | n/a | yes |
| <a name="input_sonar_host"></a> [sonar\_host](#input\_sonar\_host) | Enter the host value of SonarQube | `string` | n/a | yes |
| <a name="input_source_buildspec_codebuild"></a> [source\_buildspec\_codebuild](#input\_source\_buildspec\_codebuild) | Enter the buildspec file of build stage codebuild project | `string` | n/a | yes |
| <a name="input_source_location_codebuild"></a> [source\_location\_codebuild](#input\_source\_location\_codebuild) | Location of the source code from git or s3 to build codescan project. | `string` | `null` | no |
| <a name="input_stages"></a> [stages](#input\_stages) | Further stages after publisg stage can be added in dynamic block. Dynamic stage is also optional when no values is provided in tfvars | `list(any)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs within which to run builds. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_unit_test_commands"></a> [unit\_test\_commands](#input\_unit\_test\_commands) | Enter the unit test commands for dotnet webapp | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | enter the vpc id within which to run builds. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codepipeline_all"></a> [codepipeline\_all](#output\_codepipeline\_all) | Map of Codepipeline object |
| <a name="output_codepipeline_arn"></a> [codepipeline\_arn](#output\_codepipeline\_arn) | The codepipeline ARN |
| <a name="output_codepipeline_id"></a> [codepipeline\_id](#output\_codepipeline\_id) | The codepipeline ID |

<!-- END_TF_DOCS -->
