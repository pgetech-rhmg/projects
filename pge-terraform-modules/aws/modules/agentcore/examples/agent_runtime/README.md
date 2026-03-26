<!-- BEGIN_TF_DOCS -->
AWS Bedrock AgentCore Module

This module provisions an AWS Bedrock AgentCore Runtime with optional memory and strategy configurations.
It also sets up necessary resources such as ECR repositories for container images, KMS keys for encryption, and security groups for network access. * Source can be found at https://github.com/pgetech/pge-terraform-modules

Source can be found at https://github.com/pgetech/pge-terraform-modules
To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

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
| <a name="module_bedrock_agent_runtime"></a> [bedrock\_agent\_runtime](#module\_bedrock\_agent\_runtime) | ../../modules/runtime/ | n/a |
| <a name="module_codepipeline"></a> [codepipeline](#module\_codepipeline) | app.terraform.io/pgetech/codepipeline-container/aws | 0.1.0 |
| <a name="module_codepipeline_iam_role"></a> [codepipeline\_iam\_role](#module\_codepipeline\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | app.terraform.io/pgetech/ecr/aws | 0.1.3 |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | app.terraform.io/pgetech/kms/aws | 0.1.2 |
| <a name="module_s3_ci"></a> [s3\_ci](#module\_s3\_ci) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_bedrockagentcore_memory.agent_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagentcore_memory) | resource |
| [aws_bedrockagentcore_memory_strategy.semantic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagentcore_memory_strategy) | resource |
| [aws_bedrockagentcore_memory_strategy.summarization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagentcore_memory_strategy) | resource |
| [aws_bedrockagentcore_memory_strategy.user_preference](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagentcore_memory_strategy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ci_allow_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecr_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
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
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | The AWS account number where resources will be created. | `string` | `"064160142714"` | no |
| <a name="input_agent_foundation_model"></a> [agent\_foundation\_model](#input\_agent\_foundation\_model) | The foundation model to use for the Bedrock Agent. | `string` | `"anthropic.claude-3-5-sonnet-20241022-v2:0"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region where resources will be created. | `string` | `"us-west-2"` | no |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | The AWS IAM role to assume for resource creation. | `string` | `"CloudAdmin"` | no |
| <a name="input_ci_branch"></a> [ci\_branch](#input\_ci\_branch) | The git branch to build. | `string` | `"main"` | no |
| <a name="input_ci_compute_type"></a> [ci\_compute\_type](#input\_ci\_compute\_type) | The AWS CodeBuild compute type to use for CI builds. | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_ci_github_secret"></a> [ci\_github\_secret](#input\_ci\_github\_secret) | The name of the AWS Secrets Manager secret containing the GitHub token. | `string` | n/a | yes |
| <a name="input_ci_image"></a> [ci\_image](#input\_ci\_image) | The AWS CodeBuild image to use for CI builds. | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:5.0"` | no |
| <a name="input_ci_logs_bucket_name"></a> [ci\_logs\_bucket\_name](#input\_ci\_logs\_bucket\_name) | The name of the S3 bucket to store CodeBuild logs. | `string` | `"pge-bedrock-agent-ci-logs-bucket"` | no |
| <a name="input_create_memory"></a> [create\_memory](#input\_create\_memory) | Whether to create memory for the agent. | `bool` | `false` | no |
| <a name="input_create_runtime"></a> [create\_runtime](#input\_create\_runtime) | Whether to create the Bedrock Agent Runtime. | `bool` | `true` | no |
| <a name="input_create_runtime_endpoint"></a> [create\_runtime\_endpoint](#input\_create\_runtime\_endpoint) | Whether to create the runtime endpoint. | `bool` | `true` | no |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | The ARN of the KMS key | `string` | `null` | no |
| <a name="input_memory_description"></a> [memory\_description](#input\_memory\_description) | Description for the memory resource. | `string` | `""` | no |
| <a name="input_memory_dynamodb_read_capacity_units"></a> [memory\_dynamodb\_read\_capacity\_units](#input\_memory\_dynamodb\_read\_capacity\_units) | Read capacity units for DynamoDB. | `number` | `5` | no |
| <a name="input_memory_dynamodb_table_name"></a> [memory\_dynamodb\_table\_name](#input\_memory\_dynamodb\_table\_name) | DynamoDB table name for memory. | `string` | `""` | no |
| <a name="input_memory_dynamodb_write_capacity_units"></a> [memory\_dynamodb\_write\_capacity\_units](#input\_memory\_dynamodb\_write\_capacity\_units) | Write capacity units for DynamoDB. | `number` | `5` | no |
| <a name="input_memory_name"></a> [memory\_name](#input\_memory\_name) | Name for the memory resource. | `string` | `""` | no |
| <a name="input_memory_tags"></a> [memory\_tags](#input\_memory\_tags) | Tags for memory resources. | `map(string)` | `{}` | no |
| <a name="input_memory_type"></a> [memory\_type](#input\_memory\_type) | Type of memory (DYNAMODB). | `string` | `"DYNAMODB"` | no |
| <a name="input_parameter_subnet_id1_name"></a> [parameter\_subnet\_id1\_name](#input\_parameter\_subnet\_id1\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | `""` | no |
| <a name="input_parameter_subnet_id2_name"></a> [parameter\_subnet\_id2\_name](#input\_parameter\_subnet\_id2\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | `""` | no |
| <a name="input_parameter_subnet_id3_name"></a> [parameter\_subnet\_id3\_name](#input\_parameter\_subnet\_id3\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | n/a | yes |
| <a name="input_parameter_vpc_id_name"></a> [parameter\_vpc\_id\_name](#input\_parameter\_vpc\_id\_name) | Id of vpc stored in aws\_ssm\_parameter | `string` | `""` | no |
| <a name="input_repo_url"></a> [repo\_url](#input\_repo\_url) | The URL of the Git repository for the CodeBuild project. | `string` | n/a | yes |
| <a name="input_runtime_artifact_type"></a> [runtime\_artifact\_type](#input\_runtime\_artifact\_type) | The artifact type for the runtime (container or code). | `string` | `"container"` | no |
| <a name="input_runtime_code_runtime_type"></a> [runtime\_code\_runtime\_type](#input\_runtime\_code\_runtime\_type) | The runtime type for code-based runtimes. | `string` | `"PYTHON_3_13"` | no |
| <a name="input_runtime_container_uri"></a> [runtime\_container\_uri](#input\_runtime\_container\_uri) | The URI of the container image for the Bedrock Agent Runtime. | `string` | `"064160142714.dkr.ecr.us-west-2.amazonaws.com/bedrock/agent-runtime-76ab0c91:latest"` | no |
| <a name="input_runtime_description"></a> [runtime\_description](#input\_runtime\_description) | Description for the Bedrock Agent Runtime. | `string` | `"Bedrock Agent Runtime"` | no |
| <a name="input_runtime_endpoint_description"></a> [runtime\_endpoint\_description](#input\_runtime\_endpoint\_description) | Description for the runtime endpoint. | `string` | `"Bedrock Agent Runtime Endpoint"` | no |
| <a name="input_runtime_endpoint_name"></a> [runtime\_endpoint\_name](#input\_runtime\_endpoint\_name) | Name for the runtime endpoint. | `string` | `"bedrock-runtime-endpoint"` | no |
| <a name="input_runtime_endpoint_tags"></a> [runtime\_endpoint\_tags](#input\_runtime\_endpoint\_tags) | Tags for the runtime endpoint. | `map(string)` | `{}` | no |
| <a name="input_runtime_environment_variables"></a> [runtime\_environment\_variables](#input\_runtime\_environment\_variables) | Environment variables for the runtime. | `map(string)` | `{}` | no |
| <a name="input_runtime_module_source"></a> [runtime\_module\_source](#input\_runtime\_module\_source) | The source path for the Bedrock Agent Runtime module. | `string` | `"../../modules/runtime/"` | no |
| <a name="input_runtime_name"></a> [runtime\_name](#input\_runtime\_name) | The name prefix for resources. | `string` | `"ccoe_bedrock_agent"` | no |
| <a name="input_runtime_tags"></a> [runtime\_tags](#input\_runtime\_tags) | Tags for the runtime. | `map(string)` | `{}` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_runtime_arn"></a> [agent\_runtime\_arn](#output\_agent\_runtime\_arn) | ARN of the created Bedrock Agent Runtime |
| <a name="output_agent_runtime_endpoint_arn"></a> [agent\_runtime\_endpoint\_arn](#output\_agent\_runtime\_endpoint\_arn) | ARN of the created Bedrock Agent Runtime Endpoint |
| <a name="output_agent_runtime_endpoint_id"></a> [agent\_runtime\_endpoint\_id](#output\_agent\_runtime\_endpoint\_id) | ID of the created Bedrock Agent Runtime Endpoint |
| <a name="output_agent_runtime_endpoint_status"></a> [agent\_runtime\_endpoint\_status](#output\_agent\_runtime\_endpoint\_status) | Status of the created Bedrock Agent Runtime Endpoint |
| <a name="output_agent_runtime_id"></a> [agent\_runtime\_id](#output\_agent\_runtime\_id) | ID of the created Bedrock Agent Runtime |
| <a name="output_memory_arn"></a> [memory\_arn](#output\_memory\_arn) | ARN of the AgentCore memory |
| <a name="output_memory_id"></a> [memory\_id](#output\_memory\_id) | ID of the AgentCore memory |
| <a name="output_semantic_strategy_id"></a> [semantic\_strategy\_id](#output\_semantic\_strategy\_id) | ID of the semantic memory strategy |
| <a name="output_summary_strategy_id"></a> [summary\_strategy\_id](#output\_summary\_strategy\_id) | ID of the summarization memory strategy |
| <a name="output_user_preference_strategy_id"></a> [user\_preference\_strategy\_id](#output\_user\_preference\_strategy\_id) | ID of the user preference memory strategy |

<!-- END_TF_DOCS -->