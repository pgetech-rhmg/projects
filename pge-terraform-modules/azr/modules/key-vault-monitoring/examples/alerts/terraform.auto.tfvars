# Example values - replace with actual resource names
resource_group_name              = "DefaultResourceGroup-WUS2"
action_group_resource_group_name = "DefaultResourceGroup-WUS2"
action_group                     = "" # Leave empty for testing without actual action group
key_vault_names                  = [] # Leave empty for testing without actual key vaults
availability_threshold           = 99.5
service_api_latency_threshold    = 1500
service_api_hit_threshold        = 5000
service_api_result_threshold     = 20
saturation_shoebox_threshold     = 80
enable_diagnostic_settings       = false

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
