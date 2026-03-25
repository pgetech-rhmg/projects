###############################################################################
# Azure Context
###############################################################################

tenant_id       = "44ae661a-ece6-41aa-bc96-7c2c85a08941"
subscription_id = "2d118b3d-8251-4f33-a681-c79ff46c5036"

resource_group_name = "rg-pge-php-example-dev"
azure_region        = "westus2"

###############################################################################
# Application
###############################################################################

app_name          = "pge-php-example"
environment       = "dev"
service_plan_name = "asp-pge-php-example-dev"
sku_name          = "B1"
runtime_version   = "8.3"

###############################################################################
# Tagging & Compliance
###############################################################################

appid              = 2102
notify             = ["rhmg@pge.com", "def2@pge.com", "ghi3@pge.com"]
owner              = ["rhmg", "def2", "ghi3"]
order              = 70056008
dataclassification = "Public"
compliance         = ["None"]
cris               = "Low"
