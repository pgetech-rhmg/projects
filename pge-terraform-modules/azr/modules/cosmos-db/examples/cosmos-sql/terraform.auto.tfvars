name                = "my-cosmos-db-account-LanID" # Name of the Cosmos DB account
resource_group_name = "DefaultResourceGroup-WUS2"  # Name of the resource group
location            = "West US 2"                  # Azure region location
api_type            = "sql"                        # API type for Cosmos DB (sql(nosql engine), mongodb, cassandra, gremlin, table).  furture enhancement could be to add support for other API types in the module.

database_name  = "my-database"     # Name of the database to create
container_name = "my-container"    # Name of the container to create
partition_key  = "/myPartitionKey" # Partition key path for the container" Partition key must start with '/' and contain only alphanumeric characters, underscores, and hyphens."
capacity_mode  = "serverless"      # Capacity mode for Cosmos DB (serverless or provisioned). Serverless is ideal for development and testing, while provisioned is better for production workloads with predictable traffic patterns.
#key_vault_key_id = "" # Optional: Key Vault key ID for customer-managed keys (CMK) encryption. If not provided, the Cosmos DB account will use Microsoft-managed keys.



tags = { # Custom tags to apply to the Cosmos DB account
  AppID              = "APP-1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = "abc1@pge.com_def2@pge.com_ghi3@pge.com"
  Owner              = "abc1_def2_ghi3"
  Compliance         = "None"
  Order              = "811205"
}



