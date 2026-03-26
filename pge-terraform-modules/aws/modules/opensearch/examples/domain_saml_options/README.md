<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.5.1 |

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
| <a name="module_domain_saml_options"></a> [domain\_saml\_options](#module\_domain\_saml\_options) | ../../modules/domain_saml_options | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_opensearch_domain.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/opensearch_domain) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain Name | `string` | n/a | yes |
| <a name="input_domain_search"></a> [domain\_search](#input\_domain\_search) | Boolean to enable/disable the domain search using data source query | `bool` | `true` | no |
| <a name="input_metadata_content_file"></a> [metadata\_content\_file](#input\_metadata\_content\_file) | Metadata file content | `any` | `null` | no |
| <a name="input_saml_options"></a> [saml\_options](#input\_saml\_options) | SAML Options for the domain including metadata | `list(any)` | `[]` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_saml_id"></a> [saml\_id](#output\_saml\_id) | Map of all SAML ID |

<!-- END_TF_DOCS -->