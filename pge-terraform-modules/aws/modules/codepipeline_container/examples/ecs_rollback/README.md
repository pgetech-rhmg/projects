<!-- BEGIN_TF_DOCS -->
# AWS codepipeline example for Containarized Java module example
# Prerequisites : In the variables 'ssm\_parameter\_github\_oauth\_token', 'github\_repo\_url', 'dependency\_file\_location', 'artifactory\_repo\_key', 'project\_root\_directory' Provide the suitable values respectively in tfvars for testing.
# Code verified using terraform validate and terraform fmt -check.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

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
| <a name="module_codepipeline"></a> [codepipeline](#module\_codepipeline) | ../../modules/ecs_rollback | n/a |
| <a name="module_codepipeline_iam_role"></a> [codepipeline\_iam\_role](#module\_codepipeline\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_codepipeline_internal_gh_webhook"></a> [codepipeline\_internal\_gh\_webhook](#module\_codepipeline\_internal\_gh\_webhook) | app.terraform.io/pgetech/codepipeline_internal/aws//modules/gh_webhook | 0.1.6 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.allow_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.github_token_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssm_parameter.artifactory_docker_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Enter the application name | `string` | n/a | yes |
| <a name="input_appspec_template_path"></a> [appspec\_template\_path](#input\_appspec\_template\_path) | Enter appspec\_template\_path | `string` | n/a | yes |
| <a name="input_artifact_path"></a> [artifact\_path](#input\_artifact\_path) | Enter the path to store artifact - S3 | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_branch"></a> [branch](#input\_branch) | Branch of the GitHub repository, e.g 'master | `string` | n/a | yes |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | variables for security\_group\_project | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_cidr_egress_rules_SNS_codestar"></a> [cidr\_egress\_rules\_SNS\_codestar](#input\_cidr\_egress\_rules\_SNS\_codestar) | egress rule for codestar | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_codedeploy_application_name"></a> [codedeploy\_application\_name](#input\_codedeploy\_application\_name) | Enter Application name | `string` | n/a | yes |
| <a name="input_codedeploy_deployment_groupname"></a> [codedeploy\_deployment\_groupname](#input\_codedeploy\_deployment\_groupname) | Enter application deployment group name | `string` | n/a | yes |
| <a name="input_codedeploy_provider"></a> [codedeploy\_provider](#input\_codedeploy\_provider) | Enter CodeDeploy Provider name for deployment strategies | `string` | n/a | yes |
| <a name="input_codepipeline_name"></a> [codepipeline\_name](#input\_codepipeline\_name) | The name of the pipeline. | `string` | n/a | yes |
| <a name="input_codepipeline_role_service"></a> [codepipeline\_role\_service](#input\_codepipeline\_role\_service) | Aws service of the iam role | `list(string)` | <pre>[<br/>  "codepipeline.amazonaws.com"<br/>]</pre> | no |
| <a name="input_compute_type_codebuild"></a> [compute\_type\_codebuild](#input\_compute\_type\_codebuild) | Information about the compute resources the build project will use in codebuild project | `string` | n/a | yes |
| <a name="input_concurrent_build_limit_codebuild"></a> [concurrent\_build\_limit\_codebuild](#input\_concurrent\_build\_limit\_codebuild) | Maximum number of concurrent builds for the project in codebuild project | `number` | n/a | yes |
| <a name="input_endpoint_email"></a> [endpoint\_email](#input\_endpoint\_email) | Endpoint to send data to. The contents vary with the protocol | `list(string)` | n/a | yes |
| <a name="input_environment_image_codebuild"></a> [environment\_image\_codebuild](#input\_environment\_image\_codebuild) | Docker image to use for codebuild project. Valid values include Docker images provided by codebuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | n/a | yes |
| <a name="input_environment_type_codebuild"></a> [environment\_type\_codebuild](#input\_environment\_type\_codebuild) | Type of build environment to use for codebuild project related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | Github organization name of the repository, pgetech, DigitalCatalyst, etc | `string` | n/a | yes |
| <a name="input_image1_artifact_name"></a> [image1\_artifact\_name](#input\_image1\_artifact\_name) | Enter image1\_artifact\_name | `string` | n/a | yes |
| <a name="input_image1_container_name"></a> [image1\_container\_name](#input\_image1\_container\_name) | Enter image1\_container\_name | `string` | n/a | yes |
| <a name="input_java_runtime"></a> [java\_runtime](#input\_java\_runtime) | Enter the project root directory - variable in buildspec yml | `string` | n/a | yes |
| <a name="input_notification_message"></a> [notification\_message](#input\_notification\_message) | Enter Approval request notification message | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_pollchanges"></a> [pollchanges](#input\_pollchanges) | Periodically check the location of your source content and run the pipeline if changes are detected | `string` | n/a | yes |
| <a name="input_privileged_mode"></a> [privileged\_mode](#input\_privileged\_mode) | Whether to enable running the Docker daemon inside a Docker container | `bool` | `false` | no |
| <a name="input_publish_docker_registry"></a> [publish\_docker\_registry](#input\_publish\_docker\_registry) | Docker registry to publish the image. BOTH will publish the image to both ECR and JFROG. JFROG image will be considered default for the deployment | `string` | `"JFROG"` | no |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Github repository name of the application to be built | `string` | n/a | yes |
| <a name="input_rollback_image_tag"></a> [rollback\_image\_tag](#input\_rollback\_image\_tag) | Enter rollback image tag either from Jfrog ir ECR docker registries | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_token"></a> [secretsmanager\_artifactory\_token](#input\_secretsmanager\_artifactory\_token) | Enter the token value of jfrog artifactory stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_user"></a> [secretsmanager\_artifactory\_user](#input\_secretsmanager\_artifactory\_user) | Enter the name of jfrog artifactory user stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_github_token_secret_name"></a> [secretsmanager\_github\_token\_secret\_name](#input\_secretsmanager\_github\_token\_secret\_name) | secret manager path of the github OAUTH or PAT | `string` | n/a | yes |
| <a name="input_source_location_codebuild"></a> [source\_location\_codebuild](#input\_source\_location\_codebuild) | Location of the source code from git or s3 to build codescan project. | `string` | n/a | yes |
| <a name="input_ssm_parameter_artifactory_docker_registry"></a> [ssm\_parameter\_artifactory\_docker\_registry](#input\_ssm\_parameter\_artifactory\_docker\_registry) | Enter the name value of jfrog artifactory stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id\_1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | enter the value of subnet id\_2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes |
| <a name="input_task_definition_template_artifact"></a> [task\_definition\_template\_artifact](#input\_task\_definition\_template\_artifact) | enter Task definition template arti | `string` | n/a | yes |
| <a name="input_task_definition_template_path"></a> [task\_definition\_template\_path](#input\_task\_definition\_template\_path) | Enter task\_definition\_template\_path | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codepipeline_arn"></a> [codepipeline\_arn](#output\_codepipeline\_arn) | The codepipeline ARN |
| <a name="output_codepipeline_bucket"></a> [codepipeline\_bucket](#output\_codepipeline\_bucket) | codepipeline bucket name |
| <a name="output_codepipeline_id"></a> [codepipeline\_id](#output\_codepipeline\_id) | The codepipeline ID |

<!-- END_TF_DOCS -->
