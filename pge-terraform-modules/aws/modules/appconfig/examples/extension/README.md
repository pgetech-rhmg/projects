<!-- BEGIN_TF_DOCS -->
# AWS AppConfig User module example

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
| <a name="module_extension"></a> [extension](#module\_extension) | ../../modules/extension | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_action_description"></a> [action\_description](#input\_action\_description) | Information about the action. | `string` | n/a | yes |
| <a name="input_action_name"></a> [action\_name](#input\_action\_name) | The action name | `string` | n/a | yes |
| <a name="input_action_point"></a> [action\_point](#input\_action\_point) | The point at which to perform the defined actions. | `string` | n/a | yes |
| <a name="input_action_role"></a> [action\_role](#input\_action\_role) | The role to assume. | `string` | n/a | yes |
| <a name="input_action_uri"></a> [action\_uri](#input\_action\_uri) | The extension URI associated to the action point in the extension definition. Can be ARN for Lambda function, SQS queue, SNS topic, or EventBridge default event bus. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Information about the extension. | `string` | n/a | yes |
| <a name="input_enable_extension_association"></a> [enable\_extension\_association](#input\_enable\_extension\_association) | Specifies if extension association is to be enabled or not. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | A name for the extension. Each extension name in your account must be unique. | `string` | n/a | yes |
| <a name="input_parameter_description"></a> [parameter\_description](#input\_parameter\_description) | Information about the parameter. | `string` | n/a | yes |
| <a name="input_parameter_name"></a> [parameter\_name](#input\_parameter\_name) | A name for the parameter. | `string` | n/a | yes |
| <a name="input_parameter_required"></a> [parameter\_required](#input\_parameter\_required) | Determines if a parameter value must be specified in the extension association. | `string` | n/a | yes |
| <a name="input_resource_arn_to_associate_with_extension"></a> [resource\_arn\_to\_associate\_with\_extension](#input\_resource\_arn\_to\_associate\_with\_extension) | The Amazon Resource Name (ARN) of the resource to associate with the AppConfig Extension. | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | AppConfig Extension ARN |
| <a name="output_id"></a> [id](#output\_id) | AppConfig Extension ID |
| <a name="output_version"></a> [version](#output\_version) | The version number for the extension. |

<!-- END_TF_DOCS -->