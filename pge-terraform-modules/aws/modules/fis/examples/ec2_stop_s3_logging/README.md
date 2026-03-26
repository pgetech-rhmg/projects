<!-- BEGIN_TF_DOCS -->
# AWS FIS experiment template module example - S3 Logging.
Terraform usage example which creates FIS experimental\_template in AWS with S3 logging
When using this module, AWS FIS (Fault Injection Simulator) is a fully managed service
that enables you to perform fault injection experiments on your AWS workloads

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
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

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
| <a name="module_fis_experimental_template"></a> [fis\_experimental\_template](#module\_fis\_experimental\_template) | ../.. | n/a |
| <a name="module_s3_fis_log_bucket"></a> [s3\_fis\_log\_bucket](#module\_s3\_fis\_log\_bucket) | app.terraform.io/pgetech/s3/aws | 0.1.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Application ID from AMPS system in format APP-####. Identifies the application this FIS experiment belongs to. | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score for this FIS experiment. Valid values: High, Medium, Low. | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | List of compliance requirements for this FIS experiment assets (SOX, HIPAA, etc.). Note: NERC workloads are not deployed to cloud. | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Data classification level for this FIS experiment. One of: Public, Internal, Confidential, Restricted, Privileged. | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | Environment in which the FIS experiment resources are provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_LogGroupNamePrefix"></a> [LogGroupNamePrefix](#input\_LogGroupNamePrefix) | Prefix for CloudWatch Log Group names used in this example. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | List of contacts to notify for FIS experiment system failures or maintenance. Should be group names or email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order number tag to be associated with FIS experiment AWS resources. | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List of three owners of this FIS experiment system: AMPS Director, Client Owner, and IT Lead in format LANID1\_LANID2\_LANID3. | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | AWS account ID where this FIS experiment will be deployed. | `string` | `""` | no |
| <a name="input_action"></a> [action](#input\_action) | List of fault injection actions to perform during this S3 logging FIS experiment example. | <pre>list(object({<br/>    name        = string<br/>    action_id   = string<br/>    description = string<br/>    start_after = optional(list(string), [])<br/>    parameter   = optional(map(string), {})<br/>    target = list(object({<br/>      key   = string<br/>      value = string<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where this FIS experiment will be deployed. | `string` | `""` | no |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | The name of the AWS IAM role to assume. | `string` | n/a | yes |
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | List of AWS services that the IAM role will assume. Defaults to ['fis.amazonaws.com'] if not specified. | `list(string)` | `null` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Name of the CloudWatch Log Group to use for FIS experiment logs. Required when log\_type is set to 'cloudwatch'. | `string` | `""` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the FIS experiment template that explains the purpose of this S3 logging example. | `string` | n/a | yes |
| <a name="input_experiment_options"></a> [experiment\_options](#input\_experiment\_options) | Configuration options for this S3 logging FIS experiment, including account targeting and target resolution behavior. | <pre>object({<br/>    account_targeting            = string<br/>    empty_target_resolution_mode = string<br/>  })</pre> | n/a | yes |
| <a name="input_fis_experiment_name"></a> [fis\_experiment\_name](#input\_fis\_experiment\_name) | Name for the Fault Injection experiment, used for easier identification withing FIS. | `string` | n/a | yes |
| <a name="input_fis_role_name"></a> [fis\_role\_name](#input\_fis\_role\_name) | Name of an existing IAM role to use for FIS experiments. If empty, a new role will be created automatically. | `string` | `""` | no |
| <a name="input_inline_policy"></a> [inline\_policy](#input\_inline\_policy) | List of inline IAM policies in JSON format to attach to the FIS role. If empty, the default FIS policy from the root module will be used. | `list(string)` | `[]` | no |
| <a name="input_log_schema_version"></a> [log\_schema\_version](#input\_log\_schema\_version) | Version of the log schema for FIS experiment logs. Supported values: 1 or 2. | `number` | n/a | yes |
| <a name="input_log_type"></a> [log\_type](#input\_log\_type) | Type of logging to use (s3 or cloudwatch). | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the FIS experiment template for this S3 logging example. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags to merge with the default required tags for this example. | `map(string)` | `{}` | no |
| <a name="input_policy_content"></a> [policy\_content](#input\_policy\_content) | Content of the IAM managed policy in JSON format. | `string` | n/a | yes |
| <a name="input_policy_description"></a> [policy\_description](#input\_policy\_description) | Description of the IAM managed policy for this FIS example. | `string` | n/a | yes |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Name of the IAM managed policy for this FIS example. | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Base name for the S3 bucket. Required if log\_type is set to 's3'. | `string` | `""` | no |
| <a name="input_s3_logging"></a> [s3\_logging](#input\_s3\_logging) | Configuration object for S3 logging in this example, including the prefix for log file organization. | <pre>object({<br/>    prefix = string<br/>  })</pre> | <pre>{<br/>  "prefix": ""<br/>}</pre> | no |
| <a name="input_stop_condition"></a> [stop\_condition](#input\_stop\_condition) | List of stop conditions that will halt the FIS experiment if triggered during this S3 logging example. | <pre>list(object({<br/>    source = string<br/>    value  = string<br/>  }))</pre> | n/a | yes |
| <a name="input_target"></a> [target](#input\_target) | List of target resources for the FIS experiment. Defines which AWS resources will be affected by the experiment actions. | <pre>list(object({<br/>    name           = string<br/>    resource_type  = string<br/>    selection_mode = string<br/><br/>    # Optional filter block<br/>    filter = optional(list(object({<br/>      path   = string<br/>      values = list(string)<br/>    })), [])<br/><br/>    # Optional resource ARNs<br/>    resource_arns = optional(list(string), [])<br/><br/>    # Optional parameters<br/>    parameters = optional(map(string), null)<br/><br/>    # Optional resource tags<br/>    resource_tags = optional(list(object({<br/>      key   = string<br/>      value = string<br/>    })), [])<br/>  }))</pre> | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_iam_role"></a> [aws\_iam\_role](#output\_aws\_iam\_role) | Outputs the IAM role resource used for AWS Fault Injection Simulator (FIS) operations. |
| <a name="output_fis_experimental_template"></a> [fis\_experimental\_template](#output\_fis\_experimental\_template) | Outputs the experimental template resource for AWS Fault Injection Simulator (FIS). |
| <a name="output_s3_fis_log_bucket"></a> [s3\_fis\_log\_bucket](#output\_s3\_fis\_log\_bucket) | Outputs the S3 bucket resource used for storing logs related to AWS Fault Injection Simulator (FIS). |

<!-- END_TF_DOCS -->