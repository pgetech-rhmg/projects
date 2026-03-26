<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.8.0 |

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
| [azapi_resource.hub_to_partner](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.partner_to_hub](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hub_gateway_transit"></a> [hub\_gateway\_transit](#input\_hub\_gateway\_transit) | Allow hub VNet to provide gateway transit to partner VNets. Set to true if hub has a gateway. | `bool` | `false` | no |
| <a name="input_hub_vnet_id"></a> [hub\_vnet\_id](#input\_hub\_vnet\_id) | Hub VNet resource ID | `string` | n/a | yes |
| <a name="input_partner_name"></a> [partner\_name](#input\_partner\_name) | Partner name | `string` | n/a | yes |
| <a name="input_partner_vnet_id"></a> [partner\_vnet\_id](#input\_partner\_vnet\_id) | Partner VNet resource ID | `string` | n/a | yes |
| <a name="input_partner_vnet_name"></a> [partner\_vnet\_name](#input\_partner\_vnet\_name) | Partner VNet name | `string` | n/a | yes |
| <a name="input_use_remote_gateways"></a> [use\_remote\_gateways](#input\_use\_remote\_gateways) | Allow partner VNet to use hub's remote gateway (VPN/ExpressRoute). Set to true if hub has a gateway. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hub_peering_id"></a> [hub\_peering\_id](#output\_hub\_peering\_id) | Hub to Partner peering resource ID |
| <a name="output_hub_peering_name"></a> [hub\_peering\_name](#output\_hub\_peering\_name) | Hub to Partner peering name |
| <a name="output_peering_id"></a> [peering\_id](#output\_peering\_id) | Partner to Hub peering resource ID |
| <a name="output_peering_name"></a> [peering\_name](#output\_peering\_name) | Partner to Hub peering name |
| <a name="output_peering_status"></a> [peering\_status](#output\_peering\_status) | Peering status |


<!-- END_TF_DOCS -->