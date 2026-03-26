<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.63.0 |

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
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_environment_v3.ase](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_environment_v3) | resource |
| [azurerm_private_dns_a_record.ase_root](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_a_record.ase_scm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_a_record.ase_wildcard](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.ase](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.ase](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.ase_dns_resolver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ase_name"></a> [ase\_name](#input\_ase\_name) | Name of the App Service Environment | `string` | n/a | yes |
| <a name="input_create_private_dns_zone"></a> [create\_private\_dns\_zone](#input\_create\_private\_dns\_zone) | Create private DNS zone for internal ASE | `bool` | `true` | no |
| <a name="input_dns_resolver_vnet_id"></a> [dns\_resolver\_vnet\_id](#input\_dns\_resolver\_vnet\_id) | ID of the DNS resolver VNet to link the private DNS zone to (for hub-spoke DNS resolution) | `string` | `""` | no |
| <a name="input_internal_load_balancing_mode"></a> [internal\_load\_balancing\_mode](#input\_internal\_load\_balancing\_mode) | Load balancing mode (None for public, 'Web, Publishing' for ILB) | `string` | `"None"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region location | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID of the subnet where ASE will be deployed | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | ID of the VNet to link the private DNS zone to | `string` | `""` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ase_dns_suffix"></a> [ase\_dns\_suffix](#output\_ase\_dns\_suffix) | DNS suffix of the ASE |
| <a name="output_ase_id"></a> [ase\_id](#output\_ase\_id) | ID of the App Service Environment |
| <a name="output_ase_internal_ip"></a> [ase\_internal\_ip](#output\_ase\_internal\_ip) | Internal inbound IP addresses of the ASE |
| <a name="output_ase_location"></a> [ase\_location](#output\_ase\_location) | Location of the App Service Environment |
| <a name="output_ase_name"></a> [ase\_name](#output\_ase\_name) | Name of the App Service Environment |
| <a name="output_ase_subnet_id"></a> [ase\_subnet\_id](#output\_ase\_subnet\_id) | Subnet ID of the ASE |
| <a name="output_private_dns_zone_id"></a> [private\_dns\_zone\_id](#output\_private\_dns\_zone\_id) | ID of the private DNS zone for the ASE |
| <a name="output_private_dns_zone_name"></a> [private\_dns\_zone\_name](#output\_private\_dns\_zone\_name) | Name of the private DNS zone for the ASE |

<!-- END_TF_DOCS -->