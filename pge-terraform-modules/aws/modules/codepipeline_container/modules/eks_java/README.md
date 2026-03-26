<!-- BEGIN_TF_DOCS -->
# AWS codepipeline EKS module for Java
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
| <a name="module_internal_container"></a> [internal\_container](#module\_internal\_container) | ../internal/ | n/a |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID. Format = APP-#### | `number` | `1001` | no |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | n/a | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `string` | n/a | yes |
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | A domain name for which the certificate should be issued | `string` | n/a | yes |
| <a name="input_artifact_bucket_owner_access"></a> [artifact\_bucket\_owner\_access](#input\_artifact\_bucket\_owner\_access) | Enter the artifact bucket owner access | `string` | n/a | yes |
| <a name="input_artifact_location"></a> [artifact\_location](#input\_artifact\_location) | Enter the bucket name used for artifact storage | `string` | n/a | yes |
| <a name="input_artifact_path"></a> [artifact\_path](#input\_artifact\_path) | Enter the path to store artifact - S3 | `string` | n/a | yes |
| <a name="input_artifact_store_location_bucket"></a> [artifact\_store\_location\_bucket](#input\_artifact\_store\_location\_bucket) | The location where AWS CodePipeline stores artifacts for a pipeline; currently only S3 is supported. | `string` | n/a | yes |
| <a name="input_artifact_store_region"></a> [artifact\_store\_region](#input\_artifact\_store\_region) | The region where the artifact store is located. Required for a cross-region CodePipeline, do not provide for a single-region CodePipeline. | `string` | `null` | no |
| <a name="input_artifactory_docker_registry"></a> [artifactory\_docker\_registry](#input\_artifactory\_docker\_registry) | Enter the name value of JFrog Artifactory | `string` | n/a | yes |
| <a name="input_artifactory_helm_local_repo"></a> [artifactory\_helm\_local\_repo](#input\_artifactory\_helm\_local\_repo) | Enter the name value of jfrog artifactory helm chart virtual group name storedin ssm parameter | `string` | n/a | yes |
| <a name="input_artifactory_host"></a> [artifactory\_host](#input\_artifactory\_host) | Enter the name of JFrog Artifactory host | `string` | n/a | yes |
| <a name="input_artifactory_maven_repo"></a> [artifactory\_maven\_repo](#input\_artifactory\_maven\_repo) | Enter the name value of JFrog Artifactory | `string` | `null` | no |
| <a name="input_artifactory_repo_name"></a> [artifactory\_repo\_name](#input\_artifactory\_repo\_name) | Enter the name value of JFrog Artifactory | `string` | `null` | no |
| <a name="input_aws_account_number"></a> [aws\_account\_number](#input\_aws\_account\_number) | Enter the provisoninged account number | `string` | n/a | yes |
| <a name="input_branch"></a> [branch](#input\_branch) | Branch of the GitHub repository, e.g., 'master' | `string` | n/a | yes |
| <a name="input_branch_codesecret"></a> [branch\_codesecret](#input\_branch\_codesecret) | Branch of the GitHub repository, e.g., 'master' | `string` | `"main"` | no |
| <a name="input_cache_location_codebuild"></a> [cache\_location\_codebuild](#input\_cache\_location\_codebuild) | Location where the AWS CodeBuild project stores cached resources | `string` | `null` | no |
| <a name="input_cache_location_codescan"></a> [cache\_location\_codescan](#input\_cache\_location\_codescan) | Location where the AWS CodeBuild project stores cached resources | `string` | `null` | no |
| <a name="input_cache_modes_codebuild"></a> [cache\_modes\_codebuild](#input\_cache\_modes\_codebuild) | Specifies settings that AWS CodeBuild uses to store and reuse build dependencies | `string` | `"LOCAL_SOURCE_CACHE"` | no |
| <a name="input_cache_modes_codescan"></a> [cache\_modes\_codescan](#input\_cache\_modes\_codescan) | Specifies settings that AWS CodeBuild uses to store and reuse build dependencies | `string` | `"LOCAL_SOURCE_CACHE"` | no |
| <a name="input_cache_type_codebuild"></a> [cache\_type\_codebuild](#input\_cache\_type\_codebuild) | Type of storage that will be used for the AWS CodeBuild project cache | `string` | `"NO_CACHE"` | no |
| <a name="input_cache_type_codescan"></a> [cache\_type\_codescan](#input\_cache\_type\_codescan) | Type of storage that will be used for the AWS CodeBuild project cache | `string` | `"NO_CACHE"` | no |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | Variables for security group | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_cidr_egress_rules_SNS_codestar"></a> [cidr\_egress\_rules\_SNS\_codestar](#input\_cidr\_egress\_rules\_SNS\_codestar) | Egress rule for CodeStar | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_codebuild_role_service"></a> [codebuild\_role\_service](#input\_codebuild\_role\_service) | AWS service of the IAM role | `list(string)` | n/a | yes |
| <a name="input_codedeploy_provider"></a> [codedeploy\_provider](#input\_codedeploy\_provider) | Enter CodeDeploy Provider name for ECS Deployment strategies | `string` | `"ECS"` | no |
| <a name="input_codepipeline_name"></a> [codepipeline\_name](#input\_codepipeline\_name) | The name of the pipeline. | `string` | n/a | yes |
| <a name="input_codestar_lambda_encryption_key_id"></a> [codestar\_lambda\_encryption\_key\_id](#input\_codestar\_lambda\_encryption\_key\_id) | The KMS key ARN for CodeStar notifications | `string` | `null` | no |
| <a name="input_codestar_sns_kms_key_arn"></a> [codestar\_sns\_kms\_key\_arn](#input\_codestar\_sns\_kms\_key\_arn) | CodeStar KMS key ARN | `string` | `null` | no |
| <a name="input_compute_type_codebuild"></a> [compute\_type\_codebuild](#input\_compute\_type\_codebuild) | Information about the compute resources the build project will use in CodeBuild project | `string` | n/a | yes |
| <a name="input_compute_type_codepublish"></a> [compute\_type\_codepublish](#input\_compute\_type\_codepublish) | Information about the compute resources the build project will use in CodePublish project | `string` | n/a | yes |
| <a name="input_compute_type_codescan"></a> [compute\_type\_codescan](#input\_compute\_type\_codescan) | Information about the compute resources the build project will use in CodeScan project | `string` | n/a | yes |
| <a name="input_compute_type_codesecret"></a> [compute\_type\_codesecret](#input\_compute\_type\_codesecret) | Information about the compute resources the build project will use in CodeBuild project | `string` | n/a | yes |
| <a name="input_concurrent_build_limit_codebuild"></a> [concurrent\_build\_limit\_codebuild](#input\_concurrent\_build\_limit\_codebuild) | Maximum number of concurrent builds for the project in CodeBuild project | `number` | n/a | yes |
| <a name="input_concurrent_build_limit_codepublish"></a> [concurrent\_build\_limit\_codepublish](#input\_concurrent\_build\_limit\_codepublish) | Maximum number of concurrent builds for the CodePublish project | `number` | n/a | yes |
| <a name="input_concurrent_build_limit_codescan"></a> [concurrent\_build\_limit\_codescan](#input\_concurrent\_build\_limit\_codescan) | Maximum number of concurrent builds for the CodeScan project | `number` | n/a | yes |
| <a name="input_concurrent_build_limit_codesecret"></a> [concurrent\_build\_limit\_codesecret](#input\_concurrent\_build\_limit\_codesecret) | Maximum number of concurrent builds for the project in CodeBuild project | `number` | n/a | yes |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Enter the application container name | `string` | n/a | yes |
| <a name="input_custom_codebuild_policy_file"></a> [custom\_codebuild\_policy\_file](#input\_custom\_codebuild\_policy\_file) | Add custom CodeBuild policy file for CodeBuild project, if needed | `string` | `null` | no |
| <a name="input_custom_codepublish_policy_file"></a> [custom\_codepublish\_policy\_file](#input\_custom\_codepublish\_policy\_file) | Add custom CodePublish policy file for CodeBuild project, if needed | `string` | `null` | no |
| <a name="input_custom_codescan_policy_file"></a> [custom\_codescan\_policy\_file](#input\_custom\_codescan\_policy\_file) | Add custom CodeScan policy file for CodeBuild project, if needed | `string` | `null` | no |
| <a name="input_custom_domain_name"></a> [custom\_domain\_name](#input\_custom\_domain\_name) | A domain name for which the certificate should be issued | `string` | n/a | yes |
| <a name="input_encryption_key_id"></a> [encryption\_key\_id](#input\_encryption\_key\_id) | The KMS key ARN or ID for artifact store | `string` | `null` | no |
| <a name="input_endpoint_email"></a> [endpoint\_email](#input\_endpoint\_email) | Endpoint to send data to. The contents vary with the protocol | `list(string)` | `null` | no |
| <a name="input_environment_image_codebuild"></a> [environment\_image\_codebuild](#input\_environment\_image\_codebuild) | Docker image to use for CodeBuild project. Valid values include Docker images provided by CodeBuild (e.g., aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | n/a | yes |
| <a name="input_environment_image_codepublish"></a> [environment\_image\_codepublish](#input\_environment\_image\_codepublish) | Docker image to use for this CodePublish project. Valid values include Docker images provided by CodeBuild (e.g., aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | n/a | yes |
| <a name="input_environment_image_codescan"></a> [environment\_image\_codescan](#input\_environment\_image\_codescan) | Docker image to use for this CodeScan project. Valid values include Docker images provided by CodeBuild (e.g., aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | n/a | yes |
| <a name="input_environment_image_codesecret"></a> [environment\_image\_codesecret](#input\_environment\_image\_codesecret) | Docker image to use for CodeBuild project. Valid values include Docker images provided by CodeBuild (e.g., aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | n/a | yes |
| <a name="input_environment_type_codebuild"></a> [environment\_type\_codebuild](#input\_environment\_type\_codebuild) | Type of build environment to use for CodeBuild project related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | n/a | yes |
| <a name="input_environment_type_codepublish"></a> [environment\_type\_codepublish](#input\_environment\_type\_codepublish) | Type of build environment to use for CodePublish project related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | n/a | yes |
| <a name="input_environment_type_codescan"></a> [environment\_type\_codescan](#input\_environment\_type\_codescan) | Type of build environment to use for CodeScan related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | n/a | yes |
| <a name="input_environment_type_codesecret"></a> [environment\_type\_codesecret](#input\_environment\_type\_codesecret) | Type of build environment to use for CodeBuild project related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | n/a | yes |
| <a name="input_environment_variables_codebuild_stage"></a> [environment\_variables\_codebuild\_stage](#input\_environment\_variables\_codebuild\_stage) | Provide the list of environment variables required for CodeBuild stage | `list(any)` | `[]` | no |
| <a name="input_environment_variables_codescan_stage"></a> [environment\_variables\_codescan\_stage](#input\_environment\_variables\_codescan\_stage) | Provide the list of environment variables required for CodeScan stage | `list(any)` | `[]` | no |
| <a name="input_environment_variables_wiz_stage"></a> [environment\_variables\_wiz\_stage](#input\_environment\_variables\_wiz\_stage) | Provide the list of environment variables required for wiz stage | `list(any)` | `[]` | no |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | GitHub organization name of the repository, e.g., pgetech, DigitalCatalyst, etc. | `string` | n/a | yes |
| <a name="input_is_eks_fargate"></a> [is\_eks\_fargate](#input\_is\_eks\_fargate) | To embed wiz defender if the cluster is EKS Fargate | `bool` | `true` | no |
| <a name="input_java_runtime"></a> [java\_runtime](#input\_java\_runtime) | Enter the Java runtime version for CodeBuild stages - variable in buildspec yml | `string` | n/a | yes |
| <a name="input_java_runtime_codescan"></a> [java\_runtime\_codescan](#input\_java\_runtime\_codescan) | Enter the Java runtime version for CodeScan stage. Minimum of Java 17 version is required to run SonarScan - variable in buildspec yml | `string` | `"corretto17"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Enter the KMS key ARN for encryption - CodeBuild | `string` | `null` | no |
| <a name="input_pollchanges"></a> [pollchanges](#input\_pollchanges) | Periodically check the location of your source content and run the pipeline if changes are detected, this uses CodePipeline Polling. Default to false to use webhook. | `string` | `"false"` | no |
| <a name="input_pollchanges_codesecret"></a> [pollchanges\_codesecret](#input\_pollchanges\_codesecret) | Periodically check the location of your source content and run the pipeline if changes are detected | `string` | `false` | no |
| <a name="input_privileged_mode_wizscan"></a> [privileged\_mode\_wizscan](#input\_privileged\_mode\_wizscan) | Whether to enable running the Docker daemon inside a Docker container | `bool` | `false` | no |
| <a name="input_project_key"></a> [project\_key](#input\_project\_key) | A unique identifier of your project inside SonarQube | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The display name visible in SonarQube dashboard. Example: My Project | `string` | n/a | yes |
| <a name="input_project_root_directory"></a> [project\_root\_directory](#input\_project\_root\_directory) | Enter the project root directory - variable in buildspec yml | `string` | n/a | yes |
| <a name="input_publish_docker_registry"></a> [publish\_docker\_registry](#input\_publish\_docker\_registry) | Docker registry to publish the image. BOTH will publish the image to both ECR and JFROG. JFROG image will be considered default for the deployment | `string` | `"JFROG"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region of pipeline stages | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | GitHub repository name of the application to be built | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | A service role Amazon Resource Name (ARN) that grants AWS CodePipeline permission to make calls to AWS services on your behalf. | `string` | n/a | yes |
| <a name="input_runtime_version_codescan"></a> [runtime\_version\_codescan](#input\_runtime\_version\_codescan) | Enter the nodejs version value for codescan, Minimum of node18 version is required to run sonarscan. Latest LTS is 20 which is recommended | `string` | `"20"` | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | The location where AWS CodePipeline pulls artifacts for a pipeline | `string` | `""` | no |
| <a name="input_s3_object_key"></a> [s3\_object\_key](#input\_s3\_object\_key) | The S3 object key for the source artifact (e.g., source.zip) | `string` | `""` | no |
| <a name="input_secretsmanager_artifactory_token"></a> [secretsmanager\_artifactory\_token](#input\_secretsmanager\_artifactory\_token) | Enter the token value of JFrog Artifactory stored in Secrets Manager | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_user"></a> [secretsmanager\_artifactory\_user](#input\_secretsmanager\_artifactory\_user) | Enter the name of JFrog Artifactory user stored in Secrets Manager | `string` | n/a | yes |
| <a name="input_secretsmanager_github_token_secret_name"></a> [secretsmanager\_github\_token\_secret\_name](#input\_secretsmanager\_github\_token\_secret\_name) | Secret manager path of the GitHub OAUTH or PAT | `string` | n/a | yes |
| <a name="input_secretsmanager_sonar_token"></a> [secretsmanager\_sonar\_token](#input\_secretsmanager\_sonar\_token) | Enter the token of SonarQube stored in Secrets Manager | `string` | n/a | yes |
| <a name="input_secretsmanager_wiz_client_id"></a> [secretsmanager\_wiz\_client\_id](#input\_secretsmanager\_wiz\_client\_id) | Enter the name of wiz client id stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_wiz_client_secret"></a> [secretsmanager\_wiz\_client\_secret](#input\_secretsmanager\_wiz\_client\_secret) | Enter the token of wiz client secret stored in secrets manager | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | Description of the security group | `string` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | Name of the security group | `string` | n/a | yes |
| <a name="input_sonar_host"></a> [sonar\_host](#input\_sonar\_host) | Enter the host value of SonarQube | `string` | n/a | yes |
| <a name="input_source_buildspec_codebuild"></a> [source\_buildspec\_codebuild](#input\_source\_buildspec\_codebuild) | Enter the buildspec file of build stage CodeBuild project | `string` | n/a | yes |
| <a name="input_source_location_codebuild"></a> [source\_location\_codebuild](#input\_source\_location\_codebuild) | Location of the source code from Git or S3 to build CodeScan project. | `string` | n/a | yes |
| <a name="input_source_location_codepublish"></a> [source\_location\_codepublish](#input\_source\_location\_codepublish) | Location of the source code from Git or S3 for CodePublish. | `string` | n/a | yes |
| <a name="input_source_location_codescan"></a> [source\_location\_codescan](#input\_source\_location\_codescan) | Location of the source code from Git or S3 to build CodeScan project. | `string` | n/a | yes |
| <a name="input_source_location_codesecret"></a> [source\_location\_codesecret](#input\_source\_location\_codesecret) | Location of the source code from Git or S3 to build CodeScan project. | `string` | n/a | yes |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | The source type for the pipeline (GitHub or S3) | `string` | `"GitHub"` | no |
| <a name="input_stages"></a> [stages](#input\_stages) | Further stages after publish stage can be added in dynamic block. Dynamic stage is also optional when no values are provided in tfvars. | `list(any)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs within which to run builds. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | n/a | yes |
| <a name="input_tags_codebuild"></a> [tags\_codebuild](#input\_tags\_codebuild) | Tags for CodeBuild projects | `map(string)` | n/a | yes |
| <a name="input_unit_test_commands"></a> [unit\_test\_commands](#input\_unit\_test\_commands) | Default is empty as Sonar scan command will be used to run unit tests as well | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Enter the VPC ID within which to run builds. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codepipeline_all"></a> [codepipeline\_all](#output\_codepipeline\_all) | Map of Codepipeline object |
| <a name="output_codepipeline_arn"></a> [codepipeline\_arn](#output\_codepipeline\_arn) | The codepipeline ARN |
| <a name="output_codepipeline_id"></a> [codepipeline\_id](#output\_codepipeline\_id) | The codepipeline ID |
| <a name="output_codepipeline_tags_all"></a> [codepipeline\_tags\_all](#output\_codepipeline\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | n/a |
| <a name="output_sns_arn"></a> [sns\_arn](#output\_sns\_arn) | sns arn |

<!-- END_TF_DOCS -->
