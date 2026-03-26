<!-- BEGIN_TF_DOCS -->
# AWS Opensearch domain\_saml\_options module
Terraform module which creates domain\_saml\_options for Opensearch Domain

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
| [aws_opensearch_domain_saml_options.saml](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain_saml_options) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Name of the fleet. | `string` | n/a | yes |
| <a name="input_metadata_content_file"></a> [metadata\_content\_file](#input\_metadata\_content\_file) | metadata\_content\_file. | `any` | `null` | no |
| <a name="input_saml_options"></a> [saml\_options](#input\_saml\_options) | SAML Options for domain | `list(any)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_saml_all"></a> [saml\_all](#output\_saml\_all) | Map of all Opensearch Domain SAML attributes |
| <a name="output_saml_id"></a> [saml\_id](#output\_saml\_id) | Opensearch Domain SAML options ID |

<!-- END_TF_DOCS -->