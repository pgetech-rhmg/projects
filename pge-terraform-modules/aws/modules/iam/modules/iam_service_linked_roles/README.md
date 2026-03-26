<!-- BEGIN_TF_DOCS -->
# AWS IAM SLR module
Terraform module which creates SAF2.0 IAM Service Linked Roles in AWS

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
| [aws_iam_service_linked_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_service_names"></a> [aws\_service\_names](#input\_aws\_service\_names) | List of AWS Service Names for which service-linked roles will be created | `set(string)` | n/a | yes |
| <a name="input_custom_suffix"></a> [custom\_suffix](#input\_custom\_suffix) | (Optional, forces new resource) Additional string appended to the role name. Not all AWS services support custom suffixes | `string` | `""` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the role | `string` | `"IAM Role created by pge_team = ccoe-tf-developers"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) specifying the role |
| <a name="output_create_date"></a> [create\_date](#output\_create\_date) | The creation date of the IAM role. |
| <a name="output_description"></a> [description](#output\_description) | The description of the role. |
| <a name="output_iam_service_linked_roles"></a> [iam\_service\_linked\_roles](#output\_iam\_service\_linked\_roles) | Map of IAM Service-linked role objects |
| <a name="output_id"></a> [id](#output\_id) | The Amazon Resource Name (ARN) of the role. |
| <a name="output_name"></a> [name](#output\_name) | The name of the IAM role created |
| <a name="output_path"></a> [path](#output\_path) | The path of the role in IAM |

<!-- END_TF_DOCS -->