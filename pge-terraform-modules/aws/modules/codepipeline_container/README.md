<!-- BEGIN_TF_DOCS -->
# AWS codepipeline example for codepipeline dockerimages
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.33.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.1 |

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
| <a name="module_codebuild_iam_role"></a> [codebuild\_iam\_role](#module\_codebuild\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_codebuild_project"></a> [codebuild\_project](#module\_codebuild\_project) | app.terraform.io/pgetech/codebuild/aws | 0.1.29 |
| <a name="module_codepipeline_internal_codestar_notifications"></a> [codepipeline\_internal\_codestar\_notifications](#module\_codepipeline\_internal\_codestar\_notifications) | app.terraform.io/pgetech/codepipeline_internal/aws//modules/codestar_notifications | 0.1.0 |
| <a name="module_security-group"></a> [security-group](#module\_security-group) | app.terraform.io/pgetech/security-group/aws | 0.1.1 |
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
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
| <a name="input_artifact_bucket_owner_access"></a> [artifact\_bucket\_owner\_access](#input\_artifact\_bucket\_owner\_access) | Enter the artifact bucket owner access | `string` | n/a | yes |
| <a name="input_artifact_path"></a> [artifact\_path](#input\_artifact\_path) | Enter the path to store artifact - S3 | `string` | n/a | yes |
| <a name="input_artifact_store_location_bucket"></a> [artifact\_store\_location\_bucket](#input\_artifact\_store\_location\_bucket) | The location where AWS CodePipeline stores artifacts for a pipeline; currently only S3 is supported. | `string` | n/a | yes |
| <a name="input_artifact_store_region"></a> [artifact\_store\_region](#input\_artifact\_store\_region) | The region where the artifact store is located. Required for a cross-region CodePipeline, do not provide for a single-region CodePipeline. | `string` | `null` | no |
| <a name="input_branch"></a> [branch](#input\_branch) | Branch of the GitHub repository, e.g 'master | `string` | n/a | yes |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | variables for security\_group\_project | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_cidr_egress_rules_SNS_codestar"></a> [cidr\_egress\_rules\_SNS\_codestar](#input\_cidr\_egress\_rules\_SNS\_codestar) | egress rule for codestar | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "description": "CCOE egress rules",<br/>    "from": 0,<br/>    "ipv6_cidr_blocks": [],<br/>    "prefix_list_ids": [],<br/>    "protocol": "-1",<br/>    "to": 0<br/>  }<br/>]</pre> | no |
| <a name="input_codebuild_role_service"></a> [codebuild\_role\_service](#input\_codebuild\_role\_service) | Aws service of the iam role | `list(string)` | <pre>[<br/>  "codebuild.amazonaws.com"<br/>]</pre> | no |
| <a name="input_codepipeline_name"></a> [codepipeline\_name](#input\_codepipeline\_name) | The name of the pipeline. | `string` | n/a | yes |
| <a name="input_compute_type_codebuild"></a> [compute\_type\_codebuild](#input\_compute\_type\_codebuild) | Information about the compute resources the build project will use in codebuild project | `string` | n/a | yes |
| <a name="input_concurrent_build_limit_codebuild"></a> [concurrent\_build\_limit\_codebuild](#input\_concurrent\_build\_limit\_codebuild) | Maximum number of concurrent builds for the codebuild project | `number` | n/a | yes |
| <a name="input_custom_codebuild_policy_file"></a> [custom\_codebuild\_policy\_file](#input\_custom\_codebuild\_policy\_file) | add custom codebuild policy file for codebuild project, if needed | `string` | `null` | no |
| <a name="input_encryption_key_id"></a> [encryption\_key\_id](#input\_encryption\_key\_id) | The KMS key ARN or ID for artifact store | `string` | `null` | no |
| <a name="input_endpoint_email"></a> [endpoint\_email](#input\_endpoint\_email) | Endpoint to send data to. The contents vary with the protocol | `list(string)` | `null` | no |
| <a name="input_environment_image_codebuild"></a> [environment\_image\_codebuild](#input\_environment\_image\_codebuild) | Docker image to use for this codebuild project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | n/a | yes |
| <a name="input_environment_type_codebuild"></a> [environment\_type\_codebuild](#input\_environment\_type\_codebuild) | Type of build environment to use for codebuild project related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | n/a | yes |
| <a name="input_environment_variables_codebuild_stage"></a> [environment\_variables\_codebuild\_stage](#input\_environment\_variables\_codebuild\_stage) | Provide the list of environment variables required for codebuild stage | `list(any)` | `[]` | no |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | Github organization name of the repository, pgetech, DigitalCatalyst, etc | `string` | n/a | yes |
| <a name="input_pollchanges"></a> [pollchanges](#input\_pollchanges) | Periodically check the location of your source content and run the pipeline if changes are detected, this uses Codepipeline Polling. default to false to use webhook | `string` | `"false"` | no |
| <a name="input_privileged_mode_codebuild"></a> [privileged\_mode\_codebuild](#input\_privileged\_mode\_codebuild) | Whether to enable running the Docker daemon inside a Docker container | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | Region of pipeline stages | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Github repository name of the application to be built | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | A service role Amazon Resource Name (ARN) that grants AWS CodePipeline permission to make calls to AWS services on your behalf. | `string` | n/a | yes |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | The location where AWS CodePipeline pulls artifacts for a pipeline | `string` | `""` | no |
| <a name="input_s3_object_key"></a> [s3\_object\_key](#input\_s3\_object\_key) | The S3 object key for the source artifact (e.g., source.zip) | `string` | `""` | no |
| <a name="input_secretsmanager_github_token_secret_name"></a> [secretsmanager\_github\_token\_secret\_name](#input\_secretsmanager\_github\_token\_secret\_name) | secret manager path of the github OAUTH or PAT | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | vpc id for security group | `string` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | name of the security group | `string` | n/a | yes |
| <a name="input_source_buildspec_codebuild"></a> [source\_buildspec\_codebuild](#input\_source\_buildspec\_codebuild) | Enter the codebuild buildspec | `string` | n/a | yes |
| <a name="input_source_location_codebuild"></a> [source\_location\_codebuild](#input\_source\_location\_codebuild) | Location of the source code from git or s3 for codebuild. | `string` | n/a | yes |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | The source type for the pipeline (GitHub or S3) | `string` | `"GitHub"` | no |
| <a name="input_stages"></a> [stages](#input\_stages) | Further stages after publish stage can be added in dynamic block. Dynamic stage is also optional when no values is provided in tfvars | `list(any)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs within which to run builds. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | enter the vpc id within which to run builds. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codepipeline_all"></a> [codepipeline\_all](#output\_codepipeline\_all) | Map of Codepipeline object |
| <a name="output_codepipeline_arn"></a> [codepipeline\_arn](#output\_codepipeline\_arn) | The codepipeline ARN |
| <a name="output_codepipeline_id"></a> [codepipeline\_id](#output\_codepipeline\_id) | The codepipeline ID |
| <a name="output_codepipeline_tags_all"></a> [codepipeline\_tags\_all](#output\_codepipeline\_tags\_all) | A map of tags assigned to the resource |

<!-- END_TF_DOCS -->
