<!-- BEGIN_TF_DOCS -->
# AWS Glue user defined function
Terraform module which creates SAF2.0 glue user defined function in AWS.

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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_glue_user_defined_function.user_defined_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_user_defined_function) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_catalog_id"></a> [catalog\_id](#input\_catalog\_id) | ID of the Glue Catalog to create the function in. If omitted, this defaults to the AWS Account ID | `string` | `null` | no |
| <a name="input_class_name"></a> [class\_name](#input\_class\_name) | The Java class that contains the function code. | `string` | n/a | yes |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | The name of the Database to create the Function. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the function. | `string` | n/a | yes |
| <a name="input_owner_name"></a> [owner\_name](#input\_owner\_name) | The owner of the function. | `string` | n/a | yes |
| <a name="input_owner_type"></a> [owner\_type](#input\_owner\_type) | The owner type. can be one of USER, ROLE, and GROUP | `string` | n/a | yes |
| <a name="input_resource_uris"></a> [resource\_uris](#input\_resource\_uris) | The configuration block for Resource URIs | `list(map(string))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_user_defined_function"></a> [aws\_glue\_user\_defined\_function](#output\_aws\_glue\_user\_defined\_function) | A map of aws\_glue\_user\_defined\_function object. |
| <a name="output_user_defined_function_arn"></a> [user\_defined\_function\_arn](#output\_user\_defined\_function\_arn) | The ARN of the Glue User Defined Function. |
| <a name="output_user_defined_function_create_time"></a> [user\_defined\_function\_create\_time](#output\_user\_defined\_function\_create\_time) | The time at which the function was created. |
| <a name="output_user_defined_function_id"></a> [user\_defined\_function\_id](#output\_user\_defined\_function\_id) | The id of the Glue User Defined Function. |


<!-- END_TF_DOCS -->