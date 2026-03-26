terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Example 1: Production deployment with strict thresholds
module "firewall_alerts_production" {
  source = "../"

  firewall_names                   = ["prod-afw-001", "prod-afw-002"]
  resource_group_name              = "rg-networking-prod"
  action_group_resource_group_name = "rg-actiongroups-prod"
  action_group                     = "ag-production-alerts"
  location                         = "East US"

  # Production thresholds - strict monitoring
  firewall_health_threshold                   = 95  # Alert if health drops below 95%
  firewall_snat_port_utilization_threshold    = 90  # Stricter SNAT monitoring
  firewall_throughput_threshold               = 20000000000  # 20 Gbps
  firewall_latency_threshold                  = 15  # 15ms latency threshold
  firewall_data_processed_threshold           = 800000000000  # 800 GB per hour
  firewall_app_rule_hit_threshold             = 80000  # Stricter app rule monitoring
  firewall_net_rule_hit_threshold             = 80000  # Stricter network rule monitoring

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

# Example 2: Development deployment with relaxed thresholds
module "firewall_alerts_development" {
  source = "../"

  firewall_names                   = ["dev-afw-001"]
  resource_group_name              = "rg-networking-dev"
  action_group_resource_group_name = "rg-actiongroups-dev"
  action_group                     = "ag-development-alerts"
  location                         = "East US"

  # Development thresholds - more relaxed
  firewall_health_threshold                   = 80  # More relaxed for dev
  firewall_snat_port_utilization_threshold    = 95  # Standard threshold
  firewall_throughput_threshold               = 30000000000  # 30 Gbps - higher for dev testing
  firewall_latency_threshold                  = 30  # More relaxed latency
  firewall_data_processed_threshold           = 2000000000000  # 2 TB per hour - higher for dev
  firewall_app_rule_hit_threshold             = 200000  # More relaxed
  firewall_net_rule_hit_threshold             = 200000  # More relaxed

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

# Example 3: Basic deployment with default values
module "firewall_alerts_basic" {
  source = "../"

  firewall_names                   = ["basic-afw-001"]
  resource_group_name              = "rg-networking-basic"
  action_group_resource_group_name = "rg-actiongroups-basic"
  action_group                     = "ag-basic-alerts"
  location                         = "East US"

  # Use all default threshold values

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
