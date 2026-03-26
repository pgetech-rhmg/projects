<!-- BEGIN_TF_DOCS -->
# AWS codepipeline project Java Docker example
# CodeScan and CodePublish stages buildspec files get added by terraform module. CodePublish stage reads lambda function name variable and publishes lambda version using aws cli, generates Docker image with built code, uploads to registry and updates lambda function with container image
# Prerequisites : In the variables 'lambda\_function\_name', 'lambda\_alias\_name', 'secretsmanager\_github\_token\_secret\_name', 'secretsmanager\_artifactory\_user', 'ssm\_parameter\_sonar\_host', 'secretsmanager\_artifactory\_token', 'docker\_image\_name', 'app\_owners', 'publish\_docker\_registry', secretsmanager\_sonar\_token Provide the suitable values respectively in tfvars for testing.
# Code verified using terraform validate and terraform fmt -check.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.4.0 |

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
| <a name="module_aws_lambda_iam_role"></a> [aws\_lambda\_iam\_role](#module\_aws\_lambda\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_codepipeline"></a> [codepipeline](#module\_codepipeline) | ../../modules/container | n/a |
| <a name="module_codepipeline_iam_role"></a> [codepipeline\_iam\_role](#module\_codepipeline\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_codepipeline_internal_gh_webhook"></a> [codepipeline\_internal\_gh\_webhook](#module\_codepipeline\_internal\_gh\_webhook) | app.terraform.io/pgetech/codepipeline_internal/aws//modules/gh_webhook | 0.1.4 |
| <a name="module_lambda_alias"></a> [lambda\_alias](#module\_lambda\_alias) | app.terraform.io/pgetech/lambda/aws//modules/lambda_alias | 0.1.0 |
| <a name="module_lambda_image"></a> [lambda\_image](#module\_lambda\_image) | app.terraform.io/pgetech/lambda/aws//modules/lambda_image | 0.1.3 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_security_group_lambda"></a> [security\_group\_lambda](#module\_security\_group\_lambda) | app.terraform.io/pgetech/security-group/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_pet.cp_random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.allow_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.github_token_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssm_parameter.artifactory_docker_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.artifactory_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.sonar_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
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
| <a name="input_allow_outofband_update"></a> [allow\_outofband\_update](#input\_allow\_outofband\_update) | Whether to allow the Lambda function to be updated outside of Terraform | `bool` | `true` | no |
| <a name="input_app_owners"></a> [app\_owners](#input\_app\_owners) | Application owners for Docker image metadata | `string` | `"PGE-DevOps"` | no |
| <a name="input_artifact_bucket_owner_access"></a> [artifact\_bucket\_owner\_access](#input\_artifact\_bucket\_owner\_access) | Enter the artifact bucket owner access | `string` | `"FULL"` | no |
| <a name="input_artifact_path"></a> [artifact\_path](#input\_artifact\_path) | Enter the path to store artifact - S3 | `string` | `""` | no |
| <a name="input_artifactory_repo_name"></a> [artifactory\_repo\_name](#input\_artifactory\_repo\_name) | Enter the artifact repo name of jfrog - environment variable used in buildspec yml | `string` | `"java-local"` | no |
| <a name="input_aws_account_number"></a> [aws\_account\_number](#input\_aws\_account\_number) | Enter the provisoninged account number | `number` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_branch"></a> [branch](#input\_branch) | Branch of the GitHub repository, e.g 'master | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Bucket name for codepipeline | `string` | n/a | yes |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "description": "All outbound traffic",<br/>    "from": 0,<br/>    "ipv6_cidr_blocks": [],<br/>    "prefix_list_ids": [],<br/>    "protocol": "tcp",<br/>    "to": 65535<br/>  },<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "description": "All outbound traffic",<br/>    "from": 0,<br/>    "ipv6_cidr_blocks": [],<br/>    "prefix_list_ids": [],<br/>    "protocol": "udp",<br/>    "to": 65535<br/>  }<br/>]</pre> | no |
| <a name="input_cidr_egress_rules_lambda"></a> [cidr\_egress\_rules\_lambda](#input\_cidr\_egress\_rules\_lambda) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "description": "All outbound traffic",<br/>    "from": 0,<br/>    "ipv6_cidr_blocks": [],<br/>    "prefix_list_ids": [],<br/>    "protocol": "tcp",<br/>    "to": 65535<br/>  },<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "description": "All outbound traffic",<br/>    "from": 0,<br/>    "ipv6_cidr_blocks": [],<br/>    "prefix_list_ids": [],<br/>    "protocol": "udp",<br/>    "to": 65535<br/>  }<br/>]</pre> | no |
| <a name="input_codebuild_role_service"></a> [codebuild\_role\_service](#input\_codebuild\_role\_service) | Aws service of the iam role | `list(string)` | <pre>[<br/>  "codebuild.amazonaws.com"<br/>]</pre> | no |
| <a name="input_codebuildapp_language"></a> [codebuildapp\_language](#input\_codebuildapp\_language) | The language for the codebuild pipeline (e.g., docker, java, nodejs, etc.) | `string` | `"docker"` | no |
| <a name="input_codepipeline_name"></a> [codepipeline\_name](#input\_codepipeline\_name) | The name of the pipeline. | `string` | `""` | no |
| <a name="input_codepipeline_role_service"></a> [codepipeline\_role\_service](#input\_codepipeline\_role\_service) | Aws service of the iam role | `list(string)` | <pre>[<br/>  "codepipeline.amazonaws.com"<br/>]</pre> | no |
| <a name="input_compute_type_codebuild"></a> [compute\_type\_codebuild](#input\_compute\_type\_codebuild) | Information about the compute resources the build project will use in codebuild project | `string` | `"BUILD_GENERAL1_MEDIUM"` | no |
| <a name="input_compute_type_codepublish"></a> [compute\_type\_codepublish](#input\_compute\_type\_codepublish) | Information about the compute resources the build project will use in codepublish project | `string` | `"BUILD_GENERAL1_MEDIUM"` | no |
| <a name="input_compute_type_codescan"></a> [compute\_type\_codescan](#input\_compute\_type\_codescan) | Information about the compute resources the build project will use in codescan project | `string` | `"BUILD_GENERAL1_MEDIUM"` | no |
| <a name="input_concurrent_build_limit_codebuild"></a> [concurrent\_build\_limit\_codebuild](#input\_concurrent\_build\_limit\_codebuild) | Maximum number of concurrent builds for the project in codebuild project | `number` | `1` | no |
| <a name="input_concurrent_build_limit_codepublish"></a> [concurrent\_build\_limit\_codepublish](#input\_concurrent\_build\_limit\_codepublish) | Maximum number of concurrent builds for the codepublish project | `number` | `1` | no |
| <a name="input_concurrent_build_limit_codescan"></a> [concurrent\_build\_limit\_codescan](#input\_concurrent\_build\_limit\_codescan) | Maximum number of concurrent builds for the codescan project | `number` | `1` | no |
| <a name="input_dependency_files_location"></a> [dependency\_files\_location](#input\_dependency\_files\_location) | Enter the dependency file location - environment variable used in buildspec yml | `string` | `"pom.xml"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the lambda function | `string` | `"Java Lambda function using Docker containers"` | no |
| <a name="input_docker_image_name"></a> [docker\_image\_name](#input\_docker\_image\_name) | Name of the Docker image to be built for the Java Lambda | `string` | n/a | yes |
| <a name="input_environment_image_codebuild"></a> [environment\_image\_codebuild](#input\_environment\_image\_codebuild) | Docker image to use for codebuild project | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:3.0"` | no |
| <a name="input_environment_image_codepublish"></a> [environment\_image\_codepublish](#input\_environment\_image\_codepublish) | Docker image to use for this codepublish project | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:3.0"` | no |
| <a name="input_environment_image_codescan"></a> [environment\_image\_codescan](#input\_environment\_image\_codescan) | Docker image to use for this codescan project | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:3.0"` | no |
| <a name="input_environment_type_codebuild"></a> [environment\_type\_codebuild](#input\_environment\_type\_codebuild) | Type of build environment to use for codebuild project related builds | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_environment_type_codepublish"></a> [environment\_type\_codepublish](#input\_environment\_type\_codepublish) | Type of build environment to use for codepublish project related builds | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_environment_type_codescan"></a> [environment\_type\_codescan](#input\_environment\_type\_codescan) | Type of build environment to use for codescan related builds | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables for the Lambda function | `map(string)` | `{}` | no |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | Github organization name of the repository, pgetech, DigitalCatalyst, etc | `string` | n/a | yes |
| <a name="input_github_repo_url"></a> [github\_repo\_url](#input\_github\_repo\_url) | Enter the github repo url - environment variable used in buildspec yml | `string` | `""` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint in your code | `string` | n/a | yes |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Tag of the Docker image to deploy to Lambda (e.g., CodeBuild output tag or timestamp). | `string` | `""` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | ECR image URI placeholder for lambda\_image module (e.g. 750713712981.dkr.ecr.us-west-2.amazonaws.com/repo:tag) | `string` | `""` | no |
| <a name="input_include_lib_files"></a> [include\_lib\_files](#input\_include\_lib\_files) | Set it to false if lib files need not to be added | `bool` | `true` | no |
| <a name="input_java_runtime"></a> [java\_runtime](#input\_java\_runtime) | Java runtime version for Docker builds | `string` | n/a | yes |
| <a name="input_lambda_alias_name"></a> [lambda\_alias\_name](#input\_lambda\_alias\_name) | Enter the name of the Lambda alias | `string` | n/a | yes |
| <a name="input_lambda_cidr_egress_rules"></a> [lambda\_cidr\_egress\_rules](#input\_lambda\_cidr\_egress\_rules) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_lambda_cidr_ingress_rules"></a> [lambda\_cidr\_ingress\_rules](#input\_lambda\_cidr\_ingress\_rules) | variables for security\_group | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | Enter the name of the Lambda Function | `string` | n/a | yes |
| <a name="input_lambda_iam_aws_service"></a> [lambda\_iam\_aws\_service](#input\_lambda\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_lambda_iam_name"></a> [lambda\_iam\_name](#input\_lambda\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_lambda_iam_policy_arns"></a> [lambda\_iam\_policy\_arns](#input\_lambda\_iam\_policy\_arns) | Policy arn for the iam role | `list(string)` | n/a | yes |
| <a name="input_lambda_role_service"></a> [lambda\_role\_service](#input\_lambda\_role\_service) | Aws service of the lambda iam role | `list(string)` | <pre>[<br/>  "lambda.amazonaws.com"<br/>]</pre> | no |
| <a name="input_lambda_sg_description"></a> [lambda\_sg\_description](#input\_lambda\_sg\_description) | vpc id for security group | `string` | n/a | yes |
| <a name="input_lambda_sg_name"></a> [lambda\_sg\_name](#input\_lambda\_sg\_name) | name of the security group | `string` | n/a | yes |
| <a name="input_lambda_update"></a> [lambda\_update](#input\_lambda\_update) | Input from the user to update lambda function with container image or not | `bool` | `true` | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_project_key"></a> [project\_key](#input\_project\_key) | A unique identifier of your project inside SonarQube | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The display name visible in SonarQube dashboard. Example: My Project | `string` | n/a | yes |
| <a name="input_project_root_directory"></a> [project\_root\_directory](#input\_project\_root\_directory) | Enter the project root directory - environment variable used in buildspec yml | `string` | n/a | yes |
| <a name="input_publish_docker_registry"></a> [publish\_docker\_registry](#input\_publish\_docker\_registry) | Where to publish the Docker image (ECR, JFROG, or BOTH) | `string` | `"ECR"` | no |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Github repository name of the application to be built | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Identifier of the function's runtime | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_token"></a> [secretsmanager\_artifactory\_token](#input\_secretsmanager\_artifactory\_token) | Enter the token value of jfrog artifactory stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_user"></a> [secretsmanager\_artifactory\_user](#input\_secretsmanager\_artifactory\_user) | Enter the name of jfrog artifactory user stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_github_token_secret_name"></a> [secretsmanager\_github\_token\_secret\_name](#input\_secretsmanager\_github\_token\_secret\_name) | secret manager path of the github OAUTH or PAT | `string` | n/a | yes |
| <a name="input_secretsmanager_sonar_token"></a> [secretsmanager\_sonar\_token](#input\_secretsmanager\_sonar\_token) | Enter the token of SonarQube stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_wiz_client_id"></a> [secretsmanager\_wiz\_client\_id](#input\_secretsmanager\_wiz\_client\_id) | Enter the name of wiz client id stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_wiz_client_secret"></a> [secretsmanager\_wiz\_client\_secret](#input\_secretsmanager\_wiz\_client\_secret) | Enter the token of wiz client secret stored in secrets manager | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | vpc id for security group | `string` | `"Security group for CodeBuild"` | no |
| <a name="input_sg_description_lambda"></a> [sg\_description\_lambda](#input\_sg\_description\_lambda) | security group description for lambda | `string` | `"Security group for Lambda function"` | no |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | name of the security group | `string` | `"codebuild_sg"` | no |
| <a name="input_sg_name_lambda"></a> [sg\_name\_lambda](#input\_sg\_name\_lambda) | name of the security group for lambda | `string` | `"lambda_sg"` | no |
| <a name="input_sonar_scanner_cli_version"></a> [sonar\_scanner\_cli\_version](#input\_sonar\_scanner\_cli\_version) | Enter the SonarScanner CLI version for Java analysis | `string` | `"4.6.2.2472"` | no |
| <a name="input_source_buildspec_codebuild"></a> [source\_buildspec\_codebuild](#input\_source\_buildspec\_codebuild) | Path to the buildspec file for the build stage | `string` | `""` | no |
| <a name="input_source_buildspec_codepublish"></a> [source\_buildspec\_codepublish](#input\_source\_buildspec\_codepublish) | Path to the buildspec file for the publish stage | `string` | `""` | no |
| <a name="input_source_buildspec_codescan"></a> [source\_buildspec\_codescan](#input\_source\_buildspec\_codescan) | Path to the buildspec file for the scan stage | `string` | `""` | no |
| <a name="input_source_location_codebuild"></a> [source\_location\_codebuild](#input\_source\_location\_codebuild) | Location of the source code from git or s3 to build project | `string` | `""` | no |
| <a name="input_source_location_codepublish"></a> [source\_location\_codepublish](#input\_source\_location\_codepublish) | Location of the source code from git or s3 to build codepublish project. | `string` | n/a | yes |
| <a name="input_source_location_codescan"></a> [source\_location\_codescan](#input\_source\_location\_codescan) | Location of the source code from git or s3 to build codescan project. | `string` | n/a | yes |
| <a name="input_source_location_wizscan"></a> [source\_location\_wizscan](#input\_source\_location\_wizscan) | Source location for the wizscan stage | `string` | n/a | yes |
| <a name="input_ssm_parameter_artifactory_docker_registry"></a> [ssm\_parameter\_artifactory\_docker\_registry](#input\_ssm\_parameter\_artifactory\_docker\_registry) | enter the ssm\_parameter path for artifactory\_docker\_registry | `string` | `null` | no |
| <a name="input_ssm_parameter_artifactory_host"></a> [ssm\_parameter\_artifactory\_host](#input\_ssm\_parameter\_artifactory\_host) | enter the ssm\_parameter path for artifactory\_host | `string` | n/a | yes |
| <a name="input_ssm_parameter_sonar_host"></a> [ssm\_parameter\_sonar\_host](#input\_ssm\_parameter\_sonar\_host) | enter the ssm\_parameter path for sonar host | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id\_1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | enter the value of subnet id\_2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | enter the value of subnet id\_3 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes |
| <a name="input_unit_test_commands"></a> [unit\_test\_commands](#input\_unit\_test\_commands) | Default is empty as sonar scan command will be used to run unit tests as well | `string` | `""` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codepipeline_arn"></a> [codepipeline\_arn](#output\_codepipeline\_arn) | The ARN of the CodePipeline |
| <a name="output_codepipeline_id"></a> [codepipeline\_id](#output\_codepipeline\_id) | The ID of the CodePipeline |

<!-- END_TF_DOCS -->