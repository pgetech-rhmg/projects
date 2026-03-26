# Azure Update Manager Monitoring - Example Configurations
# This example demonstrates various deployment patterns for Azure Update Manager monitoring

# =======================================================================================
# Data Sources - Common across all examples
# =======================================================================================

data "azurerm_monitor_action_group" "pge_operations" {
  name                = "PGE-Operations"
  resource_group_name = "rg-pge-monitoring-prod"
}

# =======================================================================================
# Example 1: Production Update Manager with Full Monitoring
# =======================================================================================
# This configuration monitors production VMs with comprehensive update management alerting

module "updatemanager_monitoring_production" {
  source = "../"

  # Resource Configuration
  resource_group_name              = "rg-pge-updatemanager-prod"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"
  location                         = "West US 2"

  # Subscription IDs to Monitor
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012"
  ]

  # VM Resource IDs to Monitor for Update Compliance
  vm_resource_ids = [
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-pge-vms-prod/providers/Microsoft.Compute/virtualMachines/vm-web-prod-01",
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-pge-vms-prod/providers/Microsoft.Compute/virtualMachines/vm-web-prod-02",
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-pge-vms-prod/providers/Microsoft.Compute/virtualMachines/vm-app-prod-01",
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-pge-vms-prod/providers/Microsoft.Compute/virtualMachines/vm-app-prod-02",
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-pge-vms-prod/providers/Microsoft.Compute/virtualMachines/vm-db-prod-01"
  ]

  # Enable All Alerts
  enable_update_deployment_failure_alert  = true
  enable_update_compliance_alert          = true
  enable_maintenance_window_alert         = true
  enable_patch_installation_failure_alert = true
  enable_update_assessment_failure_alert  = true
  enable_critical_update_available_alert  = true

  # Alert Thresholds - Strict for Production
  update_deployment_failure_threshold  = 1
  update_compliance_threshold          = 95 # 95% compliance required
  patch_installation_failure_threshold = 1
  update_assessment_failure_threshold  = 1
  critical_update_available_threshold  = 1
  maintenance_window_threshold         = 15 # 15 minutes tolerance

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

# =======================================================================================
# Example 2: Development Update Manager with Relaxed Monitoring
# =======================================================================================
# This configuration monitors development VMs with relaxed thresholds

module "updatemanager_monitoring_development" {
  source = "../"

  # Resource Configuration
  resource_group_name              = "rg-pge-updatemanager-dev"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"
  location                         = "West US 2"

  # Subscription IDs to Monitor
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012"
  ]

  # VM Resource IDs to Monitor for Update Compliance
  vm_resource_ids = [
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-pge-vms-dev/providers/Microsoft.Compute/virtualMachines/vm-web-dev-01",
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-pge-vms-dev/providers/Microsoft.Compute/virtualMachines/vm-app-dev-01",
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-pge-vms-dev/providers/Microsoft.Compute/virtualMachines/vm-db-dev-01"
  ]

  # Enable Critical Alerts Only
  enable_update_deployment_failure_alert  = true
  enable_update_compliance_alert          = true
  enable_maintenance_window_alert         = false
  enable_patch_installation_failure_alert = true
  enable_update_assessment_failure_alert  = false
  enable_critical_update_available_alert  = true

  # Alert Thresholds - Relaxed for Development
  update_deployment_failure_threshold  = 2
  update_compliance_threshold          = 80 # 80% compliance acceptable
  patch_installation_failure_threshold = 2
  update_assessment_failure_threshold  = 2
  critical_update_available_threshold  = 3
  maintenance_window_threshold         = 60 # 60 minutes tolerance

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

# =======================================================================================
# Example 3: Basic Update Manager Monitoring for Test Environment
# =======================================================================================
# This configuration provides minimal monitoring for test VMs

module "updatemanager_monitoring_basic" {
  source = "../"

  # Resource Configuration
  resource_group_name              = "rg-pge-updatemanager-test"
  action_group_resource_group_name = "rg-pge-monitoring-prod"
  action_group                     = "PGE-Operations"
  location                         = "West US 2"

  # Subscription IDs to Monitor
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012"
  ]

  # VM Resource IDs to Monitor for Update Compliance
  vm_resource_ids = [
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-pge-vms-test/providers/Microsoft.Compute/virtualMachines/vm-test-01"
  ]

  # Enable Only Critical Alerts
  enable_update_deployment_failure_alert  = true
  enable_update_compliance_alert          = false
  enable_maintenance_window_alert         = false
  enable_patch_installation_failure_alert = true
  enable_update_assessment_failure_alert  = false
  enable_critical_update_available_alert  = true

  # Alert Thresholds - Minimal
  update_deployment_failure_threshold  = 3
  update_compliance_threshold          = 70
  patch_installation_failure_threshold = 3
  update_assessment_failure_threshold  = 3
  critical_update_available_threshold  = 5
  maintenance_window_threshold         = 120

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
