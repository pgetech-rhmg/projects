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

name                          = "example-redis-cache-20250224" # note name must be globally unique
location                      = "West US 2"
resource_group_name           = "DefaultResourceGroup-WUS2"
capacity                      = 2
family                        = "P"
sku_name                      = "Premium"
enable_non_ssl_port           = true
minimum_tls_version           = "1.2"
public_network_access_enabled = true
redis_version                 = 6
maxmemory_policy              = "volatile-lru"
