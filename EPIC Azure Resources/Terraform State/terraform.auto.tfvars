tenant_id       = "44ae661a-ece6-41aa-bc96-7c2c85a08941"
subscription_id = "2d118b3d-8251-4f33-a681-c79ff46c5036"

azure_region         = "westus2"
resource_group_name  = "rg-epic-terraform-state"
storage_account_name = "pgeepicterraformstate"
container_name       = "tfstate"

account_replication_type = "GRS"

tags = {
  ManagedBy   = "EPIC"
  Team        = "CCoE"
  Environment = "shared"
  AppID       = "APP-2102"
}
