<!-- BEGIN_TF_DOCS -->


 Source can be found at https://github.com/pgetech/pge-terraform-modules

 To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

 ## Requirements

 Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

 ## Usage

 Usage information can be found in `modules/examples/*`

 `cd pge-terraform-modules/modules/examples/*`

 `terraform init`

 `terraform validate`

 `terraform plan`

 `terraform apply`

 Run `terraform destroy` when you don't need these resources.
|

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_imagebuilder_component.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_component) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_change_description"></a> [change\_description](#input\_change\_description) | description of changes since last version | `string` | `null` | no |
| <a name="input_component_data"></a> [component\_data](#input\_component\_data) | Map of component data that can either contain file path or data URI | `map(string)` | `{}` | no |
| <a name="input_component_kms_key_id"></a> [component\_kms\_key\_id](#input\_component\_kms\_key\_id) | KMS key to use for encryption | `string` | `null` | no |
| <a name="input_component_name_prefix"></a> [component\_name\_prefix](#input\_component\_name\_prefix) | name prefix of the component | `string` | n/a | yes |
| <a name="input_component_platform"></a> [component\_platform](#input\_component\_platform) | platform of component(Linux or Windows) | `string` | `"Linux"` | no |
| <a name="input_component_version"></a> [component\_version](#input\_component\_version) | version of the component | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | description of component | `string` | `null` | no |
| <a name="input_supported_os_versions"></a> [supported\_os\_versions](#input\_supported\_os\_versions) | Aset of operating system versions supported by the component. If the os information is available, a prefix match is performed against  base image os version during image recipe creation. | `set(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to use for CFN stack and component | `map(string)` | `{}` | no |


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_component_arns"></a> [component\_arns](#output\_component\_arns) | List of the component ARNs |
| <a name="output_component_names"></a> [component\_names](#output\_component\_names) | List of the component names |