<!-- BEGIN_TF_DOCS -->
# Azure Cosmos DB SQL Example

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

No providers.

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
| <a name="module_cosmos_sql"></a> [cosmos\_sql](#module\_cosmos\_sql) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_type"></a> [api\_type](#input\_api\_type) | API type for Cosmos DB | `string` | `"sql"` | no |
| <a name="input_capacity_mode"></a> [capacity\_mode](#input\_capacity\_mode) | Capacity mode for Cosmos DB | `string` | `"serverless"` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Name of the container to create | `string` | n/a | yes |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the database to create | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region location | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Cosmos DB account | `string` | n/a | yes |
| <a name="input_partition_key"></a> [partition\_key](#input\_partition\_key) | Partition key path for the container | `string` | `"/partitionKey"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | Name of the created container |
| <a name="output_cosmos_db_id"></a> [cosmos\_db\_id](#output\_cosmos\_db\_id) | ID of the Cosmos DB account |
| <a name="output_cosmos_db_name"></a> [cosmos\_db\_name](#output\_cosmos\_db\_name) | Name of the Cosmos DB account |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | Name of the created database |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Endpoint of the Cosmos DB account |
| <a name="output_primary_key"></a> [primary\_key](#output\_primary\_key) | Primary key for the Cosmos DB account (use with caution, RBAC preferred) |

<!-- END_TF_DOCS -->