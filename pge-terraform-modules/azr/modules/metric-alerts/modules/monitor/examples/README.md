# Azure Monitor Resources Monitoring Module - Examples

This directory contains example configurations for the Azure Monitor resources monitoring module, demonstrating different deployment patterns for observability platform monitoring.

## Overview

The Azure Monitor resources monitoring module provides comprehensive observability for the Azure Monitor platform itself, including:
- **Log Analytics Workspace Monitoring**: Data ingestion, query performance tracking
- **Application Insights Monitoring**: Availability, response times, failures, exceptions
- **Data Collection Rules Monitoring**: Collection failures and data latency
- **Service Health Monitoring**: Azure Monitor service availability and health
- **Diagnostic Settings Monitoring**: Configuration compliance and completeness

## Examples

### 1. Production Deployment
**File**: See `main.tf` - Production example

High-sensitivity configuration optimized for production observability platforms with:
- Strict data ingestion limits (50GB warning, 100GB critical)
- Tight availability requirements (99.5%)
- Low latency tolerances (1 second response time)
- Aggressive error detection (10 failed requests, 5 exceptions)
- All alert categories enabled
- Multi-workspace and multi-insights monitoring

**Best for**:
- Production environments
- Mission-critical observability platforms
- Enterprise monitoring infrastructure
- SLA-driven deployments

**Key Features**:
- 50GB/100GB data ingestion thresholds
- 99.5% availability monitoring
- 1-second response time threshold
- 10 failed requests threshold
- 5 exception threshold
- 5% DCR failure rate
- 10-minute data latency threshold

### 2. Development Deployment
**File**: See `main.tf` - Development example

Relaxed configuration for development and testing:
- Higher ingestion limits (100GB warning, 200GB critical)
- Lower availability requirements (95%)
- Relaxed latency tolerances (3 seconds)
- Increased error thresholds (50 failures, 20 exceptions)
- Selective alert categories
- Development-appropriate sensitivity

**Best for**:
- Development environments
- Testing and staging
- Cost-conscious monitoring
- Non-production workloads

**Key Features**:
- 100GB/200GB data ingestion thresholds
- 95% availability monitoring
- 3-second response time threshold
- 50 failed requests threshold
- 20 exception threshold
- 15% DCR failure rate
- 30-minute data latency threshold
- Monitor service alerts disabled

### 3. Basic Deployment
**File**: See `main.tf` - Basic example

Minimal configuration focusing on critical resources:
- Default thresholds for simplicity
- Only workspace and App Insights monitoring
- No DCR or service health monitoring
- Simplified alert footprint
- Essential monitoring only

**Best for**:
- Proof-of-concept deployments
- Quick setup requirements
- Testing the module
- Budget-constrained environments

**Key Features**:
- Default threshold values
- Only critical resource monitoring
- Minimal alert volume
- Lower operational overhead

## Alert Types

### Log Analytics Workspace Alerts
Monitor data ingestion and query performance:

| Alert | Metric | Default Threshold | Description |
|-------|--------|-------------------|-------------|
| Data Ingestion (Warning) | BillableDataSizeGB | 100GB | Daily data ingestion warning |
| Data Ingestion (Critical) | BillableDataSizeGB | 200GB | Daily data ingestion critical |

**Ingestion Warning**: Severity 2 (Warning), Medium frequency  
**Ingestion Critical**: Severity 0 (Critical), High frequency

### Application Insights Alerts
Track application observability health:

| Alert | Metric | Default Threshold | Description |
|-------|--------|-------------------|-------------|
| Availability | AvailabilityResults/availabilityPercentage | 99.0% | Service availability |
| Response Time | requests/duration | 2000ms | Average response time |
| Failed Requests | requests/failed | 20 | Failed request count |
| Exceptions | exceptions/count | 10 | Exception rate |

**Availability**: Severity 1 (Critical)  
**Response Time**: Severity 2 (Warning)  
**Failed Requests**: Severity 2 (Warning)  
**Exceptions**: Severity 2 (Warning)

### Data Collection Rules Alerts
Monitor data collection pipeline health:

| Alert | Metric | Default Threshold | Description |
|-------|--------|-------------------|-------------|
| Collection Failures | Collection failure percentage | 10% | DCR collection failure rate |
| Data Latency | Data latency | 20 minutes | DCR data processing latency |

**Note**: DCR alerts require Data Collection Rules to be deployed and configured.

## Module Architecture

### Resource Types Monitored
1. **Log Analytics Workspaces**: Core logging and analytics platform
2. **Application Insights**: Application performance monitoring
3. **Data Collection Rules**: Agent-based data collection configuration
4. **Subscriptions**: Subscription-level monitoring scope

### Alert Categories
The module provides granular control through five alert categories:

| Category | Controls | Default |
|----------|----------|---------|
| `enable_workspace_alerts` | Log Analytics workspace monitoring | `true` |
| `enable_application_insights_alerts` | Application Insights monitoring | `true` |
| `enable_data_collection_alerts` | DCR monitoring | `true` |
| `enable_monitor_service_alerts` | Azure Monitor service health | `true` |
| `enable_diagnostic_settings_alerts` | Diagnostic settings compliance | `true` |

## Usage

### Prerequisites
1. Azure subscription with monitoring resources deployed
2. Existing Action Group for alert notifications
3. Log Analytics workspaces (optional)
4. Application Insights resources (optional)
5. Data Collection Rules (optional)

### Basic Usage

```hcl
module "monitor_alerts" {
  source = "path/to/module"

  # Resource identification
  resource_group_name              = "rg-monitoring-prod"
  action_group_resource_group_name = "rg-alerts"
  action_group                     = "ag-prod-alerts"

  # Subscription monitoring
  subscription_ids = ["12345678-1234-1234-1234-123456789012"]

  # Log Analytics workspaces
  log_analytics_workspace_names = [
    "law-prod-001",
    "law-security-prod"
  ]

  # Application Insights
  application_insights_names = [
    "appi-web-prod"
  ]

  # Custom thresholds
  workspace_data_ingestion_threshold_gb = 50
  app_insights_availability_threshold_percent = 99.5

  # Tags
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Monitor Multiple Workspaces with Custom Thresholds

```hcl
module "monitor_alerts" {
  source = "path/to/module"

  resource_group_name              = "rg-monitoring-prod"
  action_group_resource_group_name = "rg-alerts"
  action_group                     = "ag-prod-alerts"

  subscription_ids = ["12345678-1234-1234-1234-123456789012"]

  # Monitor multiple Log Analytics workspaces
  log_analytics_workspace_names = [
    "law-application-prod",
    "law-security-prod",
    "law-infrastructure-prod"
  ]

  # Strict production thresholds
  workspace_data_ingestion_threshold_gb          = 50
  workspace_data_ingestion_critical_threshold_gb = 100
  workspace_query_timeout_threshold_minutes      = 5

  # Enable all alert categories
  enable_workspace_alerts             = true
  enable_application_insights_alerts  = false  # No App Insights in this deployment
  enable_data_collection_alerts       = true
  enable_monitor_service_alerts       = true
  enable_diagnostic_settings_alerts   = true

  tags = {
    Environment    = "Production"
    MonitoringTier = "Critical"
  }
}
```

### Application Insights Focused Monitoring

```hcl
module "monitor_alerts" {
  source = "path/to/module"

  resource_group_name              = "rg-monitoring-prod"
  action_group_resource_group_name = "rg-alerts"
  action_group                     = "ag-prod-alerts"

  subscription_ids = ["12345678-1234-1234-1234-123456789012"]

  # Focus on Application Insights monitoring
  application_insights_names = [
    "appi-web-frontend",
    "appi-api-backend",
    "appi-mobile-app"
  ]

  # Strict Application Insights thresholds
  app_insights_availability_threshold_percent = 99.9  # Four nines
  app_insights_response_time_threshold_ms     = 500   # 500ms
  app_insights_failed_requests_threshold      = 5     # Only 5 failures
  app_insights_exception_rate_threshold       = 3     # 3 exceptions

  # Enable only App Insights alerts
  enable_workspace_alerts             = false
  enable_application_insights_alerts  = true
  enable_data_collection_alerts       = false
  enable_monitor_service_alerts       = false
  enable_diagnostic_settings_alerts   = false

  tags = {
    Environment       = "Production"
    ApplicationTier   = "Frontend"
    MonitoringFocus   = "Performance"
  }
}
```

### Selective Alert Categories

```hcl
module "monitor_alerts" {
  source = "path/to/module"

  resource_group_name              = "rg-monitoring-dev"
  action_group_resource_group_name = "rg-alerts"
  action_group                     = "ag-dev-alerts"

  subscription_ids                  = ["87654321-4321-4321-4321-210987654321"]
  log_analytics_workspace_names     = ["law-dev-001"]
  application_insights_names        = ["appi-dev-001"]
  data_collection_rule_names        = ["dcr-vm-insights-dev"]

  # Enable only critical alert categories for dev
  enable_workspace_alerts             = true   # Monitor ingestion
  enable_application_insights_alerts  = true   # Monitor app health
  enable_data_collection_alerts       = false  # Disable DCR alerts
  enable_monitor_service_alerts       = false  # Disable service health
  enable_diagnostic_settings_alerts   = false  # Disable config checks
}
```

## Threshold Variables

All threshold variables support customization:

### Log Analytics Workspace Thresholds
| Variable | Default | Description |
|----------|---------|-------------|
| `workspace_data_ingestion_threshold_gb` | 100 | Daily data ingestion warning (GB) |
| `workspace_data_ingestion_critical_threshold_gb` | 200 | Daily data ingestion critical (GB) |
| `workspace_query_timeout_threshold_minutes` | 10 | Query timeout threshold (minutes) |

### Application Insights Thresholds
| Variable | Default | Description |
|----------|---------|-------------|
| `app_insights_availability_threshold_percent` | 99.0 | Availability percentage |
| `app_insights_response_time_threshold_ms` | 2000 | Response time in milliseconds |
| `app_insights_failed_requests_threshold` | 20 | Failed request count |
| `app_insights_exception_rate_threshold` | 10 | Exception count |

### Data Collection Rules Thresholds
| Variable | Default | Description |
|----------|---------|-------------|
| `dcr_collection_failure_threshold_percent` | 10 | Collection failure percentage |
| `dcr_data_latency_threshold_minutes` | 20 | Data latency in minutes |

## Outputs

The module provides comprehensive outputs:

```hcl
# Alert resource IDs (list)
output "alert_ids" {
  value = module.monitor_alerts.alert_ids
}

# Alert names (list)
output "alert_names" {
  value = module.monitor_alerts.alert_names
}

# Monitored resources
output "monitored_workspaces" {
  value = module.monitor_alerts.monitored_log_analytics_workspaces
}

output "monitored_app_insights" {
  value = module.monitor_alerts.monitored_application_insights
}

output "monitored_dcrs" {
  value = module.monitor_alerts.monitored_data_collection_rules
}

# Alert summary (counts by type)
output "alert_summary" {
  value = module.monitor_alerts.alert_summary
}

# Alert categories status
output "alert_categories" {
  value = module.monitor_alerts.alert_categories_enabled
}
```

## Best Practices

### 1. Threshold Tuning
- Start with defaults and adjust based on baseline behavior
- Monitor alert frequency and adjust to reduce noise
- Set stricter thresholds for production environments
- Use relaxed thresholds for development/testing

### 2. Resource Organization
- Group monitoring resources by environment and purpose
- Use separate modules for different monitoring tiers
- Consider resource-specific thresholds for high-traffic workspaces
- Use tags to identify monitoring ownership

### 3. Cost Management
- Monitor Log Analytics data ingestion closely
- Set appropriate ingestion thresholds to control costs
- Use critical alerts for budget protection
- Review historical ingestion patterns regularly

### 4. Alert Categories
- Enable all categories for production
- Disable service health alerts for dev/test to reduce noise
- Always enable workspace and App Insights alerts
- DCR alerts only needed if using agent-based collection

### 5. Application Insights Monitoring
- Set availability thresholds based on SLAs
- Monitor response times for user experience
- Track failed requests for reliability
- Monitor exceptions for code quality

### 6. Multi-Workspace Scenarios
- Use centralized monitoring resource group
- Monitor all critical workspaces from one module
- Consider workspace-specific threshold overrides
- Use consistent naming conventions

## Troubleshooting

### No Alerts Firing
1. Verify monitoring resources exist in specified resource group
2. Check that resource names match exactly
3. Confirm Action Group is deployed and accessible
4. Verify resources are generating telemetry
5. Check alert enable flags are set to `true`

### Data Ingestion Alerts
1. Review workspace retention settings
2. Check for data ingestion spikes or anomalies
3. Verify diagnostic settings aren't over-collecting
4. Review data source configurations
5. Check for unexpected log volume increases

### Application Insights Alerts
1. Verify availability tests are configured
2. Check that application is sending telemetry
3. Review App Insights connection strings
4. Verify sampling isn't affecting metrics
5. Check for regional or network issues

### False Positives
1. Review and increase thresholds if too sensitive
2. Check for legitimate traffic spikes
3. Verify baseline calculations are accurate
4. Consider time-of-day patterns
5. Use dynamic thresholds for variable workloads

### DCR Alerts Not Working
1. Verify Data Collection Rules are deployed
2. Check that DCRs are associated with resources
3. Confirm agents are installed and running
4. Review DCR configuration and endpoints
5. Verify `enable_data_collection_alerts` is `true`

## Version Requirements

- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0

## Related Documentation

- [Azure Monitor Documentation](https://docs.microsoft.com/azure/azure-monitor/)
- [Log Analytics Workspaces](https://docs.microsoft.com/azure/azure-monitor/logs/log-analytics-workspace-overview)
- [Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [Data Collection Rules](https://docs.microsoft.com/azure/azure-monitor/essentials/data-collection-rule-overview)
- [Azure Monitor Metrics](https://docs.microsoft.com/azure/azure-monitor/essentials/metrics-supported)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review module documentation
3. Verify Azure resource configuration
4. Check Azure Monitor metrics in portal
5. Review workspace and App Insights telemetry
