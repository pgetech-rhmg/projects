<!-- BEGIN_TF_DOCS -->
# AWS SSM module
Terraform module which creates SAF2.0 SSM-Document in AWS

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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_document.ssm_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ssm_document_attachments_source"></a> [ssm\_document\_attachments\_source](#input\_ssm\_document\_attachments\_source) | One or more configuration blocks describing attachments sources to a version of a document. | <pre>list(object({<br>    key : string<br>    values : list(string)<br>    name : string<br>  }))</pre> | `[]` | no |
| <a name="input_ssm_document_content"></a> [ssm\_document\_content](#input\_ssm\_document\_content) | The JSON or YAML content of the document. | `string` | n/a | yes |
| <a name="input_ssm_document_format"></a> [ssm\_document\_format](#input\_ssm\_document\_format) | The format of the document. Valid document types include: JSON and YAML | `string` | `"JSON"` | no |
| <a name="input_ssm_document_name"></a> [ssm\_document\_name](#input\_ssm\_document\_name) | SSM document name | `string` | n/a | yes |
| <a name="input_ssm_document_permissions"></a> [ssm\_document\_permissions](#input\_ssm\_document\_permissions) | Additional Permissions to attach to the document. The permissions attribute specifies how you want to share the document. | `map(string)` | `{}` | no |
| <a name="input_ssm_document_target_type"></a> [ssm\_document\_target\_type](#input\_ssm\_document\_target\_type) | The target type which defines the kinds of resources the document can run on. For example, /AWS::EC2::Instance. | `string` | `null` | no |
| <a name="input_ssm_document_type"></a> [ssm\_document\_type](#input\_ssm\_document\_type) | The type of the document. Valid document types include: Automation, Command, Package, Policy, and Session | `string` | `"Command"` | no |
| <a name="input_ssm_document_version_name"></a> [ssm\_document\_version\_name](#input\_ssm\_document\_version\_name) | A field specifying the version of the artifact you are creating with the document. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_created_date"></a> [created\_date](#output\_created\_date) | The date the document was created. |
| <a name="output_default_version"></a> [default\_version](#output\_default\_version) | The default version of the document. |
| <a name="output_description"></a> [description](#output\_description) | The description of the SSM document. |
| <a name="output_document_version"></a> [document\_version](#output\_document\_version) | The document version. |
| <a name="output_hash"></a> [hash](#output\_hash) | The sha1 or sha256 of the document content |
| <a name="output_hash_type"></a> [hash\_type](#output\_hash\_type) | The hashing algorithm used when hashing the content. |
| <a name="output_id"></a> [id](#output\_id) | The default version of the document. |
| <a name="output_latest_version"></a> [latest\_version](#output\_latest\_version) | The latest version of the document. |
| <a name="output_owner"></a> [owner](#output\_owner) | The AWS user account of the person who created the document. |
| <a name="output_parameter"></a> [parameter](#output\_parameter) | The parameters that are available to this document. |
| <a name="output_platform_types"></a> [platform\_types](#output\_platform\_types) | A list of OS platforms compatible with this SSM document, either 'Windows' or 'Linux'. |
| <a name="output_schema_version"></a> [schema\_version](#output\_schema\_version) | The schema version of the document. |
| <a name="output_ssm_document_all"></a> [ssm\_document\_all](#output\_ssm\_document\_all) | The map of all atributes |
| <a name="output_status"></a> [status](#output\_status) | The current status of the document. |


<!-- END_TF_DOCS -->