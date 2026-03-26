/*
 * # Azure Cosmos DB SQL Example
*/
#  Filename    : azr/modules/cosmos-db/examples/cosmos-sql/main.tf
#  Date        : 24 Feb 2026
#  Author      : PG&E
#  Description : Example implementation of the Azure Cosmos DB module that creates a complete Cosmos DB SQL API environment.
#                This example provisions the following resources:
#                  - Azure Cosmos DB Account with GlobalDocumentDB (SQL API) support
#                  - Cosmos DB SQL Database
#                  - Cosmos DB SQL Container with partition key configuration
#                  - Customer-managed encryption using Key Vault (optional)
#                  - Periodic backup with configurable intervals and retention
#                  - Private network access (public access disabled)
#                  - RBAC-based authentication (local authentication disabled)
#                  - Support for both serverless and provisioned capacity modes
#                  - Autoscale throughput settings for provisioned mode

module "cosmos_sql" {
  source              = "../../"
  database_name       = var.database_name
  container_name      = var.container_name
  partition_key       = var.partition_key
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  api_type            = var.api_type
  capacity_mode       = var.capacity_mode
  tags                = var.tags
  #key_vault_key_id    = var.key_vault_key_id
}
