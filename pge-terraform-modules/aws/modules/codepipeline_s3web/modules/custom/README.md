<!-- BEGIN_TF_DOCS -->
# AWS codepipeline Custom module
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
| <a name="module_internal_s3web"></a> [internal\_s3web](#module\_internal\_s3web) | ../internal/ | n/a |
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
| <a name="input_artifact_name_nodejs"></a> [artifact\_name\_nodejs](#input\_artifact\_name\_nodejs) | Enter the name of artifact name | `string` | n/a | yes |
| <a name="input_artifact_path"></a> [artifact\_path](#input\_artifact\_path) | Enter the path to store artifact - S3 | `string` | n/a | yes |
| <a name="input_artifact_store_location_bucket"></a> [artifact\_store\_location\_bucket](#input\_artifact\_store\_location\_bucket) | The location where AWS CodePipeline stores artifacts for a pipeline; currently only S3 is supported. | `string` | n/a | yes |
| <a name="input_artifact_store_region"></a> [artifact\_store\_region](#input\_artifact\_store\_region) | The region where the artifact store is located. Required for a cross-region CodePipeline, do not provide for a single-region CodePipeline. | `string` | `null` | no |
| <a name="input_artifactory_host"></a> [artifactory\_host](#input\_artifactory\_host) | Enter the name of jfrog artifactory host | `string` | n/a | yes |
| <a name="input_artifactory_key_path"></a> [artifactory\_key\_path](#input\_artifactory\_key\_path) | Enter the name of artifactory repo key path | `string` | n/a | yes |
| <a name="input_artifactory_repo_key"></a> [artifactory\_repo\_key](#input\_artifactory\_repo\_key) | JFrog npm Artifactory to use in Terraform CodePipeline to pull the npm dependencies | `string` | n/a | yes |
| <a name="input_artifactory_upload_file"></a> [artifactory\_upload\_file](#input\_artifactory\_upload\_file) | Enter the name of artifactory upload file | `string` | n/a | yes |
| <a name="input_aws_cloudfront_distribution_id"></a> [aws\_cloudfront\_distribution\_id](#input\_aws\_cloudfront\_distribution\_id) | aws cloudfront distribution id | `string` | n/a | yes |
| <a name="input_build_args1"></a> [build\_args1](#input\_build\_args1) | Provide the build environment variables required for codebuild | `string` | `""` | no |
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
| <a name="input_compute_type_codebuild"></a> [compute\_type\_codebuild](#input\_compute\_type\_codebuild) | Information about the compute resources the build project will use in codebuild project | `string` | n/a | yes |
| <a name="input_compute_type_codepublish"></a> [compute\_type\_codepublish](#input\_compute\_type\_codepublish) | Information about the compute resources the build project will use in codepublish project | `string` | n/a | yes |
| <a name="input_compute_type_codescan"></a> [compute\_type\_codescan](#input\_compute\_type\_codescan) | Information about the compute resources the build project will use in codescan project | `string` | n/a | yes |
| <a name="input_concurrent_build_limit_codebuild"></a> [concurrent\_build\_limit\_codebuild](#input\_concurrent\_build\_limit\_codebuild) | Maximum number of concurrent builds for the project in codebuild project | `number` | n/a | yes |
| <a name="input_concurrent_build_limit_codepublish"></a> [concurrent\_build\_limit\_codepublish](#input\_concurrent\_build\_limit\_codepublish) | Maximum number of concurrent builds for the codepublish project | `number` | n/a | yes |
| <a name="input_concurrent_build_limit_codescan"></a> [concurrent\_build\_limit\_codescan](#input\_concurrent\_build\_limit\_codescan) | Maximum number of concurrent builds for the codescan project | `number` | n/a | yes |
| <a name="input_custom_codebuild_policy_file"></a> [custom\_codebuild\_policy\_file](#input\_custom\_codebuild\_policy\_file) | add custom codebuild policy file for codebuild project, if needed | `string` | `null` | no |
| <a name="input_custom_codepublish_policy_file"></a> [custom\_codepublish\_policy\_file](#input\_custom\_codepublish\_policy\_file) | add custom codepublish policy file for codebuild project, if needed | `string` | `null` | no |
| <a name="input_custom_codescan_policy_file"></a> [custom\_codescan\_policy\_file](#input\_custom\_codescan\_policy\_file) | add custom codescan policy file for codebuild project, if needed | `string` | `null` | no |
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
| <a name="input_github_branch"></a> [github\_branch](#input\_github\_branch) | Enter the value of github repo branch | `string` | n/a | yes |
| <a name="input_github_repo_url"></a> [github\_repo\_url](#input\_github\_repo\_url) | Enter the github repo url for environment variable used in buildspec yml | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Enter the KMS key arn for encryption - codebuild | `string` | `null` | no |
| <a name="input_nodejs_version"></a> [nodejs\_version](#input\_nodejs\_version) | Enter the nodejs version value | `string` | n/a | yes |
| <a name="input_nodejs_version_codescan"></a> [nodejs\_version\_codescan](#input\_nodejs\_version\_codescan) | Enter the nodejs version value for codescan, Minimum of node18 version is required to run sonarscan. Latest LTS is 20 which is recommended | `string` | `"20"` | no |
| <a name="input_overwrite_s3_bucket"></a> [overwrite\_s3\_bucket](#input\_overwrite\_s3\_bucket) | Enter the type of the codepipeline application | `string` | `"false"` | no |
| <a name="input_pollchanges"></a> [pollchanges](#input\_pollchanges) | Periodically check the location of your source content and run the pipeline if changes are detected, this uses Codepipeline Polling. default to false to use webhook | `string` | `"false"` | no |
| <a name="input_project_key"></a> [project\_key](#input\_project\_key) | A unique identifier of your project inside SonarQube | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The display name visible in SonarQube dashboard. Example: My Project | `string` | n/a | yes |
| <a name="input_project_root_directory"></a> [project\_root\_directory](#input\_project\_root\_directory) | Enter the project root directory value | `string` | n/a | yes |
| <a name="input_project_unit_test_dir"></a> [project\_unit\_test\_dir](#input\_project\_unit\_test\_dir) | Enter the name of project unit test directory | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region of pipeline stages | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Github repository name of the application to be built | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | A service role Amazon Resource Name (ARN) that grants AWS CodePipeline permission to make calls to AWS services on your behalf. | `string` | n/a | yes |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | The location where AWS CodePipeline pulls artifacts for a pipeline | `string` | `""` | no |
| <a name="input_s3_object_key"></a> [s3\_object\_key](#input\_s3\_object\_key) | The S3 object key for the source artifact (e.g., source.zip) | `string` | `""` | no |
| <a name="input_s3_static_web_bucket_name"></a> [s3\_static\_web\_bucket\_name](#input\_s3\_static\_web\_bucket\_name) | Enter the bucket name | `string` | n/a | yes |
| <a name="input_s3_static_web_bucket_region"></a> [s3\_static\_web\_bucket\_region](#input\_s3\_static\_web\_bucket\_region) | Enter the bucket region | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_token"></a> [secretsmanager\_artifactory\_token](#input\_secretsmanager\_artifactory\_token) | Enter the token of artifactory stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_user"></a> [secretsmanager\_artifactory\_user](#input\_secretsmanager\_artifactory\_user) | Enter the name of jfrog artifactory user stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_github_token_secret_name"></a> [secretsmanager\_github\_token\_secret\_name](#input\_secretsmanager\_github\_token\_secret\_name) | secret manager path of the github OAUTH or PAT | `string` | n/a | yes |
| <a name="input_secretsmanager_sonar_token"></a> [secretsmanager\_sonar\_token](#input\_secretsmanager\_sonar\_token) | Enter the token of SonarQube stored in secrets manager | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | vpc id for security group | `string` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | name of the security group | `string` | n/a | yes |
| <a name="input_sonar_host"></a> [sonar\_host](#input\_sonar\_host) | Enter the value of SonarQube host | `string` | n/a | yes |
| <a name="input_source_buildspec_codebuild"></a> [source\_buildspec\_codebuild](#input\_source\_buildspec\_codebuild) | Enter the buildspec file of build stage codebuild project | `string` | n/a | yes |
| <a name="input_source_location_codebuild"></a> [source\_location\_codebuild](#input\_source\_location\_codebuild) | Location of the source code from git or s3 to build codescan project. | `string` | n/a | yes |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | The source type for the pipeline (GitHub or S3) | `string` | `"GitHub"` | no |
| <a name="input_stages"></a> [stages](#input\_stages) | Further stages after publisg stage can be added in dynamic block. Dynamic stage is also optional when no values is provided in tfvars | `list(any)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs within which to run builds. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_unit_test_commands"></a> [unit\_test\_commands](#input\_unit\_test\_commands) | The commands to execute unit tests | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | enter the vpc id within which to run builds. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codebuild_build_project_id"></a> [codebuild\_build\_project\_id](#output\_codebuild\_build\_project\_id) | Name or ARN of the CodeBuild project |
| <a name="output_codebuild_codepublish_project_id"></a> [codebuild\_codepublish\_project\_id](#output\_codebuild\_codepublish\_project\_id) | Name or ARN of the CodeBuild project |
| <a name="output_codebuild_codescan_project_id"></a> [codebuild\_codescan\_project\_id](#output\_codebuild\_codescan\_project\_id) | Name or ARN of the CodeBuild project |
| <a name="output_codepipeline_all"></a> [codepipeline\_all](#output\_codepipeline\_all) | Map of Codepipeline object |
| <a name="output_codepipeline_arn"></a> [codepipeline\_arn](#output\_codepipeline\_arn) | The codepipeline ARN |
| <a name="output_codepipeline_id"></a> [codepipeline\_id](#output\_codepipeline\_id) | The codepipeline ID |
| <a name="output_codepipeline_tags_all"></a> [codepipeline\_tags\_all](#output\_codepipeline\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_iam_codebuild_role_arn"></a> [iam\_codebuild\_role\_arn](#output\_iam\_codebuild\_role\_arn) | The Amazon Resource Name (ARN) specifying the role |
| <a name="output_iam_codepipeline_role_arn"></a> [iam\_codepipeline\_role\_arn](#output\_iam\_codepipeline\_role\_arn) | The Amazon Resource Name (ARN) specifying the role |
| <a name="output_iam_codepublish_role_arn"></a> [iam\_codepublish\_role\_arn](#output\_iam\_codepublish\_role\_arn) | The Amazon Resource Name (ARN) specifying the role |
| <a name="output_iam_codescan_role_arn"></a> [iam\_codescan\_role\_arn](#output\_iam\_codescan\_role\_arn) | The Amazon Resource Name (ARN) specifying the role |
| <a name="output_s3_codepipeiline_artifact_arn"></a> [s3\_codepipeiline\_artifact\_arn](#output\_s3\_codepipeiline\_artifact\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname |
| <a name="output_s3_codepipeiline_artifact_id"></a> [s3\_codepipeiline\_artifact\_id](#output\_s3\_codepipeiline\_artifact\_id) | The name of the bucket |
| <a name="output_sg_codebuild_id"></a> [sg\_codebuild\_id](#output\_sg\_codebuild\_id) | security group id |

<!-- END_TF_DOCS -->