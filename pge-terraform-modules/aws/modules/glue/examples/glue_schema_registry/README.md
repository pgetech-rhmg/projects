<!-- BEGIN_TF_DOCS -->
# AWS GLUE with usage example
Terraform module which creates SAF2.0 Glue schema and Glue registry resources in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
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
| <a name="module_glue_registry"></a> [glue\_registry](#module\_glue\_registry) | ../../../glue/modules/glue-registry | n/a |
| <a name="module_glue_schema"></a> [glue\_schema](#module\_glue\_schema) | ../../../glue/modules/glue_schema | n/a |
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
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_glue_compatibility"></a> [glue\_compatibility](#input\_glue\_compatibility) | The compatibility mode of the schema. Values values are: NONE, DISABLED, BACKWARD, BACKWARD\_ALL, FORWARD, FORWARD\_ALL, FULL, and FULL\_ALL. | `string` | n/a | yes |
| <a name="input_glue_data_format"></a> [glue\_data\_format](#input\_glue\_data\_format) | The data format of the schema definition. Valid values are AVRO, JSON and PROTOBUF. | `string` | n/a | yes |
| <a name="input_glue_schema_definition"></a> [glue\_schema\_definition](#input\_glue\_schema\_definition) | The schema definition using the data\_format setting for schema\_name. | `string` | n/a | yes |
| <a name="input_glue_schema_name"></a> [glue\_schema\_name](#input\_glue\_schema\_name) | The Name of the schema. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A common name for resources. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_glue_latest_schema_version"></a> [glue\_latest\_schema\_version](#output\_glue\_latest\_schema\_version) | The latest version of the schema associated with the returned schema definition. |
| <a name="output_glue_next_schema_version"></a> [glue\_next\_schema\_version](#output\_glue\_next\_schema\_version) | The next version of the schema associated with the returned schema definition. |
| <a name="output_glue_registry_arn"></a> [glue\_registry\_arn](#output\_glue\_registry\_arn) | Amazon Resource Name (ARN) of Glue Registry. |
| <a name="output_glue_registry_id"></a> [glue\_registry\_id](#output\_glue\_registry\_id) | Amazon Resource Name (ARN) of Glue Registry. |
| <a name="output_glue_registry_name"></a> [glue\_registry\_name](#output\_glue\_registry\_name) | The name of the Glue Registry. |
| <a name="output_glue_registry_tags_all"></a> [glue\_registry\_tags\_all](#output\_glue\_registry\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_glue_schema_arn"></a> [glue\_schema\_arn](#output\_glue\_schema\_arn) | Amazon Resource Name (ARN) of the schema. |
| <a name="output_glue_schema_checkpoint"></a> [glue\_schema\_checkpoint](#output\_glue\_schema\_checkpoint) | The version number of the checkpoint (the last time the compatibility mode was changed). |
| <a name="output_glue_schema_id"></a> [glue\_schema\_id](#output\_glue\_schema\_id) | Amazon Resource Name (ARN) of the schema. |
| <a name="output_glue_schema_tags_all"></a> [glue\_schema\_tags\_all](#output\_glue\_schema\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->