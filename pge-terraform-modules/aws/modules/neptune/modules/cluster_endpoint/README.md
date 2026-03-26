<!-- BEGIN_TF_DOCS -->
*#AWS Neptune module
*Terraform module which creates cluster  endpoint

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
| [aws_neptune_cluster_endpoint.neptune_cluster_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/neptune_cluster_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_members"></a> [members](#input\_members) | static\_members:<br/>    (Optional) List of DB instance identifiers that are part of the custom endpoint group.<br/>excluded\_members:<br/>    (Optional) List of DB instance identifiers that aren't part of the custom endpoint group. All other eligible instances are reachable through the custom endpoint. Only relevant if the list of static members is empty. | <pre>object({<br/>    static_members   = list(string)<br/>    excluded_members = list(string)<br/>  })</pre> | <pre>{<br/>  "excluded_members": [],<br/>  "static_members": []<br/>}</pre> | no |
| <a name="input_neptune_cluster_endpoint_identifier"></a> [neptune\_cluster\_endpoint\_identifier](#input\_neptune\_cluster\_endpoint\_identifier) | The identifier of the endpoint. | `string` | n/a | yes |
| <a name="input_neptune_cluster_endpoint_type"></a> [neptune\_cluster\_endpoint\_type](#input\_neptune\_cluster\_endpoint\_type) | The type of the endpoint. One of: READER, WRITER, ANY. | `string` | n/a | yes |
| <a name="input_neptune_cluster_identifier"></a> [neptune\_cluster\_identifier](#input\_neptune\_cluster\_identifier) | The DB cluster identifier of the DB cluster associated with the endpoint. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_neptune_cluster_endpoint"></a> [neptune\_cluster\_endpoint](#output\_neptune\_cluster\_endpoint) | The DNS address of the endpoint. |
| <a name="output_neptune_cluster_endpoint_all"></a> [neptune\_cluster\_endpoint\_all](#output\_neptune\_cluster\_endpoint\_all) | A map of aws neptune cluster endpoint |
| <a name="output_neptune_cluster_endpoint_arn"></a> [neptune\_cluster\_endpoint\_arn](#output\_neptune\_cluster\_endpoint\_arn) | The Neptune Cluster Endpoint Amazon Resource Name (ARN). |
| <a name="output_neptune_cluster_endpoint_id"></a> [neptune\_cluster\_endpoint\_id](#output\_neptune\_cluster\_endpoint\_id) | The Neptune Cluster Endpoint Identifier |
| <a name="output_neptune_cluster_endpoint_tags_all"></a> [neptune\_cluster\_endpoint\_tags\_all](#output\_neptune\_cluster\_endpoint\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->