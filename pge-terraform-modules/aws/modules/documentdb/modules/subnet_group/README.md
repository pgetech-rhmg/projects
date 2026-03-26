<!-- BEGIN_TF_DOCS -->
# AWS DocumentDB Subnet Group
Terraform module which creates SAF2.0 DocumentDB Subnet Group in AWS

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
| [aws_docdb_subnet_group.subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_subnet_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subnet_group_description"></a> [subnet\_group\_description](#input\_subnet\_group\_description) | The description of the docDB subnet group. Defaults to Managed by Terraform. | `string` | `null` | no |
| <a name="input_subnet_group_name"></a> [subnet\_group\_name](#input\_subnet\_group\_name) | The name of the docDB subnet group. | `string` | n/a | yes |
| <a name="input_subnet_group_subnet_ids"></a> [subnet\_group\_subnet\_ids](#input\_subnet\_group\_subnet\_ids) | A list of VPC subnet IDs. Subnet groups must contain at least two subnets in two different Availability Zones in the same AWS Region. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_docdb_subnet_group"></a> [docdb\_subnet\_group](#output\_docdb\_subnet\_group) | The docdb subnet group resource output. |
| <a name="output_docdb_subnet_group_arn"></a> [docdb\_subnet\_group\_arn](#output\_docdb\_subnet\_group\_arn) | The ARN of the docdb subnet group. |
| <a name="output_docdb_subnet_group_id"></a> [docdb\_subnet\_group\_id](#output\_docdb\_subnet\_group\_id) | The docdb subnet group name. |
| <a name="output_docdb_subnet_group_tags_all"></a> [docdb\_subnet\_group\_tags\_all](#output\_docdb\_subnet\_group\_tags\_all) | A map of tags assigned to the resource. |

<!-- END_TF_DOCS -->