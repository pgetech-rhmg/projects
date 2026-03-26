<!-- BEGIN_TF_DOCS -->
# AWS FIS experiment template module example - CloudWatch Logging.
Terraform usage example which creates FIS experimental\_template in AWS with CloudWatch logging
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.23.0 |

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
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Application ID from AMPS system. Format: APP-#### (e.g., APP-1234). Required for PGE compliance. | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score for PGE compliance. Valid values: High, Medium, Low. Required for PGE compliance. | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | List of compliance requirements that apply to this FIS experiment (e.g., SOX, HIPAA). Required for PGE compliance, but can be empty list if no specific compliance applies. | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Data classification level for PGE compliance. Valid values: Public, Internal, Confidential, Restricted, Privileged. Required for PGE compliance. | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | Environment where this FIS experiment will run. Valid values: Dev, Test, QA, Prod. Required for PGE compliance. | `string` | n/a | yes |
| <a name="input_LogGroupNamePrefix"></a> [LogGroupNamePrefix](#input\_LogGroupNamePrefix) | Prefix for CloudWatch Log Group names created for FIS experiment logging. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | List of email addresses or groups to notify for system failures or maintenance related to this FIS experiment. Required for PGE compliance. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order number for tracking and billing purposes. Required for PGE compliance as a resource tag. | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List of three system owners as defined by AMPS: Director, Client Owner, and IT Lead. Format: LANID1\_LANID2\_LANID3. Required for PGE compliance. | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | AWS account ID where this FIS experiment will be deployed. | `string` | `""` | no |
| <a name="input_action"></a> [action](#input\_action) | List of actions for the FIS experiment template demonstrating EC2 stop with CloudWatch logging. | <pre>list(object({<br/>    name        = string<br/>    action_id   = string<br/>    description = string<br/>    start_after = optional(list(string), [])<br/>    parameter   = optional(map(string), {})<br/>    target = list(object({<br/>      key   = string<br/>      value = string<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where this FIS experiment will be deployed. | `string` | `""` | no |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | Name of the AWS IAM role to assume for FIS experiment execution in this CloudWatch logging example. | `string` | n/a | yes |
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | List of AWS services that the IAM role will assume trust for. Default includes fis.amazonaws.com for FIS experiments. | `list(string)` | `null` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Name of the CloudWatch Log Group for FIS experiment logs. Required when log\_type is set to 'cloudwatch'. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the FIS experiment template demonstrating EC2 stop action with CloudWatch logging. | `string` | n/a | yes |
| <a name="input_experiment_options"></a> [experiment\_options](#input\_experiment\_options) | Options for the FIS experiment template in this CloudWatch logging example, including account targeting and empty target resolution. | <pre>object({<br/>    account_targeting            = string<br/>    empty_target_resolution_mode = string<br/>  })</pre> | n/a | yes |
| <a name="input_fis_experiment_name"></a> [fis\_experiment\_name](#input\_fis\_experiment\_name) | Name for the Fault Injection experiment, used for easier identification withing FIS. | `string` | n/a | yes |
| <a name="input_fis_role_name"></a> [fis\_role\_name](#input\_fis\_role\_name) | Name of the existing IAM role to use for FIS experiments. If empty, a new role will be created. | `string` | `""` | no |
| <a name="input_inline_policy"></a> [inline\_policy](#input\_inline\_policy) | List of inline IAM policies in JSON format to attach to the FIS role. When specified, these policies are used instead of the default FIS policy from the root module. | `list(string)` | `[]` | no |
| <a name="input_log_schema_version"></a> [log\_schema\_version](#input\_log\_schema\_version) | Version of the log schema for FIS experiment logs. Supported values: 1 or 2. | `number` | `1` | no |
| <a name="input_log_type"></a> [log\_type](#input\_log\_type) | Type of logging to use for FIS experiment results. Valid values: s3, cloudwatch. This example demonstrates cloudwatch logging. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the FIS experiment template for this CloudWatch logging example. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags to merge with the required PGE compliance tags for this CloudWatch logging example. | `map(string)` | `{}` | no |
| <a name="input_policy_content"></a> [policy\_content](#input\_policy\_content) | Content of the IAM policy in JSON format. If empty, the default FIS policy template will be used with CloudWatch logging permissions. | `string` | `""` | no |
| <a name="input_policy_description"></a> [policy\_description](#input\_policy\_description) | Description of the IAM managed policy that will be created for the FIS role in this CloudWatch logging example. | `string` | n/a | yes |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Name of the IAM managed policy that will be created for the FIS role. | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Base name for the S3 bucket for FIS logging. Required when log\_type is set to 's3', not used in this CloudWatch example. | `string` | `""` | no |
| <a name="input_s3_logging"></a> [s3\_logging](#input\_s3\_logging) | Configuration object for S3 logging (not used in this CloudWatch logging example but required for module compatibility). | <pre>object({<br/>    prefix = string<br/>  })</pre> | <pre>{<br/>  "prefix": ""<br/>}</pre> | no |
| <a name="input_stop_condition"></a> [stop\_condition](#input\_stop\_condition) | List of stop conditions for the FIS experiment template in this CloudWatch logging example. | <pre>list(object({<br/>    source = string<br/>    value  = string<br/>  }))</pre> | n/a | yes |
| <a name="input_target"></a> [target](#input\_target) | List of target resources for the FIS experiment. Defines which AWS resources will be affected by the experiment actions. | <pre>list(object({<br/>    name           = string<br/>    resource_type  = string<br/>    selection_mode = string<br/><br/>    # Optional filter block<br/>    filter = optional(list(object({<br/>      path   = string<br/>      values = list(string)<br/>    })), [])<br/><br/>    # Optional resource ARNs<br/>    resource_arns = optional(list(string), [])<br/><br/>    # Optional parameters<br/>    parameters = optional(map(string), null)<br/><br/>    # Optional resource tags<br/>    resource_tags = optional(list(object({<br/>      key   = string<br/>      value = string<br/>    })), [])<br/>  }))</pre> | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_iam_role"></a> [aws\_iam\_role](#output\_aws\_iam\_role) | Outputs the IAM role resource used for AWS Fault Injection Simulator (FIS) operations. |
| <a name="output_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#output\_cloudwatch\_log\_group) | Outputs the CloudWatch Log Group created for FIS experiment logging. |
| <a name="output_fis_experimental_template"></a> [fis\_experimental\_template](#output\_fis\_experimental\_template) | Outputs the experimental template resource for AWS Fault Injection Simulator (FIS). |

<!-- END_TF_DOCS -->