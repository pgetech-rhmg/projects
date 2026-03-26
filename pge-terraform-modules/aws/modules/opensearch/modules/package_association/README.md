<!-- BEGIN_TF_DOCS -->


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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_opensearch_package_association.package_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_package_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Name of the domain to associate the package with. | `string` | n/a | yes |
| <a name="input_package_id"></a> [package\_id](#input\_package\_id) | ID of the package to associate with a domain. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_opensearch_package_association_all"></a> [aws\_opensearch\_package\_association\_all](#output\_aws\_opensearch\_package\_association\_all) | Map of all package association attributes |
| <a name="output_aws_opensearch_package_association_id"></a> [aws\_opensearch\_package\_association\_id](#output\_aws\_opensearch\_package\_association\_id) | Unique ID of the package association |

<!-- END_TF_DOCS -->