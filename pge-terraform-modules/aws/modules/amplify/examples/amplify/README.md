<!-- BEGIN_TF_DOCS -->
# AWS Amplify with usage example
Terraform module which creates SAF2.0 Amplify App resource in AWS.

#### Pre-requisites
1. Create a github repository under pgetech organization to host the
   application code.
2. Push the application code to the main branch of the github repository
   created in step 1.
3. Create environment specific branches in the github repository.
   We are considering DEV, TEST and QA environments for the example
   and hence create github branches DEV, TEST, and QA from main branch.
4. Secrets manager for storing personal access token and basic auth
   credentials must be existing to run this example.

#### AWS Amplify usage example
1. Provide the above created github repository name for
   argument **github\_repository\_name**
2. Setup IAM role to be used as a service role to have permission
   to create and modify amplify resources.
3. Module amplify branch creates Main branch (prod),
   DEV, TEST, and QA (non-prod) branches.
4. Respective environment backend and webhook are configured using
   amplify\_backend\_environment module and amplify\_webhook module.
5. Module amplify\_domain\_association is used to provide domain for
   the example. A domain name is provided in format ending with
   ss.pge.com (main.ss.pge.com) for production and nonprod.pge.com
   (dev.nonprod.pge.com, test.nonprod.pge.com and qa.nonprod.pge.com)
   for non production enviroment. These are not real domain names
   hence the argument **wait\_for\_verification** is set to false so
   that it will not wait for verification on domain to complete.
6. After apply amplify resource is created and build is in queue for
   respective branches.  Manually run these builds in console, this
   will create stack and S3 bucket. Once the build and deploy is
   completed, amplify app endpoint can be accessed using basic auth
   credentials provided in example.
7. Once terraform destroy is run, all the resources are destroyed that
   are created from the terraform code but stack and S3 bucket created
   when build is run, needs to be destroyed manually.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.9 |

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
| <a name="module_amplify_app"></a> [amplify\_app](#module\_amplify\_app) | ../.. | n/a |
| <a name="module_amplify_backend_environment_dev"></a> [amplify\_backend\_environment\_dev](#module\_amplify\_backend\_environment\_dev) | ../../modules/amplify_backend_environment | n/a |
| <a name="module_amplify_backend_environment_main"></a> [amplify\_backend\_environment\_main](#module\_amplify\_backend\_environment\_main) | ../../modules/amplify_backend_environment | n/a |
| <a name="module_amplify_backend_environment_qa"></a> [amplify\_backend\_environment\_qa](#module\_amplify\_backend\_environment\_qa) | ../../modules/amplify_backend_environment | n/a |
| <a name="module_amplify_backend_environment_test"></a> [amplify\_backend\_environment\_test](#module\_amplify\_backend\_environment\_test) | ../../modules/amplify_backend_environment | n/a |
| <a name="module_amplify_branch_dev"></a> [amplify\_branch\_dev](#module\_amplify\_branch\_dev) | ../../modules/amplify_branch | n/a |
| <a name="module_amplify_branch_main"></a> [amplify\_branch\_main](#module\_amplify\_branch\_main) | ../../modules/amplify_branch | n/a |
| <a name="module_amplify_branch_qa"></a> [amplify\_branch\_qa](#module\_amplify\_branch\_qa) | ../../modules/amplify_branch | n/a |
| <a name="module_amplify_branch_test"></a> [amplify\_branch\_test](#module\_amplify\_branch\_test) | ../../modules/amplify_branch | n/a |
| <a name="module_amplify_iam_role"></a> [amplify\_iam\_role](#module\_amplify\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_amplify_webhook_dev"></a> [amplify\_webhook\_dev](#module\_amplify\_webhook\_dev) | ../../modules/amplify_webhook | n/a |
| <a name="module_amplify_webhook_main"></a> [amplify\_webhook\_main](#module\_amplify\_webhook\_main) | ../../modules/amplify_webhook | n/a |
| <a name="module_amplify_webhook_qa"></a> [amplify\_webhook\_qa](#module\_amplify\_webhook\_qa) | ../../modules/amplify_webhook | n/a |
| <a name="module_amplify_webhook_test"></a> [amplify\_webhook\_test](#module\_amplify\_webhook\_test) | ../../modules/amplify_webhook | n/a |
| <a name="module_domain_association_non_prod"></a> [domain\_association\_non\_prod](#module\_domain\_association\_non\_prod) | ../../modules/amplify_domain_association | n/a |
| <a name="module_domain_association_prod"></a> [domain\_association\_prod](#module\_domain\_association\_prod) | ../../modules/amplify_domain_association | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait1_5min](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait2_5min](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

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
| <a name="input_amplify_domain_wait_for_verification"></a> [amplify\_domain\_wait\_for\_verification](#input\_amplify\_domain\_wait\_for\_verification) | If enabled, the resource will wait for the domain association status to change to PENDING\_DEPLOYMENT or AVAILABLE. Setting this to false will skip the process. Default: true. | `bool` | n/a | yes |
| <a name="input_auto_branch_creation_patterns"></a> [auto\_branch\_creation\_patterns](#input\_auto\_branch\_creation\_patterns) | Automated branch creation glob patterns for an Amplify app. | `list(string)` | n/a | yes |
| <a name="input_auto_branch_environment_variables"></a> [auto\_branch\_environment\_variables](#input\_auto\_branch\_environment\_variables) | Environment variables for the autocreated branch. | `map(string)` | n/a | yes |
| <a name="input_auto_branch_framework"></a> [auto\_branch\_framework](#input\_auto\_branch\_framework) | Framework for the autocreated branch. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_build_spec"></a> [build\_spec](#input\_build\_spec) | Build specification (build spec) for the autocreated branch | `string` | n/a | yes |
| <a name="input_custom_rule"></a> [custom\_rule](#input\_custom\_rule) | Custom rewrite and redirect rules for an Amplify app.<br>{<br> condition : Condition for a URL rewrite or redirect rule, such as a country code.<br> source    : Source pattern for a URL rewrite or redirect rule.<br> status    : Status code for a URL rewrite or redirect rule. Valid values: 200, 301, 302, 404, 404-200.<br> target    : Target pattern for a URL rewrite or redirect rule.<br>} | <pre>object({<br>    condition = string<br>    source    = string<br>    status    = string<br>    target    = string<br>  })</pre> | n/a | yes |
| <a name="input_dev_branch_name"></a> [dev\_branch\_name](#input\_dev\_branch\_name) | Name for the branch. | `string` | n/a | yes |
| <a name="input_dev_stage"></a> [dev\_stage](#input\_dev\_stage) | Describes the current stage for the branch. Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL\_REQUEST. | `string` | n/a | yes |
| <a name="input_domain_name_non_prod"></a> [domain\_name\_non\_prod](#input\_domain\_name\_non\_prod) | Domain name for the domain association. | `string` | n/a | yes |
| <a name="input_domain_name_prod"></a> [domain\_name\_prod](#input\_domain\_name\_prod) | Domain name for the domain association. | `string` | n/a | yes |
| <a name="input_enable_auto_branch_creation"></a> [enable\_auto\_branch\_creation](#input\_enable\_auto\_branch\_creation) | Enables automated branch creation for an Amplify app. | `bool` | n/a | yes |
| <a name="input_enable_auto_build"></a> [enable\_auto\_build](#input\_enable\_auto\_build) | Enables auto building for the autocreated branch. | `bool` | n/a | yes |
| <a name="input_enable_branch_auto_build"></a> [enable\_branch\_auto\_build](#input\_enable\_branch\_auto\_build) | Enables auto-building of branches for the Amplify App. | `bool` | n/a | yes |
| <a name="input_enable_performance_mode"></a> [enable\_performance\_mode](#input\_enable\_performance\_mode) | Enables performance mode for the branch. | `bool` | n/a | yes |
| <a name="input_enable_pull_request_preview"></a> [enable\_pull\_request\_preview](#input\_enable\_pull\_request\_preview) | Enables pull request previews for the autocreated branch. | `bool` | n/a | yes |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables map for an Amplify app. | `map(string)` | n/a | yes |
| <a name="input_framework"></a> [framework](#input\_framework) | Framework for the branch. | `string` | n/a | yes |
| <a name="input_github_repository_name"></a> [github\_repository\_name](#input\_github\_repository\_name) | Repository for an Amplify app. The github repository should be created under PGE organization. | `string` | n/a | yes |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | Policy arn for the IAM role. | `list(string)` | n/a | yes |
| <a name="input_main_branch_name"></a> [main\_branch\_name](#input\_main\_branch\_name) | Name for the branch. | `string` | n/a | yes |
| <a name="input_main_stage"></a> [main\_stage](#input\_main\_stage) | Describes the current stage for the branch. Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL\_REQUEST. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name you assign to the amplify resources. It must be unique in your account. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_pull_request_environment_name"></a> [pull\_request\_environment\_name](#input\_pull\_request\_environment\_name) | Amplify environment name for the pull request. | `string` | n/a | yes |
| <a name="input_qa_branch_name"></a> [qa\_branch\_name](#input\_qa\_branch\_name) | Name for the branch. | `string` | n/a | yes |
| <a name="input_qa_stage"></a> [qa\_stage](#input\_qa\_stage) | Describes the current stage for the branch. Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL\_REQUEST. | `string` | n/a | yes |
| <a name="input_role_service"></a> [role\_service](#input\_role\_service) | Aws service for the IAM role. | `list(string)` | n/a | yes |
| <a name="input_secretsmanager_basic_auth_cred_secret_name"></a> [secretsmanager\_basic\_auth\_cred\_secret\_name](#input\_secretsmanager\_basic\_auth\_cred\_secret\_name) | Enter the name of secrets manager for basic auth crentials | `string` | n/a | yes |
| <a name="input_secretsmanager_github_access_token_secret_name"></a> [secretsmanager\_github\_access\_token\_secret\_name](#input\_secretsmanager\_github\_access\_token\_secret\_name) | Enter the name of secrets manager for amplify personal access token. | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Describes the current stage for the autocreated branch. Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL\_REQUEST. | `string` | n/a | yes |
| <a name="input_sub_domain_prefix_dev"></a> [sub\_domain\_prefix\_dev](#input\_sub\_domain\_prefix\_dev) | Prefix setting for the subdomain. | `string` | n/a | yes |
| <a name="input_sub_domain_prefix_main"></a> [sub\_domain\_prefix\_main](#input\_sub\_domain\_prefix\_main) | Prefix setting for the subdomain. | `string` | n/a | yes |
| <a name="input_sub_domain_prefix_qa"></a> [sub\_domain\_prefix\_qa](#input\_sub\_domain\_prefix\_qa) | Prefix setting for the subdomain. | `string` | n/a | yes |
| <a name="input_sub_domain_prefix_test"></a> [sub\_domain\_prefix\_test](#input\_sub\_domain\_prefix\_test) | Prefix setting for the subdomain. | `string` | n/a | yes |
| <a name="input_test_branch_name"></a> [test\_branch\_name](#input\_test\_branch\_name) | Name for the branch. | `string` | n/a | yes |
| <a name="input_test_stage"></a> [test\_stage](#input\_test\_stage) | Describes the current stage for the branch. Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL\_REQUEST. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amplify_app_arn"></a> [amplify\_app\_arn](#output\_amplify\_app\_arn) | ARN of the Amplify app. |
| <a name="output_amplify_app_default_domain"></a> [amplify\_app\_default\_domain](#output\_amplify\_app\_default\_domain) | Default domain for the Amplify app. |
| <a name="output_amplify_app_id"></a> [amplify\_app\_id](#output\_amplify\_app\_id) | Unique ID of the Amplify app. |
| <a name="output_amplify_app_production_branch"></a> [amplify\_app\_production\_branch](#output\_amplify\_app\_production\_branch) | Describes the information about a production branch for an Amplify app. |
| <a name="output_amplify_app_tags_all"></a> [amplify\_app\_tags\_all](#output\_amplify\_app\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->