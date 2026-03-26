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
| <a name="module_internal_core"></a> [internal\_core](#module\_internal\_core) | ../internal/ | n/a |
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifact_bucket_owner_access"></a> [artifact\_bucket\_owner\_access](#input\_artifact\_bucket\_owner\_access) | Enter the artifact bucket owner access | `string` | n/a | yes |
| <a name="input_artifact_location"></a> [artifact\_location](#input\_artifact\_location) | Enter the bucket name used for artifact storage | `string` | n/a | yes |
| <a name="input_artifact_path"></a> [artifact\_path](#input\_artifact\_path) | Enter the path to store artifact - S3 | `string` | n/a | yes |
| <a name="input_artifact_store_location_bucket"></a> [artifact\_store\_location\_bucket](#input\_artifact\_store\_location\_bucket) | The location where AWS CodePipeline stores artifacts for a pipeline; currently only S3 is supported. | `string` | n/a | yes |
| <a name="input_artifact_store_region"></a> [artifact\_store\_region](#input\_artifact\_store\_region) | The region where the artifact store is located. Required for a cross-region CodePipeline, do not provide for a single-region CodePipeline. | `string` | `null` | no |
| <a name="input_artifact_version"></a> [artifact\_version](#input\_artifact\_version) | Enter the artifact version | `string` | `null` | no |
| <a name="input_artifactory_host"></a> [artifactory\_host](#input\_artifactory\_host) | Enter the name of jfrog artifactory host - environment variable used in buildspec yml | `string` | n/a | yes |
| <a name="input_artifactory_repo_key"></a> [artifactory\_repo\_key](#input\_artifactory\_repo\_key) | Enter the artifact repo name of jfrog - environment variable used in buildspec yml | `string` | `""` | no |
| <a name="input_artifactory_repo_name"></a> [artifactory\_repo\_name](#input\_artifactory\_repo\_name) | Enter the artifact repo name of jfrog - environment variable used in buildspec yml | `string` | `""` | no |
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
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | variables for security\_group\_project | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_codebuild_role_service"></a> [codebuild\_role\_service](#input\_codebuild\_role\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_codepipeline_name"></a> [codepipeline\_name](#input\_codepipeline\_name) | The name of the pipeline. | `string` | n/a | yes |
| <a name="input_compute_type_codebuild"></a> [compute\_type\_codebuild](#input\_compute\_type\_codebuild) | Information about the compute resources the build project will use in codebuild project | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_compute_type_codedownload"></a> [compute\_type\_codedownload](#input\_compute\_type\_codedownload) | Information about the compute resources the build project will use in codedownload project | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_compute_type_codepublish"></a> [compute\_type\_codepublish](#input\_compute\_type\_codepublish) | Information about the compute resources the build project will use in codepublish project | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_compute_type_codescan"></a> [compute\_type\_codescan](#input\_compute\_type\_codescan) | Information about the compute resources the build project will use in codescan project | `string` | n/a | yes |
| <a name="input_concurrent_build_limit_codebuild"></a> [concurrent\_build\_limit\_codebuild](#input\_concurrent\_build\_limit\_codebuild) | Maximum number of concurrent builds for the project in codebuild project | `number` | `"1"` | no |
| <a name="input_concurrent_build_limit_codedownload"></a> [concurrent\_build\_limit\_codedownload](#input\_concurrent\_build\_limit\_codedownload) | Maximum number of concurrent builds for the codedownload project | `number` | `1` | no |
| <a name="input_concurrent_build_limit_codepublish"></a> [concurrent\_build\_limit\_codepublish](#input\_concurrent\_build\_limit\_codepublish) | Maximum number of concurrent builds for the codepublish project | `number` | `"1"` | no |
| <a name="input_concurrent_build_limit_codescan"></a> [concurrent\_build\_limit\_codescan](#input\_concurrent\_build\_limit\_codescan) | Maximum number of concurrent builds for the codescan project | `number` | n/a | yes |
| <a name="input_custom_codebuild_policy_file"></a> [custom\_codebuild\_policy\_file](#input\_custom\_codebuild\_policy\_file) | add custom codebuild policy file for codebuild project, if needed | `string` | `null` | no |
| <a name="input_custom_codedownload_policy_file"></a> [custom\_codedownload\_policy\_file](#input\_custom\_codedownload\_policy\_file) | add custom codedownload policy file for codebuild project, if needed | `string` | `null` | no |
| <a name="input_custom_codepublish_policy_file"></a> [custom\_codepublish\_policy\_file](#input\_custom\_codepublish\_policy\_file) | add custom codepublish policy file for codebuild project, if needed | `string` | `null` | no |
| <a name="input_custom_codescan_policy_file"></a> [custom\_codescan\_policy\_file](#input\_custom\_codescan\_policy\_file) | add custom codescan policy file for codebuild project, if needed | `string` | `null` | no |
| <a name="input_dependency_files_location"></a> [dependency\_files\_location](#input\_dependency\_files\_location) | Enter the dependency file location - environment variable used in buildspec yml | `string` | `""` | no |
| <a name="input_dotnet_project_metadata_file"></a> [dotnet\_project\_metadata\_file](#input\_dotnet\_project\_metadata\_file) | Name of the file that includes dotnet project's metadata and dependencies | `string` | `"appsettings.json"` | no |
| <a name="input_dotnet_runtime"></a> [dotnet\_runtime](#input\_dotnet\_runtime) | Enter the dotnet version to compile application code - variable in buildspec yml | `string` | `"6.0"` | no |
| <a name="input_dotnet_version"></a> [dotnet\_version](#input\_dotnet\_version) | Enter the dotnet version value | `string` | `"6.0"` | no |
| <a name="input_download_artifact"></a> [download\_artifact](#input\_download\_artifact) | Download artifact from jfrog, creates a pipeline with few stages to download artifact from artifactory and skips build, sonarscan, publish stages etc. This is only for QA or prod environments. | `bool` | `false` | no |
| <a name="input_enable_windows_build"></a> [enable\_windows\_build](#input\_enable\_windows\_build) | Enable Windows build environment for .NET projects | `bool` | `false` | no |
| <a name="input_encryption_key_id"></a> [encryption\_key\_id](#input\_encryption\_key\_id) | The KMS key ARN or ID for artifact store | `string` | `null` | no |
| <a name="input_environment_image_codebuild"></a> [environment\_image\_codebuild](#input\_environment\_image\_codebuild) | Docker image to use for codebuild project. Valid values include Docker images provided by codebuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:5.0"` | no |
| <a name="input_environment_image_codebuild_windows"></a> [environment\_image\_codebuild\_windows](#input\_environment\_image\_codebuild\_windows) | Docker image to use for Windows codebuild project. Use Windows Server 2019 base image for .NET builds. | `string` | `"aws/codebuild/windows-base:2019-3.0"` | no |
| <a name="input_environment_image_codedownload"></a> [environment\_image\_codedownload](#input\_environment\_image\_codedownload) | Docker image to use for this codedownload project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:5.0"` | no |
| <a name="input_environment_image_codedownload_windows"></a> [environment\_image\_codedownload\_windows](#input\_environment\_image\_codedownload\_windows) | Docker image to use for Windows codedownload project. Use Windows Server 2019 base image for .NET builds. | `string` | `"aws/codebuild/windows-base:2019-3.0"` | no |
| <a name="input_environment_image_codepublish"></a> [environment\_image\_codepublish](#input\_environment\_image\_codepublish) | Docker image to use for this codepublish project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:5.0"` | no |
| <a name="input_environment_image_codepublish_windows"></a> [environment\_image\_codepublish\_windows](#input\_environment\_image\_codepublish\_windows) | Docker image to use for Windows codepublish project. Use Windows Server 2019 base image for .NET builds. | `string` | `"aws/codebuild/windows-base:2019-3.0"` | no |
| <a name="input_environment_image_codescan"></a> [environment\_image\_codescan](#input\_environment\_image\_codescan) | Docker image to use for this codescan project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | n/a | yes |
| <a name="input_environment_image_codescan_windows"></a> [environment\_image\_codescan\_windows](#input\_environment\_image\_codescan\_windows) | Docker image to use for Windows codescan project. Use Windows Server 2019 base image for .NET builds. | `string` | `"aws/codebuild/windows-base:2019-3.0"` | no |
| <a name="input_environment_type_codebuild"></a> [environment\_type\_codebuild](#input\_environment\_type\_codebuild) | Type of build environment to use for codebuild project related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_environment_type_codedownload"></a> [environment\_type\_codedownload](#input\_environment\_type\_codedownload) | Type of build environment to use for codedownload project related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_environment_type_codepublish"></a> [environment\_type\_codepublish](#input\_environment\_type\_codepublish) | Type of build environment to use for codepublish project related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_environment_type_codescan"></a> [environment\_type\_codescan](#input\_environment\_type\_codescan) | Type of build environment to use for codescan related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | n/a | yes |
| <a name="input_environment_variables_codebuild_stage"></a> [environment\_variables\_codebuild\_stage](#input\_environment\_variables\_codebuild\_stage) | Provide the list of environment variables required for codebuild stage | `list(any)` | `[]` | no |
| <a name="input_environment_variables_codepublish_stage"></a> [environment\_variables\_codepublish\_stage](#input\_environment\_variables\_codepublish\_stage) | Provide the list of environment variables required for codepublish stage | `list(any)` | `[]` | no |
| <a name="input_environment_variables_codescan_stage"></a> [environment\_variables\_codescan\_stage](#input\_environment\_variables\_codescan\_stage) | Provide the list of environment variables required for codescan stage | `list(any)` | `[]` | no |
| <a name="input_exclude_files"></a> [exclude\_files](#input\_exclude\_files) | space separated files/folders that should not be added to the Lambda function | `string` | `""` | no |
| <a name="input_github_branch"></a> [github\_branch](#input\_github\_branch) | Enter the value of github repo branch - environment variable used in buildspec yml | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | Github organization name of the repository, pgetech, DigitalCatalyst, etc | `string` | n/a | yes |
| <a name="input_github_repo_url"></a> [github\_repo\_url](#input\_github\_repo\_url) | Enter the github repo url - environment variable used in buildspec yml | `string` | n/a | yes |
| <a name="input_install_dotnet9"></a> [install\_dotnet9](#input\_install\_dotnet9) | Whether to install dotnet9 or not | `string` | `"false"` | no |
| <a name="input_install_telerik"></a> [install\_telerik](#input\_install\_telerik) | weather to install telerik or not | `string` | `"false"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Enter the KMS key arn for encryption - codebuild | `string` | `null` | no |
| <a name="input_pollchanges"></a> [pollchanges](#input\_pollchanges) | Periodically check the location of your source content and run the pipeline if changes are detected, this uses Codepipeline Polling. default to false to use webhook | `string` | `"false"` | no |
| <a name="input_project_file"></a> [project\_file](#input\_project\_file) | The path to the project file for the build process. | `string` | `""` | no |
| <a name="input_project_file_location"></a> [project\_file\_location](#input\_project\_file\_location) | Enter the project file location value | `string` | `null` | no |
| <a name="input_project_key"></a> [project\_key](#input\_project\_key) | A unique identifier of your project inside SonarQube | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The display name visible in SonarQube dashboard. Example: My Project | `string` | n/a | yes |
| <a name="input_project_root_directory"></a> [project\_root\_directory](#input\_project\_root\_directory) | Enter the project root directory value | `string` | n/a | yes |
| <a name="input_project_unit_test_dir"></a> [project\_unit\_test\_dir](#input\_project\_unit\_test\_dir) | Enter the name of project unit test directory | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region of pipeline stages | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Github repository name of the application to be built | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | A service role Amazon Resource Name (ARN) that grants AWS CodePipeline permission to make calls to AWS services on your behalf. | `string` | n/a | yes |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | The name of the S3 bucket containing the source code artifact for the pipeline. | `string` | `""` | no |
| <a name="input_s3_object_key"></a> [s3\_object\_key](#input\_s3\_object\_key) | The S3 object key for the source artifact (e.g., source.zip) | `string` | `""` | no |
| <a name="input_s3_telerik_extract_path"></a> [s3\_telerik\_extract\_path](#input\_s3\_telerik\_extract\_path) | S3 telerik extract path to download packages to install telerik | `string` | `"telerik.ui.for.blazor.2.28.0.commercial.msi"` | no |
| <a name="input_s3_telerik_file_name"></a> [s3\_telerik\_file\_name](#input\_s3\_telerik\_file\_name) | S3 telerik file name to download packages to install telerik | `string` | `"telerik.ui.for.blazor.2.28.0.commercial.msi.zip"` | no |
| <a name="input_secretsmanager_artifactory_token"></a> [secretsmanager\_artifactory\_token](#input\_secretsmanager\_artifactory\_token) | Enter the token value of jfrog artifactory stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_user"></a> [secretsmanager\_artifactory\_user](#input\_secretsmanager\_artifactory\_user) | Enter the name of jfrog artifactory user stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_github_token_secret_name"></a> [secretsmanager\_github\_token\_secret\_name](#input\_secretsmanager\_github\_token\_secret\_name) | secret manager path of the github OAUTH or PAT | `string` | n/a | yes |
| <a name="input_secretsmanager_sonar_token"></a> [secretsmanager\_sonar\_token](#input\_secretsmanager\_sonar\_token) | Enter the token of SonarQube stored in secrets manager | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | vpc id for security group | `string` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | name of the security group | `string` | n/a | yes |
| <a name="input_sonar_branch_scanned"></a> [sonar\_branch\_scanned](#input\_sonar\_branch\_scanned) | branch that has already been scanned with artifactory to check QG status on sonarqube and skip sonarscan rerun, requires only when download\_artifact is true | `string` | `""` | no |
| <a name="input_sonar_exclusion_list"></a> [sonar\_exclusion\_list](#input\_sonar\_exclusion\_list) | List of files and directories to exclude from SonarQube analysis. | `string` | `"**/*.txt"` | no |
| <a name="input_sonar_host"></a> [sonar\_host](#input\_sonar\_host) | Enter the host value of SonarQube | `string` | n/a | yes |
| <a name="input_sonar_scanner_cli_version"></a> [sonar\_scanner\_cli\_version](#input\_sonar\_scanner\_cli\_version) | The version of sonar-scanner CLI binary to download. Default is the latest version. | `string` | `"5.0.1.3006"` | no |
| <a name="input_source_buildspec_codebuild"></a> [source\_buildspec\_codebuild](#input\_source\_buildspec\_codebuild) | Enter the buildspec file of build stage codebuild project | `string` | `null` | no |
| <a name="input_source_location_codebuild"></a> [source\_location\_codebuild](#input\_source\_location\_codebuild) | Location of the source code from git or s3 to build codescan project. | `string` | `null` | no |
| <a name="input_source_location_codedownload"></a> [source\_location\_codedownload](#input\_source\_location\_codedownload) | Location of the source code from git or s3 for codedownload. | `string` | `null` | no |
| <a name="input_source_location_codepublish"></a> [source\_location\_codepublish](#input\_source\_location\_codepublish) | Location of the source code from git or s3 for codepublish. | `string` | `null` | no |
| <a name="input_source_location_codescan"></a> [source\_location\_codescan](#input\_source\_location\_codescan) | Location of the source code from git or s3 to build codescan project. | `string` | `null` | no |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | The source type for the pipeline (GitHub or S3) | `string` | `"GitHub"` | no |
| <a name="input_stages"></a> [stages](#input\_stages) | Further stages after publisg stage can be added in dynamic block. Dynamic stage is also optional when no values is provided in tfvars | `list(any)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs within which to run builds. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_telerik_s3_bucket_name"></a> [telerik\_s3\_bucket\_name](#input\_telerik\_s3\_bucket\_name) | Telerik S3 bucket name to download packages to install telerik | `string` | `""` | no |
| <a name="input_unit_test_commands"></a> [unit\_test\_commands](#input\_unit\_test\_commands) | Enter the unit test commands for dotnet webapp | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | enter the vpc id within which to run builds. | `string` | n/a | yes |
| <a name="input_windows_environment_type"></a> [windows\_environment\_type](#input\_windows\_environment\_type) | Type of Windows build environment container for Windows builds | `string` | `"WINDOWS_SERVER_2019_CONTAINER"` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codepipeline_all"></a> [codepipeline\_all](#output\_codepipeline\_all) | Map of Codepipeline object |
| <a name="output_codepipeline_arn"></a> [codepipeline\_arn](#output\_codepipeline\_arn) | The codepipeline ARN |
| <a name="output_codepipeline_id"></a> [codepipeline\_id](#output\_codepipeline\_id) | The codepipeline ID |

<!-- END_TF_DOCS -->
