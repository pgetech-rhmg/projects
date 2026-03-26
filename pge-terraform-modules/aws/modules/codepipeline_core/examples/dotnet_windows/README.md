<!-- BEGIN_TF_DOCS -->
# AWS codepipeline dotnet User module example
# Prerequisites : In the variable 'ssm\_parameter\_github\_oauth\_token', 'artifact\_version' , 'project\_name', 'project\_root\_directory', 'dotnet\_version', 'github\_branch', 'project\_unit\_test\_dir', 'project\_file\_location', 'artifact\_name\_dotnet' and 'github\_repo\_url' Provide the suitable values respectively for testing.
# Code verified using terraform validate and terraform fmt -check.
# Known Issue: The secret manager VPC endpoint configured in the SecureByDesign AWS account is not denying the call to secret manager and hence we made some adjustments in the VPC endpoint policy and enabled "Allow all" in the policy temporarily to make the connection to secret manager work.

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
| <a name="module_codedeploy_app_ec2"></a> [codedeploy\_app\_ec2](#module\_codedeploy\_app\_ec2) | app.terraform.io/pgetech/codedeploy/aws | 0.1.0 |
| <a name="module_codedeploy_deployment_group"></a> [codedeploy\_deployment\_group](#module\_codedeploy\_deployment\_group) | app.terraform.io/pgetech/codedeploy/aws//modules/deployment_group | 0.1.1 |
| <a name="module_codepipeline"></a> [codepipeline](#module\_codepipeline) | ../../modules/dotnet | n/a |
| <a name="module_codepipeline_iam_role"></a> [codepipeline\_iam\_role](#module\_codepipeline\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.0 |
| <a name="module_codepipeline_internal_gh_webhook"></a> [codepipeline\_internal\_gh\_webhook](#module\_codepipeline\_internal\_gh\_webhook) | app.terraform.io/pgetech/codepipeline_internal/aws//modules/gh_webhook | 0.1.5 |
| <a name="module_ec2_windows"></a> [ec2\_windows](#module\_ec2\_windows) | app.terraform.io/pgetech/ec2/aws//modules/pge_windows | 0.1.2 |
| <a name="module_iam_policy"></a> [iam\_policy](#module\_iam\_policy) | app.terraform.io/pgetech/iam/aws//modules/iam_policy | 0.1.0 |
| <a name="module_iam_role_codedeploy"></a> [iam\_role\_codedeploy](#module\_iam\_role\_codedeploy) | app.terraform.io/pgetech/iam/aws | 0.1.0 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.0 |
| <a name="module_security_group_EC2"></a> [security\_group\_EC2](#module\_security\_group\_EC2) | app.terraform.io/pgetech/security-group/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_pet.cp_random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.allow_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.github_token_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssm_parameter.artifactory_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.artifactory_repo_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.golden_ami_windows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
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
| <a name="input_artifact_bucket_owner_access"></a> [artifact\_bucket\_owner\_access](#input\_artifact\_bucket\_owner\_access) | Enter the artifact bucket owner access | `string` | n/a | yes |
| <a name="input_artifact_name_dotnet"></a> [artifact\_name\_dotnet](#input\_artifact\_name\_dotnet) | Enter the name of artifact | `string` | n/a | yes |
| <a name="input_artifact_path"></a> [artifact\_path](#input\_artifact\_path) | Enter the path to store artifact - S3 | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_branch"></a> [branch](#input\_branch) | Branch of the GitHub repository, e.g 'master | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Bucket name for codepipeline | `string` | n/a | yes |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | variables for security\_group\_project | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_cidr_egress_rules_ec2"></a> [cidr\_egress\_rules\_ec2](#input\_cidr\_egress\_rules\_ec2) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_cidr_ingress_rules_ec2"></a> [cidr\_ingress\_rules\_ec2](#input\_cidr\_ingress\_rules\_ec2) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_codebuild_role_service"></a> [codebuild\_role\_service](#input\_codebuild\_role\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_codedeploy_app_name"></a> [codedeploy\_app\_name](#input\_codedeploy\_app\_name) | The name of the application. | `string` | n/a | yes |
| <a name="input_codedeploy_role_service"></a> [codedeploy\_role\_service](#input\_codedeploy\_role\_service) | A list of AWS services allowed to assume this role.  Required if the aws\_accounts variable is not provided. | `list(string)` | n/a | yes |
| <a name="input_codepipeline_name"></a> [codepipeline\_name](#input\_codepipeline\_name) | The name of the pipeline. | `string` | n/a | yes |
| <a name="input_codepipeline_role_service"></a> [codepipeline\_role\_service](#input\_codepipeline\_role\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_compute_type_codebuild"></a> [compute\_type\_codebuild](#input\_compute\_type\_codebuild) | Information about the compute resources the build project will use in codebuild project | `string` | n/a | yes |
| <a name="input_compute_type_codepublish"></a> [compute\_type\_codepublish](#input\_compute\_type\_codepublish) | Information about the compute resources the build project will use in codepublish project | `string` | n/a | yes |
| <a name="input_compute_type_codescan"></a> [compute\_type\_codescan](#input\_compute\_type\_codescan) | Information about the compute resources the build project will use in codescan project | `string` | n/a | yes |
| <a name="input_concurrent_build_limit_codebuild"></a> [concurrent\_build\_limit\_codebuild](#input\_concurrent\_build\_limit\_codebuild) | Maximum number of concurrent builds for the project in codebuild project | `number` | n/a | yes |
| <a name="input_concurrent_build_limit_codepublish"></a> [concurrent\_build\_limit\_codepublish](#input\_concurrent\_build\_limit\_codepublish) | Maximum number of concurrent builds for the codepublish project | `number` | n/a | yes |
| <a name="input_concurrent_build_limit_codescan"></a> [concurrent\_build\_limit\_codescan](#input\_concurrent\_build\_limit\_codescan) | Maximum number of concurrent builds for the codescan project | `number` | n/a | yes |
| <a name="input_custom_codebuild_policy_file"></a> [custom\_codebuild\_policy\_file](#input\_custom\_codebuild\_policy\_file) | add custom codebuild policy file for codebuild project, if needed | `string` | `null` | no |
| <a name="input_custom_codepublish_policy_file"></a> [custom\_codepublish\_policy\_file](#input\_custom\_codepublish\_policy\_file) | add custom codepublish policy file for codebuild project, if needed | `string` | `null` | no |
| <a name="input_custom_codescan_policy_file"></a> [custom\_codescan\_policy\_file](#input\_custom\_codescan\_policy\_file) | add custom codescan policy file for codebuild project, if needed | `string` | `null` | no |
| <a name="input_deployment_option"></a> [deployment\_option](#input\_deployment\_option) | CodeDeploy Deployment Option Indicates whether to route deployment traffic behind a load balancer,Possible values: WITH\_TRAFFIC\_CONTROL, WITHOUT\_TRAFFIC\_CONTROL. | `string` | n/a | yes |
| <a name="input_deployment_tag_key"></a> [deployment\_tag\_key](#input\_deployment\_tag\_key) | CodeDeploy Deployment Tag Key | `string` | n/a | yes |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | CodeDeploy Deployment Type | `string` | `"IN_PLACE"` | no |
| <a name="input_dotnet_version"></a> [dotnet\_version](#input\_dotnet\_version) | Enter the dotnet version value | `string` | n/a | yes |
| <a name="input_ec2_az"></a> [ec2\_az](#input\_ec2\_az) | Availability Zone of the EC2 | `string` | n/a | yes |
| <a name="input_ec2_instance_type_windows"></a> [ec2\_instance\_type\_windows](#input\_ec2\_instance\_type\_windows) | Instance type of the Windows ec2 instance (requires more memory than Linux) | `string` | `"t3.xlarge"` | no |
| <a name="input_ec2_name"></a> [ec2\_name](#input\_ec2\_name) | The name for ec2 instance | `string` | n/a | yes |
| <a name="input_enable_windows_build"></a> [enable\_windows\_build](#input\_enable\_windows\_build) | Enable Windows build environment for .NET projects | `bool` | `true` | no |
| <a name="input_environment_image_codebuild_windows"></a> [environment\_image\_codebuild\_windows](#input\_environment\_image\_codebuild\_windows) | Docker image to use for Windows codebuild project. Use Windows Server 2019 base image for .NET builds. | `string` | `"aws/codebuild/windows-base:2019-3.0"` | no |
| <a name="input_environment_image_codedownload_windows"></a> [environment\_image\_codedownload\_windows](#input\_environment\_image\_codedownload\_windows) | Docker image to use for Windows codedownload project. Use Windows Server 2019 base image for .NET builds. | `string` | `"aws/codebuild/windows-base:2019-3.0"` | no |
| <a name="input_environment_image_codepublish_windows"></a> [environment\_image\_codepublish\_windows](#input\_environment\_image\_codepublish\_windows) | Docker image to use for Windows codepublish project. Use Windows Server 2019 base image for .NET builds. | `string` | `"aws/codebuild/windows-base:2019-3.0"` | no |
| <a name="input_environment_image_codescan_windows"></a> [environment\_image\_codescan\_windows](#input\_environment\_image\_codescan\_windows) | Docker image to use for Windows codescan project. Use Windows Server 2019 base image for .NET builds. | `string` | `"aws/codebuild/windows-base:2019-3.0"` | no |
| <a name="input_github_branch"></a> [github\_branch](#input\_github\_branch) | Enter the value of github repo branch | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | Github organization name of the repository, pgetech, DigitalCatalyst, etc | `string` | n/a | yes |
| <a name="input_github_repo_url"></a> [github\_repo\_url](#input\_github\_repo\_url) | Enter the github repo url for environment variable used in buildspec yml | `string` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console. | `string` | `"Parameter Store KMS master key"` | no |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | KMS key name for customer managed key encryption | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_metadata_http_endpoint"></a> [metadata\_http\_endpoint](#input\_metadata\_http\_endpoint) | Whether the metadata service is available. Valid values include enabled or disabled | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_project_file"></a> [project\_file](#input\_project\_file) | The path to the project file for the build process. | `string` | n/a | yes |
| <a name="input_project_key"></a> [project\_key](#input\_project\_key) | A unique identifier of your project inside SonarQube | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The display name visible in SonarQube dashboard. Example: My Project | `string` | n/a | yes |
| <a name="input_project_root_directory"></a> [project\_root\_directory](#input\_project\_root\_directory) | Enter the project root directory value | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Github repository name of the application to be built | `string` | n/a | yes |
| <a name="input_root_block_device_throughput"></a> [root\_block\_device\_throughput](#input\_root\_block\_device\_throughput) | Throughput of the root block device | `number` | n/a | yes |
| <a name="input_root_block_device_volume_size"></a> [root\_block\_device\_volume\_size](#input\_root\_block\_device\_volume\_size) | Volume size of the root block device | `number` | n/a | yes |
| <a name="input_root_block_device_volume_type"></a> [root\_block\_device\_volume\_type](#input\_root\_block\_device\_volume\_type) | Volume type of the root block device | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_token"></a> [secretsmanager\_artifactory\_token](#input\_secretsmanager\_artifactory\_token) | Enter the name of jfrog artifactory token stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_user"></a> [secretsmanager\_artifactory\_user](#input\_secretsmanager\_artifactory\_user) | Enter the name of jfrog artifactory user stored in secrets manager | `string` | n/a | yes |
| <a name="input_secretsmanager_github_token_secret_name"></a> [secretsmanager\_github\_token\_secret\_name](#input\_secretsmanager\_github\_token\_secret\_name) | secret manager path of the github OAUTH or PAT | `string` | n/a | yes |
| <a name="input_secretsmanager_sonar_token"></a> [secretsmanager\_sonar\_token](#input\_secretsmanager\_sonar\_token) | Enter the token value of SonarQube stored in secrets manager | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | vpc id for security group | `string` | n/a | yes |
| <a name="input_sg_description_ec2"></a> [sg\_description\_ec2](#input\_sg\_description\_ec2) | Security group for example usage with EFS | `string` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | name of the security group | `string` | n/a | yes |
| <a name="input_sg_name_ec2"></a> [sg\_name\_ec2](#input\_sg\_name\_ec2) | Name of the security group for EC2 configuration | `string` | n/a | yes |
| <a name="input_source_location_codebuild"></a> [source\_location\_codebuild](#input\_source\_location\_codebuild) | Location of the source code from git or s3 to build codescan project. | `string` | n/a | yes |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | The source type for the pipeline (GitHub or S3) | `string` | `"GitHub"` | no |
| <a name="input_ssm_parameter_artifactory_host"></a> [ssm\_parameter\_artifactory\_host](#input\_ssm\_parameter\_artifactory\_host) | Enter the name of jfrog artifactory host stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_artifactory_repo_key"></a> [ssm\_parameter\_artifactory\_repo\_key](#input\_ssm\_parameter\_artifactory\_repo\_key) | Enter the name of JFrog npm Artifactory repo key to use in Terraform CodePipeline to pull the npm dependencies | `string` | n/a | yes |
| <a name="input_ssm_parameter_golden_ami_windows_name"></a> [ssm\_parameter\_golden\_ami\_windows\_name](#input\_ssm\_parameter\_golden\_ami\_windows\_name) | The name given in parameter store for the Windows golden ami | `string` | `"/ami/windows/golden"` | no |
| <a name="input_ssm_parameter_sonar_host"></a> [ssm\_parameter\_sonar\_host](#input\_ssm\_parameter\_sonar\_host) | Enter the host value of SonarQube stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id\_1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | enter the value of subnet id\_2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | enter the value of subnet id\_3 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes |
| <a name="input_unit_test_commands"></a> [unit\_test\_commands](#input\_unit\_test\_commands) | Enter the unit test commands for python webapp | `string` | n/a | yes |
| <a name="input_windows_environment_type"></a> [windows\_environment\_type](#input\_windows\_environment\_type) | Type of Windows build environment container for Windows builds | `string` | `"WINDOWS_SERVER_2019_CONTAINER"` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codepipeline_arn"></a> [codepipeline\_arn](#output\_codepipeline\_arn) | The codepipeline ARN |
| <a name="output_codepipeline_bucket"></a> [codepipeline\_bucket](#output\_codepipeline\_bucket) | codepipeline bucket name |
| <a name="output_codepipeline_iam_role"></a> [codepipeline\_iam\_role](#output\_codepipeline\_iam\_role) | Map of IAM Role object |
| <a name="output_codepipeline_iam_role_arn"></a> [codepipeline\_iam\_role\_arn](#output\_codepipeline\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the role |
| <a name="output_codepipeline_iam_role_name"></a> [codepipeline\_iam\_role\_name](#output\_codepipeline\_iam\_role\_name) | The name of the IAM role created |
| <a name="output_codepipeline_id"></a> [codepipeline\_id](#output\_codepipeline\_id) | The codepipeline ID |
| <a name="output_s3_arn"></a> [s3\_arn](#output\_s3\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname |
| <a name="output_s3_id"></a> [s3\_id](#output\_s3\_id) | The name of the bucket |

<!-- END_TF_DOCS -->