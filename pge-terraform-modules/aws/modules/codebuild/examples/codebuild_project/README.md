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

# AWS codebuild project User module example

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

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
| <a name="module_aws_iam_role"></a> [aws\_iam\_role](#module\_aws\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_codebuild_project"></a> [codebuild\_project](#module\_codebuild\_project) | ../.. | n/a |
| <a name="module_github_webhook"></a> [github\_webhook](#module\_github\_webhook) | ../../modules/github_repository_webhook | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.0 |
| <a name="module_security_group_project"></a> [security\_group\_project](#module\_security\_group\_project) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_pet.cb_random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
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
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_artifact_type"></a> [artifact\_type](#input\_artifact\_type) | Build output artifact's type | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the S3 bucket | `string` | n/a | yes |
| <a name="input_cache_type"></a> [cache\_type](#input\_cache\_type) | Type of storage that will be used for the AWS CodeBuild project cache | `string` | n/a | yes |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | variables for security\_group\_project | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_cloudwatch_logs_group_name"></a> [cloudwatch\_logs\_group\_name](#input\_cloudwatch\_logs\_group\_name) | Name of the S3 bucket and the path prefix for S3 logs | `string` | n/a | yes |
| <a name="input_cloudwatch_logs_stream_name"></a> [cloudwatch\_logs\_stream\_name](#input\_cloudwatch\_logs\_stream\_name) | Name of the S3 bucket and the path prefix for S3 logs | `string` | n/a | yes |
| <a name="input_codebuild_project_description"></a> [codebuild\_project\_description](#input\_codebuild\_project\_description) | Short description of the project | `string` | n/a | yes |
| <a name="input_codebuild_project_name"></a> [codebuild\_project\_name](#input\_codebuild\_project\_name) | The name of Project | `string` | n/a | yes |
| <a name="input_compute_type"></a> [compute\_type](#input\_compute\_type) | Information about the compute resources the build project will use | `string` | n/a | yes |
| <a name="input_concurrent_build_limit"></a> [concurrent\_build\_limit](#input\_concurrent\_build\_limit) | Maximum number of concurrent builds for the project | `number` | n/a | yes |
| <a name="input_environment_image"></a> [environment\_image](#input\_environment\_image) | Docker image to use for this build project | `string` | n/a | yes |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | Type of build environment to use for related builds | `string` | n/a | yes |
| <a name="input_github_base_url"></a> [github\_base\_url](#input\_github\_base\_url) | GitHub target API endpoint | `string` | n/a | yes |
| <a name="input_github_content_type"></a> [github\_content\_type](#input\_github\_content\_type) | The content type for the payload | `string` | n/a | yes |
| <a name="input_github_events"></a> [github\_events](#input\_github\_events) | Indicate if the webhook should receive events | `list(string)` | n/a | yes |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | The repository of the webhook | `string` | n/a | yes |
| <a name="input_image_pull_credentials_type"></a> [image\_pull\_credentials\_type](#input\_image\_pull\_credentials\_type) | Type of credentials AWS CodeBuild uses to pull images in your build | `string` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console | `string` | n/a | yes |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_policy_file_name"></a> [policy\_file\_name](#input\_policy\_file\_name) | Valid JSON document representing a resource policy | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_role_service"></a> [role\_service](#input\_role\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_s3_logs_status"></a> [s3\_logs\_status](#input\_s3\_logs\_status) | Current status of logs in S3 for a build project | `string` | n/a | yes |
| <a name="input_secretsmanager_github_token_secret_arn"></a> [secretsmanager\_github\_token\_secret\_arn](#input\_secretsmanager\_github\_token\_secret\_arn) | ARN of the GitHub Secrets Manager containing the OAUTH or PAT | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | vpc id for security group | `string` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | name of the security group | `string` | n/a | yes |
| <a name="input_source_fetch_sub"></a> [source\_fetch\_sub](#input\_source\_fetch\_sub) | Whether to fetch Git submodules for the AWS CodeBuild build project | `bool` | n/a | yes |
| <a name="input_source_git_clone_depth"></a> [source\_git\_clone\_depth](#input\_source\_git\_clone\_depth) | Truncate git history to this many commits | `number` | n/a | yes |
| <a name="input_source_location"></a> [source\_location](#input\_source\_location) | Location of the source code from git or s3 | `string` | n/a | yes |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | Type of repository that contains the source code to be built | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codebuild_project_arn"></a> [codebuild\_project\_arn](#output\_codebuild\_project\_arn) | ARN of the CodeBuild project |
| <a name="output_codebuild_project_badge_url"></a> [codebuild\_project\_badge\_url](#output\_codebuild\_project\_badge\_url) | URL of the build badge when badge\_enabled is enabled |
| <a name="output_codebuild_project_id"></a> [codebuild\_project\_id](#output\_codebuild\_project\_id) | Name or ARN of the CodeBuild project |
| <a name="output_codebuild_project_project_alias"></a> [codebuild\_project\_project\_alias](#output\_codebuild\_project\_project\_alias) | The project identifier used with the public build APIs |
| <a name="output_codebuild_project_tags_all"></a> [codebuild\_project\_tags\_all](#output\_codebuild\_project\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |
| <a name="output_codebuild_webhook_payload_url"></a> [codebuild\_webhook\_payload\_url](#output\_codebuild\_webhook\_payload\_url) | The CodeBuild endpoint where webhook events are sent |
| <a name="output_codebuild_webhook_url"></a> [codebuild\_webhook\_url](#output\_codebuild\_webhook\_url) | The URL to the webhook |

<!-- END_TF_DOCS -->