<!-- BEGIN_TF_DOCS -->
# AWS Glue Connection module.
Terraform module which creates SAF2.0 Glue Connection in AWS.

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
| [aws_glue_connection.glue_connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_glue_connection_catalog_id"></a> [glue\_connection\_catalog\_id](#input\_glue\_connection\_catalog\_id) | The ID of the Data Catalog in which to create the connection. If none is supplied, the AWS account ID is used by default. | `string` | `null` | no |
| <a name="input_glue_connection_description"></a> [glue\_connection\_description](#input\_glue\_connection\_description) | Description of the connection. | `string` | `null` | no |
| <a name="input_glue_connection_match_criteria"></a> [glue\_connection\_match\_criteria](#input\_glue\_connection\_match\_criteria) | A list of criteria that can be used in selecting this connection. | `list(string)` | `[]` | no |
| <a name="input_glue_connection_name"></a> [glue\_connection\_name](#input\_glue\_connection\_name) | The name of the connection. | `string` | n/a | yes |
| <a name="input_glue_connection_physical_connection_requirements"></a> [glue\_connection\_physical\_connection\_requirements](#input\_glue\_connection\_physical\_connection\_requirements) | A map of physical connection requirements, such as VPC and SecurityGroup. Defined below. | `list(any)` | `[]` | no |
| <a name="input_glue_connection_properties"></a> [glue\_connection\_properties](#input\_glue\_connection\_properties) | A map of key-value pairs used as parameters for this connection. | `map(string)` | `{}` | no |
| <a name="input_glue_connection_type"></a> [glue\_connection\_type](#input\_glue\_connection\_type) | The type of the connection. Supported are: CUSTOM, JDBC, KAFKA, MARKETPLACE, MONGODB, and NETWORK. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to populate on the created table. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_connection"></a> [aws\_glue\_connection](#output\_aws\_glue\_connection) | A map of aws\_glue\_connection object |
| <a name="output_glue_connection_arn"></a> [glue\_connection\_arn](#output\_glue\_connection\_arn) | The ARN of the Glue Connection. |
| <a name="output_glue_connection_id"></a> [glue\_connection\_id](#output\_glue\_connection\_id) | Catalog ID and name of the connection |
| <a name="output_glue_connection_tags_all"></a> [glue\_connection\_tags\_all](#output\_glue\_connection\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags |


<!-- END_TF_DOCS -->