<!-- BEGIN_TF_DOCS -->
# AWS SSM module
Terraform module which creates SAF2.0 SSM Document in AWS

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

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
| <a name="module_ssm-document"></a> [ssm-document](#module\_ssm-document) | ../../modules/ssm-document | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

No resources.

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
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags. | `map(string)` | `{}` | no |
| <a name="input_ssm_document_format"></a> [ssm\_document\_format](#input\_ssm\_document\_format) | The format of the document. Valid document types include: JSON and YAML | `string` | n/a | yes |
| <a name="input_ssm_document_name"></a> [ssm\_document\_name](#input\_ssm\_document\_name) | SSM document name | `string` | n/a | yes |
| <a name="input_ssm_document_type"></a> [ssm\_document\_type](#input\_ssm\_document\_type) | The type of the document. Valid document types include: Automation, Command, Package, Policy, and Session | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_created_date"></a> [created\_date](#output\_created\_date) | The date the document was created. |
| <a name="output_default_version"></a> [default\_version](#output\_default\_version) | The default version of the document. |
| <a name="output_description"></a> [description](#output\_description) | The description of the SSM document. |
| <a name="output_document_version"></a> [document\_version](#output\_document\_version) | The document version. |
| <a name="output_hash"></a> [hash](#output\_hash) | The sha1 or sha256 of the document content |
| <a name="output_hash_type"></a> [hash\_type](#output\_hash\_type) | The hashing algorithm used when hashing the content. |
| <a name="output_latest_version"></a> [latest\_version](#output\_latest\_version) | The latest version of the document. |
| <a name="output_owner"></a> [owner](#output\_owner) | The AWS user account of the person who created the document. |
| <a name="output_parameter"></a> [parameter](#output\_parameter) | The parameters that are available to this document. |
| <a name="output_platform_types"></a> [platform\_types](#output\_platform\_types) | A list of OS platforms compatible with this SSM document, either 'Windows' or 'Linux'. |
| <a name="output_schema_version"></a> [schema\_version](#output\_schema\_version) | The schema version of the document. |
| <a name="output_status"></a> [status](#output\_status) | The current status of the document. |


<!-- END_TF_DOCS -->