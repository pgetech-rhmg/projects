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

# AWS Codebuild module creating Codebuild project
Terraform module which creates SAF2.0 Codebuild in AWS.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.27.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.5 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.6.1 |

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
| [aws_codebuild_project.codebuild_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_resource_policy.codebuild_resource_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_resource_policy) | resource |
| [aws_secretsmanager_secret.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [local_file.codepublish_buildspec_dotnet](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.codepublish_buildspec_dotnet_windows](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.codepublish_buildspec_java](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.codepublish_buildspec_java_lambda_container](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.codepublish_buildspec_nodejs](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.codepublish_buildspec_python](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.codescan_buildspec_dotnet](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.codescan_buildspec_dotnet_windows](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.codescan_buildspec_java](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.codescan_buildspec_java_lambda_container](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.codescan_buildspec_nodejs](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.codescan_buildspec_python](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.getartifact_buildspec_dotnet](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.getartifact_buildspec_java](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.getartifact_buildspec_nodejs](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.secretscan_buildspec_container](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.wizscan_buildspec_container_java](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.wizscan_buildspec_container_nodejs](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.wizscan_buildspec_container_python](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifact_bucket_owner_access"></a> [artifact\_bucket\_owner\_access](#input\_artifact\_bucket\_owner\_access) | Specifies the bucket owner's access for objects that another account uploads to their Amazon S3 bucket | `string` | `null` | no |
| <a name="input_artifact_identifier"></a> [artifact\_identifier](#input\_artifact\_identifier) | Artifact identifier | `string` | `null` | no |
| <a name="input_artifact_location"></a> [artifact\_location](#input\_artifact\_location) | Build output artifact location | `string` | `null` | no |
| <a name="input_artifact_name"></a> [artifact\_name](#input\_artifact\_name) | Name of the project | `string` | `null` | no |
| <a name="input_artifact_namespace_type"></a> [artifact\_namespace\_type](#input\_artifact\_namespace\_type) | Namespace to use in storing build artifacts | `string` | `null` | no |
| <a name="input_artifact_override_name"></a> [artifact\_override\_name](#input\_artifact\_override\_name) | Whether a name specified in the build specification overrides the artifact name | `string` | `null` | no |
| <a name="input_artifact_packaging"></a> [artifact\_packaging](#input\_artifact\_packaging) | Type of build output artifact to create.If type is set to S3, valid values are NONE, ZIP. | `string` | `null` | no |
| <a name="input_artifact_path"></a> [artifact\_path](#input\_artifact\_path) | If type is set to S3, this is the path to the output artifact | `string` | `null` | no |
| <a name="input_artifact_type"></a> [artifact\_type](#input\_artifact\_type) | Build output artifact's type | `string` | n/a | yes |
| <a name="input_badge_enabled"></a> [badge\_enabled](#input\_badge\_enabled) | Generates a publicly-accessible URL for the projects build badge | `bool` | `false` | no |
| <a name="input_build_batch_artifacts"></a> [build\_batch\_artifacts](#input\_build\_batch\_artifacts) | Specifies if the build artifacts for the batch build should be combined into a single artifact location | `string` | `null` | no |
| <a name="input_build_batch_service_role"></a> [build\_batch\_service\_role](#input\_build\_batch\_service\_role) | Specifies the service role ARN for the batch build project | `string` | `null` | no |
| <a name="input_build_batch_timeout"></a> [build\_batch\_timeout](#input\_build\_batch\_timeout) | Specifies the maximum amount of time, in minutes, that the batch build must be completed in | `number` | `null` | no |
| <a name="input_build_status_config"></a> [build\_status\_config](#input\_build\_status\_config) | Configuration block for build\_status\_config | `any` | `[]` | no |
| <a name="input_cache_location"></a> [cache\_location](#input\_cache\_location) | Location where the AWS CodeBuild project stores cached resources | `string` | `null` | no |
| <a name="input_cache_modes"></a> [cache\_modes](#input\_cache\_modes) | Specifies settings that AWS CodeBuild uses to store and reuse build dependencies | `string` | `"LOCAL_SOURCE_CACHE"` | no |
| <a name="input_cache_type"></a> [cache\_type](#input\_cache\_type) | Type of storage that will be used for the AWS CodeBuild project cache | `string` | `"NO_CACHE"` | no |
| <a name="input_cloudwatch_logs_group_name"></a> [cloudwatch\_logs\_group\_name](#input\_cloudwatch\_logs\_group\_name) | Name of the S3 bucket and the path prefix for S3 logs | `string` | `null` | no |
| <a name="input_cloudwatch_logs_stream_name"></a> [cloudwatch\_logs\_stream\_name](#input\_cloudwatch\_logs\_stream\_name) | Name of the S3 bucket and the path prefix for S3 logs | `string` | `null` | no |
| <a name="input_codebuild_project_build_timeout"></a> [codebuild\_project\_build\_timeout](#input\_codebuild\_project\_build\_timeout) | Number of minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed | `number` | `60` | no |
| <a name="input_codebuild_project_description"></a> [codebuild\_project\_description](#input\_codebuild\_project\_description) | Short description of the project | `string` | `null` | no |
| <a name="input_codebuild_project_name"></a> [codebuild\_project\_name](#input\_codebuild\_project\_name) | The name of Project | `string` | n/a | yes |
| <a name="input_codebuild_project_role"></a> [codebuild\_project\_role](#input\_codebuild\_project\_role) | IAM role that enables AWS CodeBuild to interact with dependent AWS services | `string` | n/a | yes |
| <a name="input_codebuild_resource_policy"></a> [codebuild\_resource\_policy](#input\_codebuild\_resource\_policy) | Policy file | `string` | `"{}"` | no |
| <a name="input_codebuild_sc_token"></a> [codebuild\_sc\_token](#input\_codebuild\_sc\_token) | ARN of the GitHub Secrets Manager containing the OAUTH or PAT | `string` | n/a | yes |
| <a name="input_compute_type"></a> [compute\_type](#input\_compute\_type) | Information about the compute resources the build project will use | `string` | n/a | yes |
| <a name="input_compute_types_allowed"></a> [compute\_types\_allowed](#input\_compute\_types\_allowed) | An array of strings that specify the compute types that are allowed for the batch build | `list(string)` | `[]` | no |
| <a name="input_concurrent_build_limit"></a> [concurrent\_build\_limit](#input\_concurrent\_build\_limit) | Maximum number of concurrent builds for the project | `number` | n/a | yes |
| <a name="input_encryption_key"></a> [encryption\_key](#input\_encryption\_key) | KMS used for encrypting the build project's build output artifacts | `string` | `null` | no |
| <a name="input_environment_certificate"></a> [environment\_certificate](#input\_environment\_certificate) | ARN of the S3 bucket | `string` | `null` | no |
| <a name="input_environment_credential"></a> [environment\_credential](#input\_environment\_credential) | ARN or name of credentials created using AWS Secrets Manager | `string` | `null` | no |
| <a name="input_environment_image"></a> [environment\_image](#input\_environment\_image) | Docker image to use for this build project | `string` | n/a | yes |
| <a name="input_environment_privileged_mode"></a> [environment\_privileged\_mode](#input\_environment\_privileged\_mode) | Whether to enable running the Docker daemon inside a Docker container | `bool` | `false` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | Type of build environment to use for related builds | `string` | n/a | yes |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | List of nested attributes | `list(any)` | `[]` | no |
| <a name="input_file_system_locations"></a> [file\_system\_locations](#input\_file\_system\_locations) | A set of file system locations to to mount inside the build | `map(string)` | `{}` | no |
| <a name="input_image_pull_credentials_type"></a> [image\_pull\_credentials\_type](#input\_image\_pull\_credentials\_type) | Type of credentials AWS CodeBuild uses to pull images in your build | `string` | `null` | no |
| <a name="input_maximum_builds_allowed"></a> [maximum\_builds\_allowed](#input\_maximum\_builds\_allowed) | Specifies the maximum number of builds allowed | `number` | `null` | no |
| <a name="input_project_visibility"></a> [project\_visibility](#input\_project\_visibility) | Specifies the visibility of the project's builds | `string` | `"PRIVATE"` | no |
| <a name="input_queued_timeout"></a> [queued\_timeout](#input\_queued\_timeout) | Number of minutes, from 5 to 480 (8 hours), a build is allowed to be queued before it times out | `number` | `480` | no |
| <a name="input_resource_access_role"></a> [resource\_access\_role](#input\_resource\_access\_role) | The ARN of the IAM role that enables CodeBuild to access the CloudWatch Logs and Amazon S3 artifacts | `string` | `null` | no |
| <a name="input_s3_bucket_owner_access"></a> [s3\_bucket\_owner\_access](#input\_s3\_bucket\_owner\_access) | Specifies the bucket owner's access for objects that another account uploads to their Amazon S3 bucket | `string` | `"NONE"` | no |
| <a name="input_s3_location"></a> [s3\_location](#input\_s3\_location) | Name of the S3 bucket and the path prefix for S3 logs | `string` | `null` | no |
| <a name="input_s3_logs_status"></a> [s3\_logs\_status](#input\_s3\_logs\_status) | Current status of logs in S3 for a build project | `string` | `"DISABLED"` | no |
| <a name="input_secondary_artifacts"></a> [secondary\_artifacts](#input\_secondary\_artifacts) | Configuration block for secondary artifacts | `any` | `[]` | no |
| <a name="input_secondary_source_version"></a> [secondary\_source\_version](#input\_secondary\_source\_version) | Configuration block for secondary source version | `any` | `[]` | no |
| <a name="input_secondary_sources"></a> [secondary\_sources](#input\_secondary\_sources) | Configuration block for secondary sources | `any` | `[]` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security group IDs to assign to running builds | `list(string)` | n/a | yes |
| <a name="input_source_buildspec"></a> [source\_buildspec](#input\_source\_buildspec) | Build specification to use for this build project's related builds | `string` | `null` | no |
| <a name="input_source_fetch_sub"></a> [source\_fetch\_sub](#input\_source\_fetch\_sub) | Whether to fetch Git submodules for the AWS CodeBuild build project | `bool` | `false` | no |
| <a name="input_source_git_clone_depth"></a> [source\_git\_clone\_depth](#input\_source\_git\_clone\_depth) | Truncate git history to this many commits | `number` | `0` | no |
| <a name="input_source_location"></a> [source\_location](#input\_source\_location) | Location of the source code from git or s3 | `string` | `null` | no |
| <a name="input_source_report_build_status"></a> [source\_report\_build\_status](#input\_source\_report\_build\_status) | Whether to report the status of a build's start and finish to your source provider | `string` | `null` | no |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | Type of repository that contains the source code to be built | `string` | `"NO_SOURCE"` | no |
| <a name="input_source_version"></a> [source\_version](#input\_source\_version) | Version of the build input to be built for this project | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs within which to run builds | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC within which to run builds | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codebuild_project"></a> [codebuild\_project](#output\_codebuild\_project) | Map of codebuild project |
| <a name="output_codebuild_project_arn"></a> [codebuild\_project\_arn](#output\_codebuild\_project\_arn) | ARN of the CodeBuild project |
| <a name="output_codebuild_project_badge_url"></a> [codebuild\_project\_badge\_url](#output\_codebuild\_project\_badge\_url) | URL of the build badge when badge\_enabled is enabled |
| <a name="output_codebuild_project_id"></a> [codebuild\_project\_id](#output\_codebuild\_project\_id) | Name or ARN of the CodeBuild project |
| <a name="output_codebuild_project_project_alias"></a> [codebuild\_project\_project\_alias](#output\_codebuild\_project\_project\_alias) | The project identifier used with the public build APIs |
| <a name="output_codebuild_project_tags_all"></a> [codebuild\_project\_tags\_all](#output\_codebuild\_project\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |
| <a name="output_codebuild_resource_policy"></a> [codebuild\_resource\_policy](#output\_codebuild\_resource\_policy) | Map of codebuild resource policy |
| <a name="output_codepublish_buildspec_dotnet"></a> [codepublish\_buildspec\_dotnet](#output\_codepublish\_buildspec\_dotnet) | The codepublish dotnet buildspec file |
| <a name="output_codepublish_buildspec_dotnet_windows"></a> [codepublish\_buildspec\_dotnet\_windows](#output\_codepublish\_buildspec\_dotnet\_windows) | The codepublish dotnet Windows buildspec file |
| <a name="output_codepublish_buildspec_java"></a> [codepublish\_buildspec\_java](#output\_codepublish\_buildspec\_java) | The codepublish java buildspec file |
| <a name="output_codepublish_buildspec_java_lambda_container"></a> [codepublish\_buildspec\_java\_lambda\_container](#output\_codepublish\_buildspec\_java\_lambda\_container) | The codepublish container (Java Lambda) buildspec file |
| <a name="output_codepublish_buildspec_nodejs"></a> [codepublish\_buildspec\_nodejs](#output\_codepublish\_buildspec\_nodejs) | The codepublish nodejs buildspec file |
| <a name="output_codepublish_buildspec_python"></a> [codepublish\_buildspec\_python](#output\_codepublish\_buildspec\_python) | The codepublish python buildspec file |
| <a name="output_codescan_buildspec_dotnet"></a> [codescan\_buildspec\_dotnet](#output\_codescan\_buildspec\_dotnet) | The codescan dotnet buildspec file |
| <a name="output_codescan_buildspec_dotnet_windows"></a> [codescan\_buildspec\_dotnet\_windows](#output\_codescan\_buildspec\_dotnet\_windows) | The codescan dotnet Windows buildspec file |
| <a name="output_codescan_buildspec_java"></a> [codescan\_buildspec\_java](#output\_codescan\_buildspec\_java) | The codescan java buildspec file |
| <a name="output_codescan_buildspec_java_lambda_container"></a> [codescan\_buildspec\_java\_lambda\_container](#output\_codescan\_buildspec\_java\_lambda\_container) | The codescan container (Java Lambda) buildspec file |
| <a name="output_codescan_buildspec_nodejs"></a> [codescan\_buildspec\_nodejs](#output\_codescan\_buildspec\_nodejs) | The codescan nodejs buildspec file |
| <a name="output_codescan_buildspec_python"></a> [codescan\_buildspec\_python](#output\_codescan\_buildspec\_python) | The codescan python buildspec file |
| <a name="output_getartifact_buildspec_dotnet"></a> [getartifact\_buildspec\_dotnet](#output\_getartifact\_buildspec\_dotnet) | The codepublish dotnet buildspec file |
| <a name="output_getartifact_buildspec_java"></a> [getartifact\_buildspec\_java](#output\_getartifact\_buildspec\_java) | The codepublish java buildspec file |
| <a name="output_getartifact_buildspec_nodejs"></a> [getartifact\_buildspec\_nodejs](#output\_getartifact\_buildspec\_nodejs) | The codepublish nodejs buildspec file |
| <a name="output_secretscan_buildspec_container"></a> [secretscan\_buildspec\_container](#output\_secretscan\_buildspec\_container) | The secretscan buildspec file for container |
| <a name="output_wizscan_buildspec_container_java"></a> [wizscan\_buildspec\_container\_java](#output\_wizscan\_buildspec\_container\_java) | The wizscan java buildspec file for container |
| <a name="output_wizscan_buildspec_container_nodejs"></a> [wizscan\_buildspec\_container\_nodejs](#output\_wizscan\_buildspec\_container\_nodejs) | The wizscan nodejs buildspec file for container |
| <a name="output_wizscan_buildspec_container_python"></a> [wizscan\_buildspec\_container\_python](#output\_wizscan\_buildspec\_container\_python) | The wizscan python buildspec file for container |

<!-- END_TF_DOCS -->