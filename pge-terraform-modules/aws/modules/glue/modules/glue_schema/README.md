<!-- BEGIN_TF_DOCS -->
# AWS Glue schema module.
Terraform module which creates SAF2.0 Glue Schema in AWS.

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
| [aws_glue_schema.glue_schema](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_schema) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_glue_compatibility"></a> [glue\_compatibility](#input\_glue\_compatibility) | The compatibility mode of the schema. Values values are: NONE, DISABLED, BACKWARD, BACKWARD\_ALL, FORWARD, FORWARD\_ALL, FULL, and FULL\_ALL. | `string` | n/a | yes |
| <a name="input_glue_data_format"></a> [glue\_data\_format](#input\_glue\_data\_format) | The data format of the schema definition. Valid values are AVRO, JSON and PROTOBUF. | `string` | n/a | yes |
| <a name="input_glue_registry_arn"></a> [glue\_registry\_arn](#input\_glue\_registry\_arn) | The ARN of the Glue Registry to create the schema in. | `string` | n/a | yes |
| <a name="input_glue_schema_definition"></a> [glue\_schema\_definition](#input\_glue\_schema\_definition) | The schema definition using the data\_format setting for schema\_name. | `string` | n/a | yes |
| <a name="input_glue_schema_description"></a> [glue\_schema\_description](#input\_glue\_schema\_description) | A description of the schema. | `string` | `null` | no |
| <a name="input_glue_schema_name"></a> [glue\_schema\_name](#input\_glue\_schema\_name) | The Name of the schema. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_schema"></a> [aws\_glue\_schema](#output\_aws\_glue\_schema) | A map of aws\_glue\_schema object. |
| <a name="output_glue_latest_schema_version"></a> [glue\_latest\_schema\_version](#output\_glue\_latest\_schema\_version) | The latest version of the schema associated with the returned schema definition. |
| <a name="output_glue_next_schema_version"></a> [glue\_next\_schema\_version](#output\_glue\_next\_schema\_version) | The next version of the schema associated with the returned schema definition. |
| <a name="output_glue_registry_name"></a> [glue\_registry\_name](#output\_glue\_registry\_name) | The name of the Glue Registry. |
| <a name="output_glue_schema_arn"></a> [glue\_schema\_arn](#output\_glue\_schema\_arn) | Amazon Resource Name (ARN) of the schema. |
| <a name="output_glue_schema_checkpoint"></a> [glue\_schema\_checkpoint](#output\_glue\_schema\_checkpoint) | The version number of the checkpoint (the last time the compatibility mode was changed). |
| <a name="output_glue_schema_id"></a> [glue\_schema\_id](#output\_glue\_schema\_id) | Amazon Resource Name (ARN) of the schema. |
| <a name="output_glue_schema_tags_all"></a> [glue\_schema\_tags\_all](#output\_glue\_schema\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->