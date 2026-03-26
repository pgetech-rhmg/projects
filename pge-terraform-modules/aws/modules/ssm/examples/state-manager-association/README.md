<!-- BEGIN_TF_DOCS -->
# AWS SSM module
Terraform module which creates SAF2.0 SSM State Manager Association in AWS

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

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
| <a name="module_aws_document_iam_role"></a> [aws\_document\_iam\_role](#module\_aws\_document\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_aws_sns_iam_role"></a> [aws\_sns\_iam\_role](#module\_aws\_sns\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_document_s3"></a> [document\_s3](#module\_document\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_lambda_iam_role"></a> [lambda\_iam\_role](#module\_lambda\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_security-group"></a> [security-group](#module\_security-group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_sns_topic"></a> [sns\_topic](#module\_sns\_topic) | app.terraform.io/pgetech/sns/aws | 0.1.1 |
| <a name="module_sns_topic_subscription"></a> [sns\_topic\_subscription](#module\_sns\_topic\_subscription) | app.terraform.io/pgetech/sns/aws//modules/sns_subscription | 0.1.1 |
| <a name="module_ssm-document"></a> [ssm-document](#module\_ssm-document) | ../../modules/ssm-document | n/a |
| <a name="module_ssm-patch-manager-baseline"></a> [ssm-patch-manager-baseline](#module\_ssm-patch-manager-baseline) | ../../modules/patch-manager-baseline | n/a |
| <a name="module_ssm_association"></a> [ssm\_association](#module\_ssm\_association) | ../../modules/state-manager-association | n/a |
| <a name="module_statemanager-s3"></a> [statemanager-s3](#module\_statemanager-s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_object.object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_iam_policy_document.iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.inline_policy_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
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
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory. | `string` | n/a | yes |
| <a name="input_apply_only_at_cron_interval"></a> [apply\_only\_at\_cron\_interval](#input\_apply\_only\_at\_cron\_interval) | when you create a new or update associations, the system runs it immediately and then according to the schedule you specified. Enable this option if you do not want an association to run immediately after you create or update it. This parameter is not supported for rate expressions. Default: false. | `bool` | `false` | no |
| <a name="input_approved_patches_compliance_level"></a> [approved\_patches\_compliance\_level](#input\_approved\_patches\_compliance\_level) | Defines the compliance level for approved patches. This means that if an approved patch is reported as missing, this is the severity of the compliance violation. Valid compliance levels include the following: CRITICAL, HIGH, MEDIUM, LOW, INFORMATIONAL, UNSPECIFIED. The default value is UNSPECIFIED. | `string` | n/a | yes |
| <a name="input_aws_org_id"></a> [aws\_org\_id](#input\_aws\_org\_id) | The AWS ORG ID | `string` | `"o-7vgpdbu22o"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume. | `string` | n/a | yes |
| <a name="input_cidr_egress_rules_codebuild"></a> [cidr\_egress\_rules\_codebuild](#input\_cidr\_egress\_rules\_codebuild) | vairables for codebuild security group | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_document_bucket_name"></a> [document\_bucket\_name](#input\_document\_bucket\_name) | s3 bucket for document | `string` | n/a | yes |
| <a name="input_document_iam_aws_service"></a> [document\_iam\_aws\_service](#input\_document\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_document_iam_name"></a> [document\_iam\_name](#input\_document\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Endpoint to send data to. The contents vary with the protocol | `list(string)` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console. | `string` | n/a | yes |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | The KMS key to encrypt data in store. | `string` | n/a | yes |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | Name of the Lambda role | `string` | n/a | yes |
| <a name="input_lambda_iam_name"></a> [lambda\_iam\_name](#input\_lambda\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_max_concurrency"></a> [max\_concurrency](#input\_max\_concurrency) | Input max\_concurrency in either number or percentage | `string` | `"20%"` | no |
| <a name="input_operating_system"></a> [operating\_system](#input\_operating\_system) | Defines the operating system the patch baseline applies to. Supported operating systems include WINDOWS, AMAZON\_LINUX, AMAZON\_LINUX\_2, SUSE, UBUNTU, CENTOS, and REDHAT\_ENTERPRISE\_LINUX. The Default value is WINDOWS. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags. | `map(string)` | `{}` | no |
| <a name="input_output_s3_key_prefix"></a> [output\_s3\_key\_prefix](#input\_output\_s3\_key\_prefix) | The Amazon S3 bucket subfolder | `string` | n/a | yes |
| <a name="input_patch_baseline_approval_rules"></a> [patch\_baseline\_approval\_rules](#input\_patch\_baseline\_approval\_rules) | A set of rules used to include patches in the baseline. Up to 10 approval rules can be specified. Each `approval_rule` block requires the fields documented below. | `list(any)` | n/a | yes |
| <a name="input_patch_group_names"></a> [patch\_group\_names](#input\_patch\_group\_names) | The targets to register with the maintenance window. In other words, the instances to run commands on when the maintenance window runs. You can specify targets using instance IDs, resource group names, or tags that have been applied to instances. | `list(string)` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application | `string` | n/a | yes |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | SSM association schedule expression | `string` | n/a | yes |
| <a name="input_set_default_patch_baseline"></a> [set\_default\_patch\_baseline](#input\_set\_default\_patch\_baseline) | whether to set this baseline as a Default Patch Baseline | `bool` | n/a | yes |
| <a name="input_sns_iam_aws_service"></a> [sns\_iam\_aws\_service](#input\_sns\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_sns_iam_name"></a> [sns\_iam\_name](#input\_sns\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_snstopic_display_name"></a> [snstopic\_display\_name](#input\_snstopic\_display\_name) | The display name of the SNS topic | `string` | n/a | yes |
| <a name="input_snstopic_name"></a> [snstopic\_name](#input\_snstopic\_name) | name of the SNS topic | `string` | n/a | yes |
| <a name="input_ssm_association_name"></a> [ssm\_association\_name](#input\_ssm\_association\_name) | SSM association name | `string` | n/a | yes |
| <a name="input_ssm_document_format"></a> [ssm\_document\_format](#input\_ssm\_document\_format) | The format of the document. Valid document types include: JSON and YAML | `string` | n/a | yes |
| <a name="input_ssm_document_name"></a> [ssm\_document\_name](#input\_ssm\_document\_name) | SSM document name | `string` | n/a | yes |
| <a name="input_ssm_document_type"></a> [ssm\_document\_type](#input\_ssm\_document\_type) | The type of the document. Valid document types include: Automation, Command, Package, Policy, and Session | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id\_1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_patch_baseline_name"></a> [ssm\_patch\_baseline\_name](#input\_ssm\_patch\_baseline\_name) | The name of the patch baseline | `string` | n/a | yes |
| <a name="input_statemanager_s3_bucket"></a> [statemanager\_s3\_bucket](#input\_statemanager\_s3\_bucket) | S3 bucket for SSM document parameter | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_version"></a> [default\_version](#output\_default\_version) | The default version of the document. |
| <a name="output_document_version"></a> [document\_version](#output\_document\_version) | The document version. |
| <a name="output_owner"></a> [owner](#output\_owner) | The AWS user account of the person who created the document. |
| <a name="output_patch_baseline_all"></a> [patch\_baseline\_all](#output\_patch\_baseline\_all) | The patch baseline all. |
| <a name="output_platform_types"></a> [platform\_types](#output\_platform\_types) | A list of OS platforms compatible with this SSM document, either 'Windows' or 'Linux'. |
| <a name="output_schema_version"></a> [schema\_version](#output\_schema\_version) | The schema version of the document. |
| <a name="output_ssm_state_association_id"></a> [ssm\_state\_association\_id](#output\_ssm\_state\_association\_id) | The document version. |
| <a name="output_ssm_state_association_s3_bucket"></a> [ssm\_state\_association\_s3\_bucket](#output\_ssm\_state\_association\_s3\_bucket) | The document version. |


<!-- END_TF_DOCS -->