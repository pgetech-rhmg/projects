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
name                     = "example-module-kv"
resource_group_name      = "DefaultResourceGroup-WUS2"
location                 = "West US 2"
sku_name                 = "premium"
tenant_id                = "44ae661a-ece6-41aa-bc96-7c2c85a08941"
purge_protection_enabled = true #for policy

