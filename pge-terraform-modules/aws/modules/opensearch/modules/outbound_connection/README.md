<!-- BEGIN_TF_DOCS -->


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
| [aws_opensearch_outbound_connection.outbound_connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_outbound_connection) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_connection_alias"></a> [connection\_alias](#input\_connection\_alias) | Outbound Connection alias | `string` | n/a | yes |
| <a name="input_connection_mode"></a> [connection\_mode](#input\_connection\_mode) | Connection Type Direct or vpc\_endpoint | `string` | `"DIRECT"` | no |
| <a name="input_local_domain"></a> [local\_domain](#input\_local\_domain) | Local Domain Name | `string` | n/a | yes |
| <a name="input_remote_domain"></a> [remote\_domain](#input\_remote\_domain) | Remote domain name | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_outbound_connection_all"></a> [outbound\_connection\_all](#output\_outbound\_connection\_all) | Map of all Outbound Connection attributes |
| <a name="output_outbound_connection_connection_status"></a> [outbound\_connection\_connection\_status](#output\_outbound\_connection\_connection\_status) | map of all Outbound Connection Status |
| <a name="output_outbound_connection_id"></a> [outbound\_connection\_id](#output\_outbound\_connection\_id) | Outbound Connection ID |

<!-- END_TF_DOCS -->