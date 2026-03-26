<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker module
# Terraform module which creates Sagemaker flow definition.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.0 |
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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_sagemaker_flow_definition.flow_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_flow_definition) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_flow_definition_name"></a> [flow\_definition\_name](#input\_flow\_definition\_name) | The name of your flow definition | `string` | n/a | yes |
| <a name="input_human_loop_activation_config"></a> [human\_loop\_activation\_config](#input\_human\_loop\_activation\_config) | An object containing information about the events that trigger a human workflow. | `map(any)` | `null` | no |
| <a name="input_human_loop_request_source"></a> [human\_loop\_request\_source](#input\_human\_loop\_request\_source) | Container for configuring the source of human task requests. Use to specify if Amazon Rekognition or Amazon Textract is used as an integration source. Valid values of aws\_managed\_human\_loop\_request\_source are: AWS/Rekognition/DetectModerationLabels/Image/V3 and AWS/Textract/AnalyzeDocument/Forms/V1. | `map(any)` | `null` | no |
| <a name="input_human_task_ui_arn"></a> [human\_task\_ui\_arn](#input\_human\_task\_ui\_arn) | The Amazon Resource Name (ARN) of the human task user interface. | `string` | n/a | yes |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | The Amazon Resource Name (ARN) of the role needed to call other services on your behalf. | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The Amazon Key Management Service (KMS) key ARN for server-side encryption. | `string` | n/a | yes |
| <a name="input_public_workforce_task_price"></a> [public\_workforce\_task\_price](#input\_public\_workforce\_task\_price) | Defines the amount of money paid to an Amazon Mechanical Turk worker for each task performed. Valid value of cents range between 0 and 99. Valid value of dollars range between 0 and 2. Valid value of tenth\_fractions\_of\_a\_cent range between 0 and 9. | `any` | `null` | no |
| <a name="input_s3_output_path"></a> [s3\_output\_path](#input\_s3\_output\_path) | The Amazon S3 path where the object containing human output will be made available. If the user needs to provide some specific folder within the s3 bucket, pass the value like: s3-bucket-name/test-folder. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags | `map(string)` | n/a | yes |
| <a name="input_task_availability_lifetime_in_seconds"></a> [task\_availability\_lifetime\_in\_seconds](#input\_task\_availability\_lifetime\_in\_seconds) | The length of time that a task remains available for review by human workers. Valid value range between 1 and 864000. | `number` | n/a | yes |
| <a name="input_task_count"></a> [task\_count](#input\_task\_count) | The number of distinct workers who will perform the same task on each object. Valid value range between 1 and 3. | `number` | n/a | yes |
| <a name="input_task_description"></a> [task\_description](#input\_task\_description) | A description for the human worker task. | `string` | `null` | no |
| <a name="input_task_keywords"></a> [task\_keywords](#input\_task\_keywords) | An array of keywords used to describe the task so that workers can discover the task. | `list(string)` | `null` | no |
| <a name="input_task_time_limit_in_seconds"></a> [task\_time\_limit\_in\_seconds](#input\_task\_time\_limit\_in\_seconds) | The amount of time that a worker has to complete a task. The default value is 3600 seconds. | `number` | `3600` | no |
| <a name="input_task_title"></a> [task\_title](#input\_task\_title) | A title for the human worker task. | `string` | n/a | yes |
| <a name="input_workteam_arn"></a> [workteam\_arn](#input\_workteam\_arn) | The Amazon Resource Name (ARN) of the human task user interface. Amazon Resource Name (ARN) of a team of workers. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this Flow Definition. |
| <a name="output_id"></a> [id](#output\_id) | The name of the Flow Definition. |
| <a name="output_sagemaker_flow_definition_all"></a> [sagemaker\_flow\_definition\_all](#output\_sagemaker\_flow\_definition\_all) | A map of aws sagemaker flow definition |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource. |

<!-- END_TF_DOCS -->