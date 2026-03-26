run "cosmos-sql" {
  command = apply

  module {
    source = "./examples/cosmos-sql"
  }
}

variables {
  name                               = "my-cosmos-db-account-aurb"
  resource_group_name                = "DefaultResourceGroup-WUS2"
  location                           = "West US 2"
  api_type                           = "sql"
  capacity_mode                      = "serverless"
  workload                           = "development"
  database_name                      = "my-database"
  container_name                     = "my-container"
  partition_key                      = "/myPartitionKey"
  backup_interval_in_minutes         = 60
  backup_retention_interval_in_hours = 48
  backup_storage_redundancy          = "Local"
  public_network_access_enabled      = true
  tags = {
    AppID              = "APP-1001"
    Environment        = "Dev"
    DataClassification = "Internal"
    CRIS               = "Low"
    Notify             = "abc1@pge.com_def2@pge.com_ghi3@pge.com"
    Owner              = "abc1_def2_ghi3"
    Compliance         = "None"
    Order              = "811205"
  }
  environment    = "Development"
  max_throughput = 400
}
