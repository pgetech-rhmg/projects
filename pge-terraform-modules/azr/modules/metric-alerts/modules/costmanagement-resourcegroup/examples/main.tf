# Example: Cost Management Resource Group Level Alerts Module Usage

provider "azurerm" {
  features {}
}

# Example 1: Production Environment with Strict Cost Controls
module "cost_alerts_production" {
  source = "../../costmanagement-resourcegroup"

  resource_group_name                = "rg-monitoring-prod"
  action_group_resource_group_name   = "rg-monitoring-prod"
  action_group                       = "pge-operations-actiongroup"
  location                           = "West US 2"

  # Monitor multiple production resource groups
  resource_group_names = [
    "rg-app-prod-eastus",
    "rg-app-prod-westus",
    "rg-data-prod-eastus"
  ]

  # Optional: Specify subscription if different from current
  # subscription_id = "00000000-0000-0000-0000-000000000000"

  # Strict production cost thresholds
  resource_group_monthly_cost_threshold           = 5000    # $5,000/month per RG
  resource_group_daily_cost_threshold             = 200     # $200/day spike detection
  resource_group_cost_increase_threshold_percent  = 20      # 20% increase triggers alert
  
  # Budget alert percentages
  budget_alert_percentage_first    = 70   # First warning at 70%
  budget_alert_percentage_second   = 85   # Second warning at 85%
  budget_alert_percentage_critical = 100  # Critical at 100%

  # Resource activity thresholds
  resource_creation_threshold = 15  # Alert if >15 resources created/day
  resource_deletion_threshold = 8   # Alert if >8 resources deleted/day

  # Enable all alert categories
  enable_resource_group_cost_alerts   = true
  enable_resource_group_trend_alerts  = true
  enable_resource_activity_alerts     = true

  # Notification contacts
  contact_emails = [
    "finance-prod@pge.com",
    "operations-prod@pge.com",
    "abc@pge.com"
  ]

  # Evaluation frequencies
  evaluation_frequency_daily  = "P1D"
  evaluation_frequency_hourly = "PT1H"
  window_duration_daily       = "P1D"
  window_duration_weekly      = "P7D"

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
  source = "../../costmanagement-resourcegroup"

  resource_group_name                = "rg-monitoring-dev"
  action_group_resource_group_name   = "rg-monitoring-dev"
  action_group                       = "pge-operations-actiongroup"
  location                           = "West US 2"

  # Monitor development resource groups
  resource_group_names = [
    "rg-app-dev-eastus",
    "rg-testing-dev"
  ]

  # Relaxed development cost thresholds
  resource_group_monthly_cost_threshold           = 1500    # $1,500/month per RG
  resource_group_daily_cost_threshold             = 100     # $100/day spike detection
  resource_group_cost_increase_threshold_percent  = 50      # 50% increase triggers alert
  
  # Budget alert percentages
  budget_alert_percentage_first    = 80   # First warning at 80%
  budget_alert_percentage_second   = 95   # Second warning at 95%
  budget_alert_percentage_critical = 110  # Critical at 110%

  # Relaxed resource activity thresholds
  resource_creation_threshold = 30  # Alert if >30 resources created/day
  resource_deletion_threshold = 20  # Alert if >20 resources deleted/day

  # Enable cost monitoring, disable activity alerts for dev
  enable_resource_group_cost_alerts   = true
  enable_resource_group_trend_alerts  = true
  enable_resource_activity_alerts     = false

  # Notification contacts
  contact_emails = [
    "dev-team@pge.com",
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
  source = "../../costmanagement-resourcegroup"

  resource_group_name                = "rg-monitoring-test"
  action_group_resource_group_name   = "rg-monitoring-test"
  action_group                       = "pge-operations-actiongroup"
  location                           = "West US 2"

  # Monitor single resource group
  resource_group_names = [
    "rg-app-test"
  ]

  # Use default thresholds (defined in variables.tf)
  # resource_group_monthly_cost_threshold = 2000 (default)
  # resource_group_daily_cost_threshold = 100 (default)
  # budget_alert_percentage_first = 75 (default)
  # budget_alert_percentage_second = 90 (default)
  # budget_alert_percentage_critical = 100 (default)

  # Enable only basic cost alerts
  enable_resource_group_cost_alerts   = true
  enable_resource_group_trend_alerts  = false
  enable_resource_activity_alerts     = false

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
