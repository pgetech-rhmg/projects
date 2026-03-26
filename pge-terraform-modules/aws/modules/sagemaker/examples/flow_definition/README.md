<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker flow definition example

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
| <a name="module_flow_definition"></a> [flow\_definition](#module\_flow\_definition) | ../../modules/flow_definition | n/a |
| <a name="module_flow_definition_role"></a> [flow\_definition\_role](#module\_flow\_definition\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_human_task_ui"></a> [human\_task\_ui](#module\_human\_task\_ui) | ../../modules/human_task_ui | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | app.terraform.io/pgetech/kms/aws | 0.1.2 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | A list of AWS services allowed to assume this role. Required if the trusted\_aws\_principals variable is not provided. | `list(string)` | n/a | yes |
| <a name="input_content"></a> [content](#input\_content) | The content of the Liquid template for the worker user interface. | `string` | n/a | yes |
| <a name="input_human_loop_activation_config"></a> [human\_loop\_activation\_config](#input\_human\_loop\_activation\_config) | An object containing information about the events that trigger a human workflow. | `map(any)` | n/a | yes |
| <a name="input_human_loop_request_source"></a> [human\_loop\_request\_source](#input\_human\_loop\_request\_source) | Container for configuring the source of human task requests. Use to specify if Amazon Rekognition or Amazon Textract is used as an integration source. | `map(any)` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Code Repository (must be unique). | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | A list of managed IAM policies to attach to the IAM role | `list(string)` | n/a | yes |
| <a name="input_task_availability_lifetime_in_seconds"></a> [task\_availability\_lifetime\_in\_seconds](#input\_task\_availability\_lifetime\_in\_seconds) | The length of time that a task remains available for review by human workers. | `number` | n/a | yes |
| <a name="input_task_count"></a> [task\_count](#input\_task\_count) | The number of distinct workers who will perform the same task on each object. | `number` | n/a | yes |
| <a name="input_task_keywords"></a> [task\_keywords](#input\_task\_keywords) | An array of keywords used to describe the task so that workers can discover the task. | `list(string)` | n/a | yes |
| <a name="input_task_time_limit_in_seconds"></a> [task\_time\_limit\_in\_seconds](#input\_task\_time\_limit\_in\_seconds) | The amount of time that a worker has to complete a task. | `number` | n/a | yes |
| <a name="input_task_title"></a> [task\_title](#input\_task\_title) | A title for the human worker task. | `string` | n/a | yes |
| <a name="input_workteam_arn"></a> [workteam\_arn](#input\_workteam\_arn) | The Amazon Resource Name (ARN) of the human task user interface. Amazon Resource Name (ARN) of a team of workers. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_flow_definition_arn"></a> [flow\_definition\_arn](#output\_flow\_definition\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this Flow Definition. |
| <a name="output_flow_definition_id"></a> [flow\_definition\_id](#output\_flow\_definition\_id) | The name of the Flow Definition. |
| <a name="output_flow_definition_tags_all"></a> [flow\_definition\_tags\_all](#output\_flow\_definition\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_human_task_ui_arn"></a> [human\_task\_ui\_arn](#output\_human\_task\_ui\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this Human Task UI. |
| <a name="output_human_task_ui_id"></a> [human\_task\_ui\_id](#output\_human\_task\_ui\_id) | The name of the Human Task UI. |
| <a name="output_human_task_ui_tags_all"></a> [human\_task\_ui\_tags\_all](#output\_human\_task\_ui\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_human_task_ui_template"></a> [human\_task\_ui\_template](#output\_human\_task\_ui\_template) | The Liquid template for the worker user interface. |
| <a name="output_s3_arn"></a> [s3\_arn](#output\_s3\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname |
| <a name="output_s3_bucket"></a> [s3\_bucket](#output\_s3\_bucket) | Map of S3 object |

<!-- END_TF_DOCS -->