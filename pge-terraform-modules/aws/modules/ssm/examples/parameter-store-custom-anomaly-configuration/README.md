<!-- BEGIN_TF_DOCS -->
# AWS SSM module
Terraform module which creates SAF2.0 parameters in SSM parameter-store in AWS

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
| <a name="module_custom_email_address"></a> [custom\_email\_address](#module\_custom\_email\_address) | ../../ | n/a |
| <a name="module_custom_threshold"></a> [custom\_threshold](#module\_custom\_threshold) | ../../ | n/a |
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
| <a name="input_custom_email_address_value"></a> [custom\_email\_address\_value](#input\_custom\_email\_address\_value) | Value of the parameter. This value is always marked as sensitive in the Terraform plan output, regardless of type. | `string` | n/a | yes |
| <a name="input_custom_threshold_value"></a> [custom\_threshold\_value](#input\_custom\_threshold\_value) | Value of the parameter. This value is always marked as sensitive in the Terraform plan output, regardless of type. | `number` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_email_address_arn"></a> [custom\_email\_address\_arn](#output\_custom\_email\_address\_arn) | ARN of the ssm parameter. |
| <a name="output_custom_email_address_name"></a> [custom\_email\_address\_name](#output\_custom\_email\_address\_name) | Name of the ssm parameter. |
| <a name="output_custom_email_address_type"></a> [custom\_email\_address\_type](#output\_custom\_email\_address\_type) | Type of the ssm parameter. |
| <a name="output_custom_email_address_version"></a> [custom\_email\_address\_version](#output\_custom\_email\_address\_version) | Version of the ssm parameter. |
| <a name="output_custom_threshold_arn"></a> [custom\_threshold\_arn](#output\_custom\_threshold\_arn) | ARN of the ssm parameter. |
| <a name="output_custom_threshold_name"></a> [custom\_threshold\_name](#output\_custom\_threshold\_name) | Name of the ssm parameter. |
| <a name="output_custom_threshold_type"></a> [custom\_threshold\_type](#output\_custom\_threshold\_type) | Type of the ssm parameter. |
| <a name="output_custom_threshold_version"></a> [custom\_threshold\_version](#output\_custom\_threshold\_version) | Version of the ssm parameter. |


<!-- END_TF_DOCS -->