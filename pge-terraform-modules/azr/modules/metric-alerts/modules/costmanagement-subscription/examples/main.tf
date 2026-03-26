# Example: Cost Management Subscription Level Alerts Module Usage

provider "azurerm" {
  features {}
}

# Example 1: Production Environment with Strict Cost Controls
module "cost_alerts_production" {
  source = "../../costmanagement-subscription"

  resource_group_name                = "rg-monitoring-prod"
  action_group_resource_group_name   = "rg-monitoring-prod"
  action_group                       = "pge-operations-actiongroup"
  location                           = "West US 2"

  # Monitor production subscriptions
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012",
    "87654321-4321-4321-4321-210987654321"
  ]

  # Strict production cost thresholds
  subscription_monthly_cost_threshold    = 50000   # $50,000/month per subscription
  subscription_daily_cost_threshold      = 2000    # $2,000/day spike detection
  weekly_cost_increase_threshold_percent = 15      # 15% weekly increase triggers alert
  
  # Budget alert percentages
  budget_alert_percentage_first    = 70   # First warning at 70%
  budget_alert_percentage_second   = 85   # Second warning at 85%
  budget_alert_percentage_critical = 100  # Critical at 100%

  # Service-specific cost thresholds (monthly)
  compute_cost_threshold    = 15000  # $15,000/month for VMs, AKS, etc.
  storage_cost_threshold    = 5000   # $5,000/month for storage accounts, disks
  database_cost_threshold   = 10000  # $10,000/month for SQL, Cosmos DB, etc.
  networking_cost_threshold = 3000   # $3,000/month for VNet, Load Balancers, etc.

  # Enable all alert categories
  enable_subscription_cost_alerts = true
  enable_cost_increase_alerts     = true
  enable_export_alerts            = true
  enable_service_cost_alerts      = true

  # Notification contacts
  contact_emails = [
    "finance-prod@pge.com",
    "cfo@pge.com",
    "operations-prod@pge.com",
    "abc@pge.com"
  ]

  # Evaluation frequencies
  evaluation_frequency_daily = "P1D"
  window_duration_daily      = "P1D"
  window_duration_weekly     = "P7D"

  tags = {
    AppId              = "123456"
    Env                = "Dev"
    Owner              = "abc@pge.com"
    Compliance         = "None"
    Notify             = "abc@pge.com"
    DataClassification = "internal"
    CRIS               = "1"
    order              = "123456"
  }
}

# Example 2: Development Environment with Relaxed Thresholds
module "cost_alerts_development" {
  source = "../../costmanagement-subscription"

  resource_group_name                = "rg-monitoring-dev"
  action_group_resource_group_name   = "rg-monitoring-dev"
  action_group                       = "pge-operations-actiongroup"
  location                           = "West US 2"

  # Monitor development subscription
  subscription_ids = [
    "11111111-2222-3333-4444-555555555555"
  ]

  # Relaxed development cost thresholds
  subscription_monthly_cost_threshold    = 15000   # $15,000/month per subscription
  subscription_daily_cost_threshold      = 700     # $700/day spike detection
  weekly_cost_increase_threshold_percent = 40      # 40% weekly increase triggers alert
  
  # Budget alert percentages
  budget_alert_percentage_first    = 80   # First warning at 80%
  budget_alert_percentage_second   = 95   # Second warning at 95%
  budget_alert_percentage_critical = 110  # Critical at 110%

  # Service-specific cost thresholds (monthly) - relaxed
  compute_cost_threshold    = 5000   # $5,000/month
  storage_cost_threshold    = 2000   # $2,000/month
  database_cost_threshold   = 3000   # $3,000/month
  networking_cost_threshold = 1500   # $1,500/month

  # Enable main cost monitoring, disable some alerts for dev flexibility
  enable_subscription_cost_alerts = true
  enable_cost_increase_alerts     = true
  enable_export_alerts            = false
  enable_service_cost_alerts      = true

  # Notification contacts
  contact_emails = [
    "dev-team@pge.com",
    "finance-dev@pge.com",
    "abc@pge.com"
  ]

  tags = {
    AppId              = "123456"
    Env                = "Dev"
    Owner              = "abc@pge.com"
    Compliance         = "None"
    Notify             = "abc@pge.com"
    DataClassification = "internal"
    CRIS               = "1"
    order              = "123456"
  }
}

# Example 3: Basic Configuration with Default Thresholds
module "cost_alerts_basic" {
  source = "../../costmanagement-subscription"

  resource_group_name                = "rg-monitoring-test"
  action_group_resource_group_name   = "rg-monitoring-test"
  action_group                       = "pge-operations-actiongroup"
  location                           = "West US 2"

  # Monitor single test subscription
  subscription_ids = [
    "99999999-8888-7777-6666-555555555555"
  ]

  # Use default thresholds (defined in variables.tf)
  # subscription_monthly_cost_threshold = 10000 (default)
  # subscription_daily_cost_threshold = 500 (default)
  # budget_alert_percentage_first = 75 (default)
  # budget_alert_percentage_second = 90 (default)
  # budget_alert_percentage_critical = 100 (default)

  # Enable only basic budget alerts
  enable_subscription_cost_alerts = true
  enable_cost_increase_alerts     = false
  enable_export_alerts            = false
  enable_service_cost_alerts      = false

  # Notification contacts
  contact_emails = [
    "abc@pge.com"
  ]

  tags = {
    AppId              = "123456"
    Env                = "Dev"
    Owner              = "abc@pge.com"
    Compliance         = "None"
    Notify             = "abc@pge.com"
    DataClassification = "internal"
    CRIS               = "1"
    order              = "123456"
  }
}
