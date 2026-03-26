<!-- BEGIN_TF_DOCS -->
AWS DocumentDB module
Terraform module which creates cluster parameter group

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
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
| [aws_docdb_cluster_parameter_group.docdb_cluster_parameter_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster_parameter_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_docdb_cluster_parameter_group_description"></a> [docdb\_cluster\_parameter\_group\_description](#input\_docdb\_cluster\_parameter\_group\_description) | The description of the documentDB cluster parameter group. Defaults to Managed by Terraform | `string` | `null` | no |
| <a name="input_docdb_cluster_parameter_group_family"></a> [docdb\_cluster\_parameter\_group\_family](#input\_docdb\_cluster\_parameter\_group\_family) | The family of the documentDB cluster parameter group. | `string` | n/a | yes |
| <a name="input_docdb_cluster_parameter_group_name"></a> [docdb\_cluster\_parameter\_group\_name](#input\_docdb\_cluster\_parameter\_group\_name) | The name of the documentDB cluster parameter group. If omitted, Terraform will assign a random, unique name. | `string` | n/a | yes |
| <a name="input_parameter"></a> [parameter](#input\_parameter) | A list of documentDB parameters to apply | `list(map(string))` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_documentdb_cluster_parameter_group"></a> [documentdb\_cluster\_parameter\_group](#output\_documentdb\_cluster\_parameter\_group) | The documentDB cluster parameter group. |
| <a name="output_documentdb_cluster_parameter_group_arn"></a> [documentdb\_cluster\_parameter\_group\_arn](#output\_documentdb\_cluster\_parameter\_group\_arn) | The ARN of the documentDB cluster parameter group. |
| <a name="output_documentdb_cluster_parameter_group_id"></a> [documentdb\_cluster\_parameter\_group\_id](#output\_documentdb\_cluster\_parameter\_group\_id) | The documentDB cluster parameter group name. |
| <a name="output_documentdb_cluster_parameter_group_tags_all"></a> [documentdb\_cluster\_parameter\_group\_tags\_all](#output\_documentdb\_cluster\_parameter\_group\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->