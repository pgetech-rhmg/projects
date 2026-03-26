<!-- BEGIN_TF_DOCS -->
# AWS codepipeline for Container based Java application module
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
| <a name="module_codebuild_rollback_config"></a> [codebuild\_rollback\_config](#module\_codebuild\_rollback\_config) | app.terraform.io/pgetech/codebuild/aws | 0.1.4 |
| <a name="module_codestar-notifications"></a> [codestar-notifications](#module\_codestar-notifications) | ../../modules/codestar_notifications | n/a |
| <a name="module_iam_role_codedeploy"></a> [iam\_role\_codedeploy](#module\_iam\_role\_codedeploy) | app.terraform.io/pgetech/iam/aws | 0.1.0 |
| <a name="module_security-group"></a> [security-group](#module\_security-group) | app.terraform.io/pgetech/security-group/aws | 0.1.1 |
| <a name="module_sns_topic_manual_approval"></a> [sns\_topic\_manual\_approval](#module\_sns\_topic\_manual\_approval) | app.terraform.io/pgetech/sns/aws | 0.1.0 |
| <a name="module_sns_topic_subscription"></a> [sns\_topic\_subscription](#module\_sns\_topic\_subscription) | app.terraform.io/pgetech/sns/aws//modules/sns_subscription | 0.1.0 |
| <a name="module_twistlock_scan_iam_role"></a> [twistlock\_scan\_iam\_role](#module\_twistlock\_scan\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.0 |
| <a name="module_validate_codebuild_tags"></a> [validate\_codebuild\_tags](#module\_validate\_codebuild\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.0 |
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
| [aws_ssm_parameter.environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Enter the application name | `string` | n/a | yes |
| <a name="input_appspec_template_path"></a> [appspec\_template\_path](#input\_appspec\_template\_path) | Enter appspec\_template\_path | `string` | n/a | yes |
| <a name="input_artifact_bucket_owner_access"></a> [artifact\_bucket\_owner\_access](#input\_artifact\_bucket\_owner\_access) | Enter the artifact bucket owner access | `string` | `"FULL"` | no |
| <a name="input_artifact_path"></a> [artifact\_path](#input\_artifact\_path) | Enter the path to store artifact - S3 | `string` | n/a | yes |
| <a name="input_artifact_store_location_bucket"></a> [artifact\_store\_location\_bucket](#input\_artifact\_store\_location\_bucket) | The location where AWS CodePipeline stores artifacts for a pipeline; currently only S3 is supported. | `string` | n/a | yes |
| <a name="input_artifact_store_region"></a> [artifact\_store\_region](#input\_artifact\_store\_region) | The region where the artifact store is located. Required for a cross-region CodePipeline, do not provide for a single-region CodePipeline. | `string` | `null` | no |
| <a name="input_artifactory_docker_registry"></a> [artifactory\_docker\_registry](#input\_artifactory\_docker\_registry) | Enter the name value of jfrog artifactory | `string` | n/a | yes |
| <a name="input_aws_account_number"></a> [aws\_account\_number](#input\_aws\_account\_number) | Enter the provisoninged account number | `number` | n/a | yes |
| <a name="input_branch"></a> [branch](#input\_branch) | Branch of the GitHub repository, e.g 'master | `string` | n/a | yes |
| <a name="input_cache_location_rollback_config"></a> [cache\_location\_rollback\_config](#input\_cache\_location\_rollback\_config) | Location where the AWS CodeBuild project stores cached resources | `string` | `null` | no |
| <a name="input_cache_modes_rollback_config"></a> [cache\_modes\_rollback\_config](#input\_cache\_modes\_rollback\_config) | Specifies settings that AWS CodeBuild uses to store and reuse build dependencies | `string` | `"LOCAL_SOURCE_CACHE"` | no |
| <a name="input_cache_type_rollback_config"></a> [cache\_type\_rollback\_config](#input\_cache\_type\_rollback\_config) | Type of storage that will be used for the AWS CodeBuild project cache | `string` | `"NO_CACHE"` | no |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | variables for security\_group\_project | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_cidr_egress_rules_SNS_codestar"></a> [cidr\_egress\_rules\_SNS\_codestar](#input\_cidr\_egress\_rules\_SNS\_codestar) | egress rule for codestar | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_codebuild_role_service"></a> [codebuild\_role\_service](#input\_codebuild\_role\_service) | Aws service of the iam role | `list(string)` | <pre>[<br>  "codebuild.amazonaws.com"<br>]</pre> | no |
| <a name="input_codebuild_sc_token"></a> [codebuild\_sc\_token](#input\_codebuild\_sc\_token) | For GitHub or GitHub Enterprise, this is the personal access token. | `string` | n/a | yes |
| <a name="input_codedeploy_application_name"></a> [codedeploy\_application\_name](#input\_codedeploy\_application\_name) | Enter Application name | `string` | n/a | yes |
| <a name="input_codedeploy_deployment_groupname"></a> [codedeploy\_deployment\_groupname](#input\_codedeploy\_deployment\_groupname) | Enter application deployment group name | `string` | n/a | yes |
| <a name="input_codedeploy_provider"></a> [codedeploy\_provider](#input\_codedeploy\_provider) | Enter CodeDeploy Provider name for deployment strategies | `string` | n/a | yes |
| <a name="input_codedeploy_role_service"></a> [codedeploy\_role\_service](#input\_codedeploy\_role\_service) | A list of AWS services allowed to assume this role.  Required if the aws\_accounts variable is not provided. | `list(string)` | <pre>[<br>  "codedeploy.amazonaws.com"<br>]</pre> | no |
| <a name="input_codepipeline_name"></a> [codepipeline\_name](#input\_codepipeline\_name) | The name of the pipeline. | `string` | n/a | yes |
| <a name="input_compute_type_codepublish"></a> [compute\_type\_codepublish](#input\_compute\_type\_codepublish) | Information about the compute resources the build project will use in codepublish project | `string` | n/a | yes |
| <a name="input_concurrent_build_limit_codepublish"></a> [concurrent\_build\_limit\_codepublish](#input\_concurrent\_build\_limit\_codepublish) | Maximum number of concurrent builds for the codepublish project | `number` | n/a | yes |
| <a name="input_custom_codebuild_rollback_policy_file"></a> [custom\_codebuild\_rollback\_policy\_file](#input\_custom\_codebuild\_rollback\_policy\_file) | add custom codebuild roll back policy file for codebuild project, if needed | `string` | `null` | no |
| <a name="input_encryption_key_id"></a> [encryption\_key\_id](#input\_encryption\_key\_id) | The KMS key ARN or ID for artifact store | `string` | `null` | no |
| <a name="input_endpoint_email"></a> [endpoint\_email](#input\_endpoint\_email) | Endpoint to send data to. The contents vary with the protocol | `list(string)` | `null` | no |
| <a name="input_environment_image_codepublish"></a> [environment\_image\_codepublish](#input\_environment\_image\_codepublish) | Docker image to use for this codepublish project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | n/a | yes |
| <a name="input_environment_type_codepublish"></a> [environment\_type\_codepublish](#input\_environment\_type\_codepublish) | Type of build environment to use for codepublish project related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | n/a | yes |
| <a name="input_environment_variables_rollback_config"></a> [environment\_variables\_rollback\_config](#input\_environment\_variables\_rollback\_config) | Provide the list of environment variables required for codescan stage | `list(any)` | `[]` | no |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | Github organization name of the repository, pgetech, DigitalCatalyst, etc | `string` | n/a | yes |
| <a name="input_image1_artifact_name"></a> [image1\_artifact\_name](#input\_image1\_artifact\_name) | Enter image1\_artifact\_name | `string` | n/a | yes |
| <a name="input_image1_container_name"></a> [image1\_container\_name](#input\_image1\_container\_name) | Enter image1\_container\_name | `string` | n/a | yes |
| <a name="input_java_runtime"></a> [java\_runtime](#input\_java\_runtime) | Enter the project root directory - variable in buildspec yml | `string` | n/a | yes |
| <a name="input_notification_message"></a> [notification\_message](#input\_notification\_message) | Enter Approval request notification message | `string` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | Valid JSON document representing a resource policy | `string` | `"{}"` | no |
| <a name="input_pollchanges"></a> [pollchanges](#input\_pollchanges) | Periodically check the location of your source content and run the pipeline if changes are detected | `string` | n/a | yes |
| <a name="input_privileged_mode_twistlockscan"></a> [privileged\_mode\_twistlockscan](#input\_privileged\_mode\_twistlockscan) | Whether to enable running the Docker daemon inside a Docker container | `bool` | `false` | no |
| <a name="input_publish_docker_registry"></a> [publish\_docker\_registry](#input\_publish\_docker\_registry) | Docker registry to publish the image. BOTH will publish the image to both ECR and JFROG. JFROG image will be considered default for the deployment | `string` | `"JFROG"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region of pipeline stages | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Github repository name of the application to be built | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | A service role Amazon Resource Name (ARN) that grants AWS CodePipeline permission to make calls to AWS services on your behalf. | `string` | n/a | yes |
| <a name="input_rollback_image_tag"></a> [rollback\_image\_tag](#input\_rollback\_image\_tag) | Enter rollback image tag either from Jfrog ir ECR docker registries | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_token"></a> [secretsmanager\_artifactory\_token](#input\_secretsmanager\_artifactory\_token) | Enter the token value of jfrog artifactory stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_user"></a> [secretsmanager\_artifactory\_user](#input\_secretsmanager\_artifactory\_user) | Enter the name of jfrog artifactory user stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_github_token_secret_name"></a> [secretsmanager\_github\_token\_secret\_name](#input\_secretsmanager\_github\_token\_secret\_name) | secret manager path of the github OAUTH or PAT | `string` | n/a | yes |
| <a name="input_source_location_codepublish"></a> [source\_location\_codepublish](#input\_source\_location\_codepublish) | Location of the source code from git or s3 for codepublish. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs within which to run builds. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | n/a | yes |
| <a name="input_tags_codebuild"></a> [tags\_codebuild](#input\_tags\_codebuild) | tags for codebuild projects | `map(string)` | n/a | yes |
| <a name="input_task_definition_template_artifact"></a> [task\_definition\_template\_artifact](#input\_task\_definition\_template\_artifact) | enter Task definition template arti | `string` | n/a | yes |
| <a name="input_task_definition_template_path"></a> [task\_definition\_template\_path](#input\_task\_definition\_template\_path) | Enter task\_definition\_template\_path | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | enter the vpc id within which to run builds. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codepipeline_all"></a> [codepipeline\_all](#output\_codepipeline\_all) | Map of Codepipeline object |
| <a name="output_codepipeline_arn"></a> [codepipeline\_arn](#output\_codepipeline\_arn) | The codepipeline ARN |
| <a name="output_codepipeline_id"></a> [codepipeline\_id](#output\_codepipeline\_id) | The codepipeline ID |
| <a name="output_codepipeline_tags_all"></a> [codepipeline\_tags\_all](#output\_codepipeline\_tags\_all) | A map of tags assigned to the resource |

<!-- END_TF_DOCS -->
