# Azure Key Vault Monitoring Module - Examples

This directory contains example configurations for the Azure Key Vault monitoring module, demonstrating different deployment patterns for secrets management monitoring.

## Overview

The Azure Key Vault monitoring module provides comprehensive observability for Azure Key Vault instances, including:
- **Availability Monitoring**: Track Key Vault service availability
- **Performance Monitoring**: API latency and request volumes
- **Error Detection**: API errors and authentication failures
- **Capacity Management**: Saturation monitoring for vault limits
- **Security Monitoring**: Throttling and access pattern detection
- **Audit Logging**: Activity and security logs via diagnostic settings

## Examples

### 1. Production Deployment
**File**: See `main.tf` - Production example

High-sensitivity configuration optimized for production workloads with:
- Strict availability requirements (99.9%)
- Low latency tolerances (500ms)
- Aggressive error detection (5 API errors)
- Proactive saturation monitoring (75%)
- Cross-subscription diagnostic settings
- Comprehensive audit logging

**Best for**:
- Production environments
- Mission-critical secrets management
- Compliance-driven deployments
- High-security applications

**Key Features**:
- 99.9% availability threshold
- 500ms API latency threshold
- 2000 API hits monitoring
- 5 API error threshold
- 75% saturation alerting
- EventHub for activity logs (cross-subscription)
- Log Analytics for security logs (cross-subscription)

### 2. Development Deployment
**File**: See `main.tf` - Development example

Relaxed configuration for development and testing:
- Lower availability requirements (95%)
- Higher latency tolerances (2000ms)
- Increased error thresholds (20 errors)
- Same-subscription diagnostic settings
- Development-appropriate sensitivity

**Best for**:
- Development environments
- Testing and staging
- Cost-conscious monitoring
- Non-production workloads

**Key Features**:
- 95% availability threshold
- 2000ms API latency threshold
- 5000 API hits monitoring
- 20 API error threshold
- 85% saturation alerting
- Same-subscription diagnostic settings

### 3. Basic Deployment
**File**: See `main.tf` - Basic example

Minimal configuration using default thresholds:
- Default availability (99.9%)
- Default latency (1000ms)
- Default error thresholds
- No diagnostic settings
- Simplified monitoring footprint

**Best for**:
- Proof-of-concept deployments
- Quick setup requirements
- Testing the module
- Budget-constrained environments

**Key Features**:
- Default threshold values
- No diagnostic settings
- Minimal configuration overhead
- Essential monitoring only

## Alert Types

### Availability Alerts
Monitor Key Vault service availability:

| Alert | Metric | Default Threshold | Description |
|-------|--------|-------------------|-------------|
| KV Availability | Availability | 99.9% | Overall service availability |

**Severity**: Critical (1)  
**Frequency**: Every 1 minute  
**Window**: 5 minutes

### Performance Alerts
Track API performance and request volumes:

| Alert | Metric | Default Threshold | Description |
|-------|--------|-------------------|-------------|
| Service API Latency | ServiceApiLatency | 1000ms | Average API response time |
| Service API Hit | ServiceApiHit | 1000 | Total API request count |

**Latency Severity**: Warning (2)  
**Hit Severity**: Informational (3)

### Error Alerts
Detect API errors and authentication failures:

| Alert | Metric | Default Threshold | Description |
|-------|--------|-------------------|-------------|
| Service API Result Errors | ServiceApiResult | 10 | Failed API requests |
| Authentication Failures | ServiceApiResult | 5 | Authentication failure count |

**Severity**: Warning (2)  
**Operator**: Error status codes (4xx, 5xx)

### Capacity Alerts
Monitor vault capacity and saturation:

| Alert | Metric | Default Threshold | Description |
|-------|--------|-------------------|-------------|
| Saturation Shoebox | SaturationShoebox | 75% | Vault capacity utilization |

**Severity**: Warning (2)  
**Description**: Monitors vault storage limits and transaction quotas

### Security Alerts
Detect throttling and suspicious access patterns:

| Alert | Metric | Default Threshold | Description |
|-------|--------|-------------------|-------------|
| Throttling | ServiceApiResult | 10 | Rate limit exceeded events |

**Severity**: Warning (2)  
**Purpose**: Detect excessive request rates or potential attacks

## Diagnostic Settings

### Activity Logs (EventHub)
Sends Key Vault activity logs to Event Hub for:
- Real-time log streaming
- Integration with SIEM systems
- Long-term audit retention
- Cross-subscription support

**Log Categories**:
- AuditEvent (all Key Vault operations)
- AllMetrics (performance metrics)

### Security Logs (Log Analytics)
Sends security-focused logs to Log Analytics for:
- Advanced query capabilities
- Security analytics and alerting
- Compliance reporting
- Cross-subscription support

**Log Categories**:
- AuditEvent
- AllMetrics

## Usage

### Prerequisites
1. Azure subscription with Key Vault deployed
2. Existing Action Group for alert notifications
3. (Optional) Event Hub namespace for activity logs
4. (Optional) Log Analytics workspace for security logs

### Basic Usage

```hcl
module "keyvault_monitoring" {
  source = "path/to/module"

  # Resource identification
  resource_group_name              = "rg-keyvault-prod"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-prod-alerts"

  # Key Vault names to monitor
  key_vault_names = [
    "kv-app-prod-001",
    "kv-secrets-prod"
  ]

  # Custom thresholds
  availability_threshold        = 99.9
  service_api_latency_threshold = 500
  service_api_result_threshold  = 5

  # Tags
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### With Diagnostic Settings (Same Subscription)

```hcl
module "keyvault_monitoring" {
  source = "path/to/module"

  # Basic configuration
  resource_group_name              = "rg-keyvault-prod"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-prod-alerts"

  key_vault_names = ["kv-app-prod-001"]

  # Enable diagnostic settings
  enable_diagnostic_settings = true

  # EventHub for activity logs
  eventhub_namespace_name          = "evhns-logging-prod"
  eventhub_name                    = "evh-keyvault-logs"
  eventhub_resource_group_name     = "rg-logging"
  eventhub_authorization_rule_name = "RootManageSharedAccessKey"

  # Log Analytics for security logs
  log_analytics_workspace_name       = "law-security-prod"
  log_analytics_resource_group_name  = "rg-security"
}
```

### Cross-Subscription Diagnostic Settings

```hcl
module "keyvault_monitoring" {
  source = "path/to/module"

  # Basic configuration
  resource_group_name              = "rg-keyvault-prod"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-prod-alerts"

  key_vault_names = ["kv-app-prod-001"]

  # Enable diagnostic settings with cross-subscription targets
  enable_diagnostic_settings = true

  # EventHub in different subscription
  eventhub_subscription_id         = "87654321-4321-4321-4321-210987654321"
  eventhub_namespace_name          = "evhns-central-logging"
  eventhub_name                    = "evh-all-keyvault-logs"
  eventhub_resource_group_name     = "rg-central-logging"

  # Log Analytics in different subscription
  log_analytics_subscription_id      = "11111111-2222-3333-4444-555555555555"
  log_analytics_workspace_name       = "law-central-security"
  log_analytics_resource_group_name  = "rg-central-security"
}
```

### Multiple Key Vaults with Custom Thresholds

```hcl
module "keyvault_monitoring" {
  source = "path/to/module"

  resource_group_name              = "rg-keyvault-prod"
  action_group_resource_group_name = "rg-monitoring"
  action_group                     = "ag-prod-alerts"

  # Monitor multiple Key Vaults
  key_vault_names = [
    "kv-app-secrets-prod",
    "kv-app-certs-prod",
    "kv-database-keys-prod"
  ]

  # Strict production thresholds
  availability_threshold           = 99.99  # Four nines
  service_api_latency_threshold    = 300    # 300ms
  service_api_result_threshold     = 3      # Only 3 errors
  saturation_shoebox_threshold     = 70     # Alert at 70%

  # Enable diagnostic settings
  enable_diagnostic_settings = true
  eventhub_namespace_name    = "evhns-logging-prod"
  eventhub_name              = "evh-keyvault-logs"
  eventhub_resource_group_name = "rg-logging"

  log_analytics_workspace_name      = "law-security-prod"
  log_analytics_resource_group_name = "rg-security"

  tags = {
    Environment    = "Production"
    SecurityLevel  = "High"
    ComplianceType = "PCI-DSS"
  }
}
```

## Threshold Variables

All threshold variables support customization:

| Variable | Default | Description |
|----------|---------|-------------|
| `availability_threshold` | 99.9 | Availability percentage threshold |
| `service_api_latency_threshold` | 1000 | API latency in milliseconds |
| `service_api_hit_threshold` | 1000 | Total API request count |
| `service_api_result_threshold` | 10 | API error count threshold |
| `saturation_shoebox_threshold` | 75 | Vault capacity percentage |

## Outputs

The module provides comprehensive outputs:

```hcl
# Alert resource IDs (list)
output "alert_ids" {
  value = module.keyvault_monitoring.alert_ids
}

# Alert names (list)
output "alert_names" {
  value = module.keyvault_monitoring.alert_names
}

# Monitored Key Vaults
output "monitored_vaults" {
  value = module.keyvault_monitoring.monitored_key_vaults
}

# Alert summary (counts by type)
output "alert_summary" {
  value = module.keyvault_monitoring.alert_summary
}

# Diagnostic settings (if enabled)
output "diagnostic_settings" {
  value = module.keyvault_monitoring.diagnostic_settings
}
```

## Best Practices

### 1. Threshold Tuning
- Start with defaults and adjust based on baseline behavior
- Monitor alert frequency and adjust to reduce noise
- Set stricter thresholds for production environments
- Use relaxed thresholds for development/testing

### 2. Key Vault Organization
- Group Key Vaults by environment and sensitivity
- Use separate modules for different security tiers
- Consider vault-specific thresholds for high-traffic vaults
- Use tags to identify vault ownership and purpose

### 3. Security Monitoring
- Always enable diagnostic settings for production
- Monitor authentication failures closely
- Set aggressive thresholds for throttling alerts
- Use cross-subscription logging for security segregation

### 4. Capacity Planning
- Monitor saturation alerts for proactive scaling
- Track API hit patterns for quota planning
- Alert at 70-75% saturation to allow response time
- Review historical trends for capacity forecasting

### 5. Diagnostic Settings
- Use EventHub for real-time log streaming
- Use Log Analytics for security and compliance
- Consider cross-subscription for centralized logging
- Plan retention based on compliance requirements

### 6. High-Availability Scenarios
- Set availability threshold to 99.9% or higher
- Configure low latency thresholds (< 500ms)
- Monitor multiple vaults for redundancy validation
- Use geo-redundant diagnostic settings targets

## Troubleshooting

### No Alerts Firing
1. Verify Key Vaults exist in specified resource group
2. Check that Key Vault names match exactly
3. Confirm Action Group is deployed and accessible
4. Verify Key Vault has actual traffic/usage
5. Check alert thresholds aren't too permissive

### Availability Alerts
1. Check Key Vault service health in Azure Portal
2. Review Key Vault access policies and network rules
3. Verify no regional Azure outages
4. Check for firewall or NSG blocking access
5. Review Key Vault audit logs for failure patterns

### Latency Alerts
1. Check Key Vault region and client proximity
2. Review network latency between client and vault
3. Verify no excessive Key Vault operations
4. Check for complex access policies
5. Monitor Azure service health

### Diagnostic Settings Issues
1. Verify Event Hub namespace and hub exist
2. Confirm authorization rule has send permissions
3. Check Log Analytics workspace is accessible
4. Verify cross-subscription RBAC if used
5. Ensure `enable_diagnostic_settings` is `true`
6. Review Event Hub throughput units for capacity

### Saturation Alerts
1. Review Key Vault transaction quotas
2. Check vault storage limits (keys, secrets, certs)
3. Monitor API call rates against limits
4. Consider scaling or creating additional vaults
5. Review retention policies to free capacity

### Authentication Failure Alerts
1. Review Key Vault access policies
2. Check managed identity configurations
3. Verify service principal credentials
4. Review Azure AD conditional access policies
5. Check for expired certificates or secrets

## Version Requirements

- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0

## Related Documentation

- [Azure Key Vault Documentation](https://docs.microsoft.com/azure/key-vault/)
- [Azure Monitor Metrics](https://docs.microsoft.com/azure/azure-monitor/essentials/metrics-supported#microsoftkeyvaultvaults)
- [Key Vault Best Practices](https://docs.microsoft.com/azure/key-vault/general/best-practices)
- [Diagnostic Settings](https://docs.microsoft.com/azure/azure-monitor/essentials/diagnostic-settings)
- [Key Vault Monitoring](https://docs.microsoft.com/azure/key-vault/general/monitor-key-vault)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review module documentation
3. Verify Azure resource configuration
4. Check Azure Monitor metrics in portal
5. Review Key Vault audit logs for patterns
