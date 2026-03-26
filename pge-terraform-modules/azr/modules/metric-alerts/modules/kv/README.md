# Azure Key Vault Monitoring Alerts - Terraform Module

## Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Prerequisites](#prerequisites)
- [Module Structure](#module-structure)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Production Configuration](#production-configuration)
  - [Multi-Vault Deployment](#multi-vault-deployment)
  - [High-Security Configuration](#high-security-configuration)
- [Input Variables](#input-variables)
  - [Required Variables](#required-variables)
  - [Optional Variables](#optional-variables)
  - [Alert Configuration Variables](#alert-configuration-variables)
- [Alert Details](#alert-details)
  - [Availability and Performance Alerts](#availability-and-performance-alerts)
  - [API Request Alerts](#api-request-alerts)
  - [Capacity and Saturation Alerts](#capacity-and-saturation-alerts)
  - [Security Alerts](#security-alerts)
  - [Activity Log Alerts](#activity-log-alerts)
- [Alert Severity Levels](#alert-severity-levels)
- [Cost Analysis](#cost-analysis)
- [Best Practices](#best-practices)
  - [Security Best Practices](#security-best-practices)
  - [Performance Optimization](#performance-optimization)
  - [Access Control](#access-control)
  - [Monitoring and Auditing](#monitoring-and-auditing)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Validation Commands](#validation-commands)
- [License](#license)

---

## Overview

This Terraform module provides comprehensive monitoring and alerting for **Azure Key Vault**, Microsoft's cloud-based secrets management service for securely storing and accessing keys, secrets, certificates, and cryptographic operations. Key Vault is a critical security infrastructure component that centralizes application secrets, SSL/TLS certificates, and encryption keys with hardware security module (HSM) backing.

The module implements the **Azure Monitor Baseline Alerts (AMBA)** best practices specifically tailored for Key Vault, covering:
- **Availability monitoring** - Service health and uptime tracking
- **Performance monitoring** - API latency and response time
- **Request monitoring** - API hit rates and error tracking
- **Capacity monitoring** - Storage saturation and limits
- **Security monitoring** - Authentication failures, throttling, access policy changes
- **Administrative monitoring** - Key Vault deletion, key/secret/certificate operations

**Key Capabilities:**
- Monitors Key Vault availability and performance
- Detects API errors (4xx, 5xx) and authentication failures
- Tracks throttling events and rate limiting
- Monitors storage capacity saturation
- Alerts on security-critical operations (access policy changes, deletions)
- Tracks key, secret, and certificate lifecycle events

This module is essential for organizations managing:
- Application secrets and connection strings
- SSL/TLS certificates
- Database credentials and API keys
- Encryption keys and cryptographic operations
- OAuth tokens and service principal credentials
- Compliance-required secrets management (SOX, HIPAA, PCI-DSS)

---

## Key Features

- **✅ 10 Comprehensive Alerts** - Availability, performance, security, and administrative monitoring
- **✅ 1 Availability Alert** - Service uptime monitoring (99.9% default SLA)
- **✅ 1 Performance Alert** - API latency tracking
- **✅ 2 API Request Alerts** - Hit rate and error monitoring
- **✅ 1 Capacity Alert** - Storage saturation tracking
- **✅ 2 Security Alerts** - Authentication failures and throttling detection
- **✅ 3 Activity Log Alerts** - Access policy changes, deletions, key operations
- **✅ Multi-Vault Support** - Monitor multiple Key Vaults simultaneously
- **✅ Security-First Design** - Alerts on unauthorized access and policy changes
- **✅ Throttling Detection** - Identify rate limiting and capacity issues
- **✅ Customizable Thresholds** - All alert thresholds are configurable per environment
- **✅ Production-Ready** - Follows Azure AMBA guidelines for enterprise deployments

---

## Prerequisites

Before using this module, ensure you have:

1. **Terraform >= 1.0** installed
2. **Azure Provider >= 3.0** configured
3. **Existing Azure Key Vault(s)** deployed
4. **Azure Monitor Action Group** created for alert notifications
5. **Appropriate Azure RBAC permissions**:
   - `Key Vault Contributor` or `Monitoring Contributor` role on the resource group
   - `Reader` role on Key Vaults
   - Access to the action group for notifications

6. **Key Vault Requirements**:
   - Key Vault deployed with appropriate SKU (Standard or Premium)
   - Access policies or RBAC configured
   - Network rules configured (if using private endpoints)

7. **Recommended**:
   - Log Analytics workspace for diagnostic settings
   - Diagnostic settings enabled on Key Vault (AuditEvent category)

> **Note**: While metric alerts work without diagnostic settings, enabling diagnostic logs (AuditEvent category) is **strongly recommended** for security auditing, access tracking, and compliance requirements.

---

## Module Structure

```
kv/
├── alerts.tf       # Key Vault metric and activity log alert definitions
├── variables.tf    # Input variable definitions
└── README.md       # This documentation file
```

---

## Usage

### Basic Usage

```hcl
module "keyvault_alerts" {
  source = "./modules/metricAlerts/kv"

  # Key Vault configuration
  key_vault_names                    = ["kv-prod-secrets"]
  resource_group_name                = "rg-security-production"

  # Action group configuration
  action_group                       = "security-ops-actiongroup"
  action_group_resource_group_name   = "rg-monitoring"

  # Tags
  tags = {
    Environment        = "Production"
    Application        = "Secrets-Management"
    CostCenter         = "Security"
    DataClassification = "Confidential"
    Owner              = "security-team@company.com"
  }
}
```

### Production Configuration

```hcl
module "keyvault_alerts_prod" {
  source = "./modules/metricAlerts/kv"

  # Multiple Key Vaults
  key_vault_names = [
    "kv-prod-app-secrets",
    "kv-prod-certificates",
    "kv-prod-encryption-keys"
  ]

  resource_group_name                = "rg-security-production"

  # Action groups
  action_group                       = "security-critical-alerts"
  action_group_resource_group_name   = "rg-monitoring-prod"

  # Availability and Performance
  availability_threshold             = 99.95   # Stricter SLA
  service_api_latency_threshold      = 500     # 500ms latency

  # Request monitoring
  service_api_hit_threshold          = 5000    # 5K requests per 15 min
  service_api_result_threshold       = 5       # Low error tolerance

  # Capacity
  saturation_shoebox_threshold       = 70      # Alert at 70% capacity

  # Tags
  tags = {
    Environment        = "Production"
    Application        = "Enterprise-Security"
    CostCenter         = "Security-Operations"
    Compliance         = "SOX,HIPAA,PCI-DSS"
    DataClassification = "Highly-Confidential"
    DR                 = "Critical"
    Owner              = "security-ops@company.com"
    AlertingSLA        = "24x7"
    BackupPolicy       = "Daily"
  }
}
```

### Multi-Vault Deployment

```hcl
module "keyvault_alerts_multi_region" {
  source = "./modules/metricAlerts/kv"

  # Key Vaults across regions
  key_vault_names = [
    "kv-eastus-prod-secrets",
    "kv-westus-prod-secrets",
    "kv-centralus-prod-secrets",
    "kv-prod-certificates",
    "kv-prod-hsm-keys"
  ]

  resource_group_name                = "rg-keyvault-global"

  # Tiered action groups
  action_group                       = "keyvault-pagerduty"
  action_group_resource_group_name   = "rg-alerting"

  # Aggressive thresholds for production
  availability_threshold             = 99.99   # Four nines
  service_api_latency_threshold      = 300     # 300ms
  service_api_result_threshold       = 1       # Zero tolerance for errors
  saturation_shoebox_threshold       = 60      # Early warning at 60%

  tags = {
    Environment        = "Production"
    Application        = "Multi-Region-Secrets"
    BusinessUnit       = "Engineering"
    CostCenter         = "Platform"
    Compliance         = "SOC2,ISO27001"
    DataClassification = "Highly-Confidential"
    DR                 = "Mission-Critical"
    Owner              = "platform-security@company.com"
    SLA                = "99.99"
  }
}
```

### High-Security Configuration

```hcl
module "keyvault_alerts_high_security" {
  source = "./modules/metricAlerts/kv"

  # Premium HSM-backed Key Vault
  key_vault_names = [
    "kv-premium-hsm-keys",
    "kv-premium-pki-certs"
  ]

  resource_group_name                = "rg-security-premium"

  action_group                       = "security-incident-response"
  action_group_resource_group_name   = "rg-security-monitoring"

  # Zero-tolerance security settings
  availability_threshold             = 99.99
  service_api_latency_threshold      = 200     # Premium SLA
  service_api_result_threshold       = 1       # Immediate alert on any error
  saturation_shoebox_threshold       = 50      # Early capacity warning

  tags = {
    Environment        = "Production"
    Application        = "HSM-Cryptography"
    CostCenter         = "Security"
    Compliance         = "FIPS-140-2,PCI-DSS,HIPAA"
    DataClassification = "Restricted"
    SecurityZone       = "Tier-0"
    Owner              = "cryptography-team@company.com"
    IncidentResponse   = "Immediate"
    AuditRetention     = "7-years"
  }
}
```

---

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `key_vault_names` | `list(string)` | List of Key Vault names to monitor |
| `resource_group_name` | `string` | Resource group containing the Key Vaults |
| `action_group_resource_group_name` | `string` | Resource group containing the action group |
| `action_group` | `string` | Name of the Azure Monitor action group for notifications |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `location` | `string` | `"West US 3"` | Azure region for scheduled query rules |
| `tags` | `map(string)` | See variables.tf | Resource tags for organization and cost tracking |

### Alert Configuration Variables

#### Availability and Performance Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `availability_threshold` | `number` | `99.9` | Key Vault availability percentage threshold (99.9% = SLA) |
| `service_api_latency_threshold` | `number` | `1000` | Service API latency threshold in milliseconds |

#### Request Monitoring Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `service_api_hit_threshold` | `number` | `1000` | Service API hit rate threshold (requests per window) |
| `service_api_result_threshold` | `number` | `10` | Service API error threshold (4xx/5xx errors) |

#### Capacity Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `saturation_shoebox_threshold` | `number` | `75` | Storage saturation percentage threshold (0-100%) |

#### Activity Log Thresholds

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `key_vault_access_policy_change_threshold` | `number` | `1` | Threshold for access policy change events |
| `key_vault_delete_threshold` | `number` | `1` | Threshold for Key Vault deletion events |

---

## Alert Details

### Availability and Performance Alerts

#### 1. Key Vault Availability Alert
- **Metric**: `Availability`
- **Threshold**: 99.9% (default)
- **Severity**: 1 (Error)
- **Frequency**: PT1M
- **Window**: PT5M
- **Aggregation**: Average
- **Description**: **CRITICAL** - Monitors Key Vault service availability and uptime
- **Use Case**: SLA compliance, service health monitoring

**What to do when this alert fires:**
```bash
# Check Key Vault health
az keyvault show \
  --name <key-vault-name> \
  --query "{name:name, location:location, provisioningState:properties.provisioningState}"

# Check availability metrics
az monitor metrics list \
  --resource <key-vault-resource-id> \
  --metric "Availability" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average

# Check Azure service health
az rest --method get \
  --url "https://management.azure.com/subscriptions/<subscription-id>/providers/Microsoft.ResourceHealth/availabilityStatuses?api-version=2020-05-01"

# Check Key Vault operations
az monitor activity-log list \
  --resource-id <key-vault-resource-id> \
  --start-time <start-time> \
  --query "[?contains(operationName.localizedValue, 'Key Vault')]"

# Actions (URGENT):
# 1. Verify Azure service health status
# 2. Check for regional outages
# 3. Review recent configuration changes
# 4. Test Key Vault connectivity
# 5. Check network security rules
# 6. Verify DNS resolution
# 7. Review firewall rules
# 8. Contact Azure support if service-side issue
```

#### 2. Service API Latency Alert
- **Metric**: `ServiceApiLatency`
- **Threshold**: 1,000ms (default)
- **Severity**: 2 (Warning)
- **Frequency**: PT5M
- **Window**: PT15M
- **Aggregation**: Average
- **Description**: Monitors Key Vault API response time performance
- **Use Case**: Performance monitoring, user experience

**What to do when this alert fires:**
```bash
# Check API latency metrics
az monitor metrics list \
  --resource <key-vault-resource-id> \
  --metric "ServiceApiLatency" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average Maximum

# Query diagnostic logs for slow operations
az monitor diagnostic-settings list \
  --resource <key-vault-resource-id>

# Check for throttling
az monitor metrics list \
  --resource <key-vault-resource-id> \
  --metric "ServiceApiResult" \
  --filter "StatusCode eq '429'"

# Actions:
# 1. Check for high request volume (throttling)
# 2. Review network latency to Key Vault
# 3. Check if using private endpoints (reduces latency)
# 4. Verify client connection pooling
# 5. Review cryptographic operations (HSM-backed keys are slower)
# 6. Check for regional performance issues
# 7. Consider Premium SKU for better performance
# 8. Implement caching for frequently accessed secrets
```

### API Request Alerts

#### 3. Service API Hit Rate Alert
- **Metric**: `ServiceApiHit`
- **Threshold**: 1,000 requests (default)
- **Severity**: 3 (Informational)
- **Frequency**: PT5M
- **Window**: PT15M
- **Aggregation**: Total
- **Description**: Monitors total API request volume to Key Vault
- **Use Case**: Capacity planning, usage trending

**What to do when this alert fires:**
```bash
# Check API hit metrics
az monitor metrics list \
  --resource <key-vault-resource-id> \
  --metric "ServiceApiHit" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Total

# Break down by operation type (via diagnostic logs)
# Enable diagnostic settings if not already enabled
az monitor diagnostic-settings create \
  --name "kv-diagnostics" \
  --resource <key-vault-resource-id> \
  --workspace <log-analytics-workspace-id> \
  --logs '[{"category": "AuditEvent", "enabled": true}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'

# Query Log Analytics for operation breakdown
# KQL Query:
# AzureDiagnostics
# | where ResourceProvider == "MICROSOFT.KEYVAULT"
# | where TimeGenerated > ago(1h)
# | summarize count() by OperationName
# | order by count_ desc

# Actions:
# 1. Verify traffic spike is expected (new deployment, scaling)
# 2. Check for request loops or excessive polling
# 3. Review application retry logic
# 4. Implement caching for frequently accessed secrets
# 5. Monitor for approaching throttling limits
# 6. Consider request batching where possible
# 7. Review API call patterns for optimization
```

#### 4. Service API Result Errors Alert
- **Metric**: `ServiceApiResult`
- **Threshold**: 10 errors (default)
- **Severity**: 1 (Error)
- **Frequency**: PT1M
- **Window**: PT5M
- **Aggregation**: Total
- **Dimensions**: StatusCode (4xx, 5xx)
- **Description**: **CRITICAL** - Monitors API errors (client and server errors)
- **Use Case**: Error detection, service health

**What to do when this alert fires:**
```bash
# Check error metrics by status code
az monitor metrics list \
  --resource <key-vault-resource-id> \
  --metric "ServiceApiResult" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Total \
  --filter "StatusCode eq '4xx' or StatusCode eq '5xx'"

# Query detailed error logs
# KQL Query in Log Analytics:
# AzureDiagnostics
# | where ResourceProvider == "MICROSOFT.KEYVAULT"
# | where TimeGenerated > ago(1h)
# | where httpStatusCode_d >= 400
# | summarize count() by httpStatusCode_d, OperationName, CallerIPAddress
# | order by count_ desc

# Common error codes:
# 400 - Bad Request (malformed request)
# 401 - Unauthorized (authentication failed)
# 403 - Forbidden (insufficient permissions)
# 404 - Not Found (key/secret/certificate doesn't exist)
# 429 - Too Many Requests (throttling)
# 500 - Internal Server Error
# 503 - Service Unavailable

# Actions (URGENT for 5xx errors):
# 1. Identify error types (4xx vs 5xx)
# 2. For 4xx errors: Review access policies and permissions
# 3. For 5xx errors: Check Azure service health
# 4. Review recent application deployments
# 5. Check for deleted keys/secrets still being referenced
# 6. Verify access policy configuration
# 7. Check for expired certificates
# 8. Review network connectivity
```

### Capacity and Saturation Alerts

#### 5. Saturation Shoebox Alert
- **Metric**: `SaturationShoebox`
- **Threshold**: 75% (default)
- **Severity**: 2 (Warning)
- **Frequency**: PT15M
- **Window**: PT1H
- **Aggregation**: Average
- **Description**: Monitors Key Vault storage capacity utilization
- **Use Case**: Capacity planning, storage limit management

**What to do when this alert fires:**
```bash
# Check saturation metrics
az monitor metrics list \
  --resource <key-vault-resource-id> \
  --metric "SaturationShoebox" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average Maximum

# List all keys, secrets, and certificates
az keyvault key list --vault-name <key-vault-name> --query "length(@)"
az keyvault secret list --vault-name <key-vault-name> --query "length(@)"
az keyvault certificate list --vault-name <key-vault-name> --query "length(@)"

# Check for old versions
az keyvault key list-versions --vault-name <key-vault-name> --name <key-name>
az keyvault secret list-versions --vault-name <key-vault-name> --name <secret-name>

# Key Vault limits:
# - Standard: 25,000 transactions per 10 seconds per vault
# - Premium: Same transaction limits
# - Soft-delete retention: 7-90 days (default 90)
# - Key/Secret/Certificate size: 25 KB max
# - Maximum storage: Not explicitly documented (varies)

# Actions:
# 1. Audit Key Vault contents
# 2. Delete unused keys, secrets, and certificates
# 3. Purge soft-deleted items if safe to do so
# 4. Review secret/key rotation policies
# 5. Consider creating additional Key Vaults (sharding)
# 6. Archive old secrets to Azure Storage
# 7. Implement lifecycle management
# 8. Clean up old certificate versions
```

### Security Alerts

#### 6. Authentication Failures Alert
- **Metric**: `ServiceApiResult`
- **Threshold**: 5 failures (hardcoded)
- **Severity**: 1 (Error)
- **Frequency**: PT1M
- **Window**: PT5M
- **Aggregation**: Total
- **Dimensions**: StatusCode (401, 403)
- **Description**: **CRITICAL** - Detects authentication and authorization failures
- **Use Case**: Security monitoring, unauthorized access detection

**What to do when this alert fires:**
```bash
# Query authentication failures
# KQL Query:
# AzureDiagnostics
# | where ResourceProvider == "MICROSOFT.KEYVAULT"
# | where TimeGenerated > ago(1h)
# | where httpStatusCode_d in (401, 403)
# | project TimeGenerated, CallerIPAddress, OperationName, 
#           id_s, identity_claim_appid_g, resultSignature_s
# | order by TimeGenerated desc

# Check access policies
az keyvault show \
  --name <key-vault-name> \
  --query "properties.accessPolicies"

# Check network rules
az keyvault network-rule list \
  --name <key-vault-name>

# Actions (URGENT):
# 1. Identify source of failed authentication attempts
# 2. Check for compromised credentials
# 3. Review CallerIPAddress for suspicious sources
# 4. Verify application identity configuration
# 5. Check Managed Identity assignments
# 6. Review access policies for accuracy
# 7. Check for expired service principals
# 8. Implement IP restrictions if attacks detected
# 9. Rotate credentials if compromise suspected
# 10. Escalate to security team if malicious activity
```

#### 7. Throttling Alert
- **Metric**: `ServiceApiResult`
- **Threshold**: 0 (any throttling event)
- **Severity**: 2 (Warning)
- **Frequency**: PT1M
- **Window**: PT5M
- **Aggregation**: Total
- **Dimensions**: StatusCode (429)
- **Description**: Detects when requests are being throttled due to rate limits
- **Use Case**: Capacity management, rate limiting detection

**What to do when this alert fires:**
```bash
# Check throttling events
# KQL Query:
# AzureDiagnostics
# | where ResourceProvider == "MICROSOFT.KEYVAULT"
# | where TimeGenerated > ago(1h)
# | where httpStatusCode_d == 429
# | project TimeGenerated, CallerIPAddress, OperationName, 
#           requestUri_s, identity_claim_appid_g
# | summarize Count = count() by OperationName, CallerIPAddress
# | order by Count desc

# Key Vault throttling limits:
# - 2,000 GET/LIST operations per 10 seconds per vault
# - 2,000 all other operations per 10 seconds per vault
# - 5,000 operations per 10 seconds per vault (total)

# Actions:
# 1. Identify which operations are being throttled
# 2. Implement exponential backoff in application
# 3. Reduce request rate from applications
# 4. Implement caching for GET operations
# 5. Batch operations where possible
# 6. Distribute load across multiple Key Vaults
# 7. Review connection pooling
# 8. Check for request loops
# 9. Optimize secret retrieval patterns
# 10. Consider Key Vault sharding for high-volume scenarios
```

### Activity Log Alerts

#### 8. Key Vault Access Policy Change Alert
- **Operation**: `Microsoft.KeyVault/vaults/accessPolicies/write`
- **Category**: Administrative
- **Severity**: Informational (implied)
- **Description**: Tracks changes to Key Vault access policies
- **Use Case**: Security auditing, change tracking, compliance

**What to do when this alert fires:**
```bash
# Query access policy changes
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?operationName.localizedValue == 'Update vault access policy']"

# Get current access policies
az keyvault show \
  --name <key-vault-name> \
  --query "properties.accessPolicies" \
  --output table

# Review who made the change
az monitor activity-log list \
  --resource-id <key-vault-resource-id> \
  --start-time <start-time> \
  --query "[?operationName.localizedValue == 'Update vault access policy'].{Time:eventTimestamp, User:caller, Status:status.localizedValue}"

# Actions:
# 1. Verify change was authorized
# 2. Document in change management system
# 3. Review what permissions were added/removed
# 4. Verify least-privilege principle
# 5. Check for excessive permissions
# 6. Audit who was granted access
# 7. Ensure compliance with security policies
# 8. Review for separation of duties violations
```

#### 9. Key Vault Deletion Alert
- **Operation**: `Microsoft.KeyVault/vaults/delete`
- **Category**: Administrative
- **Severity**: Critical (implied)
- **Description**: **CRITICAL** - Detects Key Vault deletion events
- **Use Case**: Accidental deletion prevention, security incident detection

**What to do when this alert fires:**
```bash
# Verify deletion
az monitor activity-log list \
  --resource-group <resource-group> \
  --start-time <start-time> \
  --query "[?operationName.localizedValue == 'Delete Key Vault']"

# Check soft-delete status (Key Vaults are soft-deleted by default)
az keyvault list-deleted --query "[?name=='<key-vault-name>']"

# Recover soft-deleted Key Vault (if within retention period)
az keyvault recover \
  --name <key-vault-name> \
  --location <location>

# Actions (URGENT):
# 1. Verify if deletion was authorized
# 2. Identify who deleted the Key Vault
# 3. If accidental: Recover from soft-delete immediately
# 4. If malicious: Escalate to security team
# 5. Review RBAC permissions
# 6. Check for compromised credentials
# 7. Restore from soft-delete (7-90 day retention)
# 8. If purged: Restore from backup/IaC
# 9. Document incident
# 10. Implement additional RBAC controls
```

#### 10. Key/Secret/Certificate Operations Alert
- **Operation**: `Microsoft.KeyVault/vaults/keys/delete`
- **Category**: Administrative
- **Severity**: Warning (implied)
- **Description**: Tracks critical operations on keys, secrets, and certificates
- **Use Case**: Audit trail, security monitoring, compliance

**What to do when this alert fires:**
```bash
# Query key operations
az monitor activity-log list \
  --resource-id <key-vault-resource-id> \
  --start-time <start-time> \
  --query "[?contains(operationName.localizedValue, 'key') || contains(operationName.localizedValue, 'secret') || contains(operationName.localizedValue, 'certificate')]"

# Check for deleted keys/secrets/certificates
az keyvault key list-deleted --vault-name <key-vault-name>
az keyvault secret list-deleted --vault-name <key-vault-name>
az keyvault certificate list-deleted --vault-name <key-vault-name>

# Recover deleted item (if soft-deleted)
az keyvault key recover --vault-name <key-vault-name> --name <key-name>
az keyvault secret recover --vault-name <key-vault-name> --name <secret-name>
az keyvault certificate recover --vault-name <key-vault-name> --name <cert-name>

# Actions:
# 1. Verify operation was authorized
# 2. Check who performed the operation
# 3. Document in audit log
# 4. If deletion: Verify impact on applications
# 5. Recover deleted items if needed (soft-delete)
# 6. Update dependent applications if key/secret changed
# 7. Review for compliance violations
# 8. Check for unauthorized access
```

---

## Alert Severity Levels

| Severity | Level | Use Case | Example Alerts |
|----------|-------|----------|----------------|
| **0** | Critical | Service outage, complete failure | None in this module |
| **1** | Error | Functional failures, security incidents | Availability, API Errors, Authentication Failures |
| **2** | Warning | Performance degradation, approaching limits | API Latency, Throttling, Saturation |
| **3** | Informational | Awareness, trend monitoring | API Hit Rate |
| **4** | Verbose | Detailed diagnostics | None in this module |

**Severity Guidelines:**
- **Severity 1** alerts require **immediate incident response** (security, availability)
- **Severity 2** alerts require **timely response** (performance, capacity)
- **Severity 3** alerts are **informational** (trends, usage patterns)
- **Activity Log** alerts are critical for **security auditing** and **compliance**

---

## Cost Analysis

### Alert Costs

**Azure Monitor Pricing (as of 2024):**
- Metric Alerts: **$0.10 per month** per alert rule
- Activity Log Alerts: **FREE**

**This Module Cost Calculation:**
- **7 Metric Alerts** per Key Vault
- **3 Activity Log Alerts** (FREE, shared across all Key Vaults)

**Cost per Key Vault:**
- Metric alerts: 7 × $0.10 = **$0.70/month** per Key Vault
- Activity log alerts: **$0.00/month** (FREE)

**Example Deployment Costs:**
- **1 Key Vault**: 7 alerts = **$0.70/month**
- **3 Key Vaults**: 3 × $0.70 = **$2.10/month**
- **10 Key Vaults**: 10 × $0.70 = **$7.00/month**
- **Annual cost (3 Key Vaults)**: **$25.20/year**

### Key Vault Costs

**Azure Key Vault Pricing:**

**Standard Tier:**
- **Secret operations**: $0.03 per 10,000 transactions
- **Key operations**: $0.03 per 10,000 transactions
- **Certificate operations**: $0.03 per 10,000 transactions
- **Advanced key types** (RSA 3K, 4K): $1.00 per month per key

**Premium Tier (HSM-backed):**
- **HSM-protected keys**: $5.00 per month per key
- **HSM operations**: $0.03 per 10,000 transactions
- **FIPS 140-2 Level 2** validated

**Example Monthly Costs:**
```
Scenario 1: Standard - Low Volume
- 100K secret operations: (100,000 / 10,000) × $0.03 = $0.30
- 10K key operations: (10,000 / 10,000) × $0.03 = $0.03
- Total: $0.33/month + monitoring ($0.70)

Scenario 2: Standard - Moderate Volume
- 1M secret operations: (1,000,000 / 10,000) × $0.03 = $3.00
- 100K key operations: (100,000 / 10,000) × $0.03 = $0.30
- 5 RSA-4K keys: 5 × $1.00 = $5.00
- Total: $8.30/month + monitoring ($0.70)

Scenario 3: Premium - High Security
- 10 HSM-protected keys: 10 × $5.00 = $50.00
- 500K HSM operations: (500,000 / 10,000) × $0.03 = $1.50
- Total: $51.50/month + monitoring ($0.70)
```

### ROI Analysis

**Scenario: Production Key Vault (3M Operations/Month)**

**Without Monitoring:**
- Average downtime per incident: 2 hours
- Incidents per month: 2
- Revenue loss: $50,000/hour (service outage)
- Security breach cost: $100,000+ (credential exposure)
- **Monthly loss**: 2 hours × 2 incidents × $50,000 = **$200,000**

**With Comprehensive Monitoring:**
- Alert cost: $0.70/month per Key Vault
- Early detection reduces MTTR by 80% (2 hours → 24 minutes)
- Prevented downtime: 1.6 hours × 2 incidents = 3.2 hours
- Security incident prevention: 1 breach avoided
- **Monthly savings**: (3.2 hours × $50,000) + $100,000 = **$260,000**

**ROI Calculation:**
```
Monthly Investment: $0.70
Monthly Benefit: $260,000
Monthly Net Benefit: $259,999.30
ROI: (259,999.30 / 0.70) × 100 = 37,142,757%
Annual ROI: $3,119,991.60 savings vs $8.40 cost
```

**Additional Benefits:**
- Prevents authentication failure cascades
- Detects capacity issues before throttling
- Immediate alert on security policy changes
- Compliance audit trail for SOX, HIPAA, PCI-DSS
- Early warning on saturation issues
- Faster incident resolution

---

## Best Practices

### 1. Diagnostic Settings Configuration

For comprehensive security monitoring and compliance, enable diagnostic settings on your Key Vault resources. While metric alerts monitor performance thresholds, diagnostic settings provide critical audit logs for access tracking and security investigations.

#### Required Diagnostic Settings

```bash
# Enable diagnostic settings for Key Vault via Azure CLI
az monitor diagnostic-settings create \
  --name "keyvault-diagnostics" \
  --resource "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.KeyVault/vaults/{vault-name}" \
  --workspace "/subscriptions/{subscription-id}/resourceGroups/{workspace-rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}" \
  --logs '[
    {"category":"AuditEvent","enabled":true,"retentionPolicy":{"days":90,"enabled":true}}
  ]' \
  --metrics '[
    {"category":"AllMetrics","enabled":true,"retentionPolicy":{"days":30,"enabled":true}}
  ]'
```

#### Terraform Example for Diagnostic Settings

```hcl
resource "azurerm_monitor_diagnostic_setting" "keyvault_diagnostics" {
  for_each                   = toset(var.key_vault_names)
  name                       = "kv-diagnostics-${each.key}"
  target_resource_id         = data.azurerm_key_vault.vaults[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Audit Events - CRITICAL for security and compliance
  enabled_log {
    category = "AuditEvent"
  }

  # All Metrics
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

#### Log Categories Explained

| Category | Purpose | When to Enable | Retention |
|----------|---------|----------------|-----------|
| **AuditEvent** | All Key Vault operations, access attempts, authentication events | **Always** - CRITICAL for security | 90+ days (compliance) |

#### Useful Log Analytics Queries

```kusto
// Failed authentication attempts (security threat detection)
AzureDiagnostics
| where ResourceType == "VAULTS"
| where TimeGenerated > ago(24h)
| where ResultType != "Success"
| summarize FailureCount = count() by CallerIPAddress, ResultType, OperationName
| order by FailureCount desc

// Secret access audit trail
AzureDiagnostics
| where ResourceType == "VAULTS"
| where OperationName == "SecretGet"
| where TimeGenerated > ago(7d)
| project TimeGenerated, CallerIPAddress, identity_claim_appid_g, id_s, ResultType
| order by TimeGenerated desc

// Certificate expiration monitoring
AzureDiagnostics
| where ResourceType == "VAULTS"
| where OperationName == "CertificateNearExpiry"
| where TimeGenerated > ago(30d)
| project TimeGenerated, Resource, CertificateName = id_s, ExpiryDate = properties_expiryDate_t
| order by ExpiryDate asc

// API saturation analysis
AzureDiagnostics
| where ResourceType == "VAULTS"
| where TimeGenerated > ago(1h)
| summarize RequestCount = count() by bin(TimeGenerated, 5m), OperationName
| where RequestCount > 1000
| order by TimeGenerated desc

// Unauthorized access attempts
AzureDiagnostics
| where ResourceType == "VAULTS"
| where ResultType == "Unauthorized"
| where TimeGenerated > ago(24h)
| summarize AttemptCount = count() by CallerIPAddress, identity_claim_upn_s
| order by AttemptCount desc
```

### 2. Security Best Practices

#### Access Control
- Use **Azure RBAC** (Role-Based Access Control) over access policies
- Implement **least-privilege** access principle
- Use **Managed Identities** for application access
- Avoid storing access keys in code
- Separate Key Vaults by environment (dev, test, prod)

#### Network Security
- Enable **firewall and virtual networks**
- Use **Private Endpoints** for VNet integration
- Restrict public access to specific IPs
- Disable public access for production Key Vaults
- Use **service endpoints** for Azure services

#### Soft Delete and Purge Protection
- Enable **soft delete** (enabled by default)
- Enable **purge protection** for production
- Set retention period to 90 days (maximum)
- Regularly test recovery procedures
- Document recovery playbooks

#### Secrets Management
- Rotate secrets regularly (automated rotation recommended)
- Use **certificate auto-renewal** where possible
- Set expiration dates on all secrets
- Monitor for expiring certificates (this module includes alert)
- Never hard-code secrets in applications

### 3. Alert Response Procedures

#### Severity 0 (Critical) - Immediate Response
- **Key Vault Deleted** → Initiate recovery process immediately, notify security team

**Response Time**: < 5 minutes  
**Escalation**: Page on-call engineer + security team + management

#### Severity 1 (Error) - Immediate Response
- **High Availability < 99%** → Check service health, verify network connectivity
- **High Authentication Failures** → Investigate security threat, review access logs
- **API Saturation** → Implement caching, optimize requests, plan tier upgrade

**Response Time**: < 15 minutes  
**Escalation**: Page on-call engineer + security team

#### Severity 2 (Warning) - Review Within 1 Hour
- **High Latency** → Review request patterns, check for throttling
- **4xx Client Errors** → Investigate application issues, review permissions

**Response Time**: < 1 hour  
**Escalation**: Email ops team

#### Activity Log Alerts (Informational) - Review During Business Hours
- **Access Policy Changes** → Audit trail review
- **Key/Secret/Certificate Operations** → Change management verification

**Response Time**: Next business day  
**Escalation**: Log for security review

### 4. Monitoring Checklist

#### Initial Setup
- [ ] Enable diagnostic settings on ALL Key Vaults (CRITICAL for security)
- [ ] Configure Log Analytics workspace with 90+ day retention for audit logs
- [ ] Set up action groups with security team
- [ ] Customize alert thresholds based on usage patterns
- [ ] Test alert notifications to verify delivery
- [ ] Document incident response procedures
- [ ] Enable soft delete and purge protection

#### Ongoing Operations
- [ ] Review authentication failures daily
- [ ] Analyze audit logs weekly for anomalies
- [ ] Review alert thresholds monthly
- [ ] Update alert rules for new Key Vaults
- [ ] Validate action group membership monthly
- [ ] Conduct security reviews quarterly
- [ ] Test Key Vault recovery procedures quarterly

#### Security & Compliance
- [ ] Audit access patterns for suspicious activity
- [ ] Review and rotate secrets regularly (90-day cycle recommended)
- [ ] Monitor certificate expiration proactively (30+ day warning)
- [ ] Maintain audit logs for compliance (SOX, HIPAA, PCI-DSS)
- [ ] Document all Key Vault access for security audits
- [ ] Review and update RBAC permissions quarterly

### Performance Optimization (Continued)
   - Cache frequently accessed secrets (not sensitive data)
   - Use application-level caching (30-60 minutes)
   - Implement cache invalidation strategies
   - Reduce Key Vault API calls
   - Use Azure App Configuration for non-sensitive config

2. **Connection Management**
   - Reuse Key Vault client instances
   - Implement connection pooling
   - Use async operations where possible
   - Batch operations when supported
   - Implement retry logic with exponential backoff

3. **Request Optimization**
   - Minimize GET operations (use caching)
   - Batch certificate imports
   - Use LIST operations judiciously
   - Implement request throttling in application
   - Monitor for approaching rate limits

4. **Premium Tier Considerations**
   - Use Premium for HSM-backed keys
   - Premium for FIPS 140-2 Level 2 compliance
   - Better performance for cryptographic operations
   - Required for regulated industries (finance, healthcare)

### Access Control

1. **RBAC Roles**
   - **Key Vault Administrator**: Full control (admin only)
   - **Key Vault Secrets Officer**: Manage secrets (apps)
   - **Key Vault Secrets User**: Read secrets (apps, read-only)
   - **Key Vault Crypto Officer**: Manage keys
   - **Key Vault Crypto User**: Perform crypto operations
   - **Key Vault Certificates Officer**: Manage certificates

2. **Access Policies (Legacy)**
   - Migrate to RBAC when possible
   - Separate permissions (keys, secrets, certificates)
   - Limit to specific operations
   - Regular access reviews
   - Remove unused policies

3. **Managed Identities**
   - Use system-assigned identities where possible
   - User-assigned for shared scenarios
   - No credential management required
   - Automatic rotation
   - Audit trail in activity logs

### Monitoring and Auditing

1. **Diagnostic Settings**
   - Enable **AuditEvent** logs
   - Send to Log Analytics workspace
   - Enable **AllMetrics**
   - Set retention period (compliance requirement)
   - Create custom KQL queries

2. **Log Analytics Queries**
   ```kql
   // Failed authentication attempts
   AzureDiagnostics
   | where ResourceProvider == "MICROSOFT.KEYVAULT"
   | where httpStatusCode_d in (401, 403)
   | summarize count() by CallerIPAddress, identity_claim_appid_g
   | order by count_ desc

   // Top operations
   AzureDiagnostics
   | where ResourceProvider == "MICROSOFT.KEYVAULT"
   | summarize count() by OperationName
   | order by count_ desc

   // Slow operations
   AzureDiagnostics
   | where ResourceProvider == "MICROSOFT.KEYVAULT"
   | where DurationMs > 1000
   | project TimeGenerated, OperationName, DurationMs, CallerIPAddress
   | order by DurationMs desc
   ```

3. **Compliance and Audit**
   - Enable Azure Policy for Key Vault
   - Implement compliance policies (soft-delete required)
   - Regular access reviews
   - Audit log retention (7 years for SOX)
   - Automated compliance reporting

4. **Certificate Management**
   - Monitor certificate expiration
   - Automate certificate renewal
   - Set up expiration alerts (30, 15, 7 days)
   - Use Let's Encrypt or managed certificates
   - Document certificate rotation procedures

---

## Troubleshooting

### Common Issues

#### Issue 1: Alerts Not Firing Despite Breaching Thresholds

**Symptoms:**
- Metrics exceed thresholds but no alerts triggered
- Alert state shows "Not Activated"

**Troubleshooting Steps:**
```bash
# 1. Verify Key Vault exists
az keyvault show --name <key-vault-name>

# 2. Verify alert is enabled
az monitor metrics alert show \
  --resource-group <resource-group> \
  --name "kv-availability-<name>" \
  --query "enabled"

# 3. Check metric availability
az monitor metrics list-definitions \
  --resource <key-vault-resource-id> \
  --query "[?namespace=='Microsoft.KeyVault/vaults']"

# 4. Verify action group
az monitor action-group show \
  --resource-group <action-group-rg> \
  --name <action-group-name>
```

**Common Causes:**
- Key Vault not receiving traffic (no metrics)
- Wrong Key Vault name in variables
- Alert disabled
- Action group email not confirmed
- Metric not available in region

**Resolution:**
```hcl
# Verify Key Vault names
key_vault_names = ["actual-kv-name"]

# Confirm action group emails
```

---

#### Issue 2: High Authentication Failures

**Symptoms:**
- Authentication failures alert firing frequently
- 401/403 errors in logs

**Troubleshooting Steps:**
```bash
# Check authentication errors
# KQL Query:
# AzureDiagnostics
# | where ResourceProvider == "MICROSOFT.KEYVAULT"
# | where httpStatusCode_d in (401, 403)
# | summarize count() by CallerIPAddress, identity_claim_appid_g, OperationName
# | order by count_ desc

# Check access policies
az keyvault show \
  --name <key-vault-name> \
  --query "properties.accessPolicies"

# Check network rules
az keyvault network-rule list --name <key-vault-name>
```

**Common Causes:**
- Missing or incorrect access policies
- Expired service principal
- Managed Identity not assigned
- Network rules blocking access
- Wrong Key Vault URL

**Resolution:**
```bash
# Grant access policy
az keyvault set-policy \
  --name <key-vault-name> \
  --object-id <service-principal-object-id> \
  --secret-permissions get list

# Assign Managed Identity RBAC role
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee <managed-identity-principal-id> \
  --scope <key-vault-resource-id>

# Add IP to network rules
az keyvault network-rule add \
  --name <key-vault-name> \
  --ip-address <ip-address>
```

---

#### Issue 3: Throttling Errors (429)

**Symptoms:**
- Throttling alert firing
- 429 status codes in logs
- Intermittent failures

**Troubleshooting Steps:**
```bash
# Check throttling metrics
az monitor metrics list \
  --resource <key-vault-resource-id> \
  --metric "ServiceApiResult" \
  --filter "StatusCode eq '429'" \
  --start-time <start-time> \
  --end-time <end-time>

# Query throttling events
# KQL Query:
# AzureDiagnostics
# | where ResourceProvider == "MICROSOFT.KEYVAULT"
# | where httpStatusCode_d == 429
# | summarize count() by OperationName, CallerIPAddress
# | order by count_ desc
```

**Common Causes:**
- Excessive request rate (>5,000 per 10 sec)
- No request throttling in application
- Lack of caching
- Request loops
- Multiple instances hammering Key Vault

**Resolution:**
```python
# Implement exponential backoff
import time
from azure.core.exceptions import ResourceExistsError

def get_secret_with_retry(secret_client, secret_name, max_retries=5):
    for attempt in range(max_retries):
        try:
            return secret_client.get_secret(secret_name)
        except ResourceExistsError as e:
            if e.status_code == 429:
                wait_time = 2 ** attempt  # Exponential backoff
                time.sleep(wait_time)
            else:
                raise
    raise Exception("Max retries exceeded")

# Implement caching
from functools import lru_cache
import time

@lru_cache(maxsize=100)
def get_cached_secret(secret_name, cache_time):
    # cache_time is used to invalidate cache
    return secret_client.get_secret(secret_name).value

# Use with:
secret = get_cached_secret("my-secret", int(time.time() / 1800))  # 30 min cache
```

---

#### Issue 4: Saturation Warning

**Symptoms:**
- Saturation shoebox alert firing
- Approaching storage limits

**Troubleshooting Steps:**
```bash
# Check saturation level
az monitor metrics list \
  --resource <key-vault-resource-id> \
  --metric "SaturationShoebox" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average Maximum

# Count objects
az keyvault key list --vault-name <key-vault-name> --query "length(@)"
az keyvault secret list --vault-name <key-vault-name> --query "length(@)"
az keyvault certificate list --vault-name <key-vault-name> --query "length(@)"

# Check soft-deleted items
az keyvault key list-deleted --vault-name <key-vault-name>
az keyvault secret list-deleted --vault-name <key-vault-name>
az keyvault certificate list-deleted --vault-name <key-vault-name>
```

**Common Causes:**
- Too many secrets/keys/certificates
- Old versions not cleaned up
- Soft-deleted items accumulating
- No lifecycle management

**Resolution:**
```bash
# Delete unused secrets
az keyvault secret delete --vault-name <key-vault-name> --name <secret-name>

# Purge soft-deleted items (if safe)
az keyvault secret purge --vault-name <key-vault-name> --name <secret-name>

# Delete old certificate versions
for cert in $(az keyvault certificate list --vault-name <key-vault-name> --query "[].id" -o tsv); do
  # Keep only latest version
  az keyvault certificate delete --id "$cert"
done

# Create additional Key Vault for sharding
az keyvault create \
  --name <new-kv-name> \
  --resource-group <resource-group> \
  --location <location> \
  --enable-soft-delete true \
  --enable-purge-protection true
```

---

#### Issue 5: High API Latency

**Symptoms:**
- API latency alert firing
- Slow application performance

**Troubleshooting Steps:**
```bash
# Check latency metrics
az monitor metrics list \
  --resource <key-vault-resource-id> \
  --metric "ServiceApiLatency" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average Maximum

# Test latency from your location
time az keyvault secret show \
  --vault-name <key-vault-name> \
  --name <secret-name>
```

**Common Causes:**
- Cryptographic operations (HSM keys)
- Network latency
- Public endpoint without private endpoint
- Far from Key Vault region
- Large certificate operations

**Resolution:**
```bash
# Use private endpoint
az network private-endpoint create \
  --name "kv-private-endpoint" \
  --resource-group <resource-group> \
  --vnet-name <vnet-name> \
  --subnet <subnet-name> \
  --private-connection-resource-id <key-vault-resource-id> \
  --group-id "vault" \
  --connection-name "kv-connection"

# Deploy Key Vault closer to application region
# Implement caching for frequently accessed secrets
# Use software keys instead of HSM for non-regulated workloads
```

---

### Validation Commands

```bash
# 1. List Key Vaults
az keyvault list --resource-group <resource-group> --output table

# 2. Get Key Vault details
az keyvault show --name <key-vault-name>

# 3. Check Key Vault status
az keyvault show --name <key-vault-name> --query "properties.provisioningState"

# 4. List metric definitions
az monitor metrics list-definitions \
  --resource <key-vault-resource-id> \
  --query "[?namespace=='Microsoft.KeyVault/vaults']"

# 5. Query availability metrics
az monitor metrics list \
  --resource <key-vault-resource-id> \
  --metric "Availability" \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --interval PT5M \
  --aggregation Average

# 6. Query API latency
az monitor metrics list \
  --resource <key-vault-resource-id> \
  --metric "ServiceApiLatency" \
  --start-time <start-time> \
  --end-time <end-time> \
  --aggregation Average Maximum

# 7. List all alerts
az monitor metrics alert list \
  --resource-group <resource-group> \
  --output table

# 8. Get alert details
az monitor metrics alert show \
  --resource-group <resource-group> \
  --name "kv-availability-<name>"

# 9. Test action group
az monitor action-group test-notifications create \
  --action-group <action-group-name> \
  --resource-group <resource-group> \
  --alert-type "Monitoring"

# 10. Enable diagnostic settings
az monitor diagnostic-settings create \
  --name "kv-diagnostics" \
  --resource <key-vault-resource-id> \
  --workspace <log-analytics-workspace-id> \
  --logs '[{"category": "AuditEvent", "enabled": true, "retentionPolicy": {"days": 365, "enabled": true}}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'

# 11. Query audit logs
# In Log Analytics:
# AzureDiagnostics
# | where ResourceProvider == "MICROSOFT.KEYVAULT"
# | where TimeGenerated > ago(24h)
# | project TimeGenerated, OperationName, CallerIPAddress, ResultType
# | order by TimeGenerated desc

# 12. Check access policies
az keyvault show \
  --name <key-vault-name> \
  --query "properties.accessPolicies"

# 13. Check network rules
az keyvault network-rule list --name <key-vault-name>

# 14. Test Key Vault access
az keyvault secret show \
  --vault-name <key-vault-name> \
  --name <secret-name>

# 15. Validate Terraform deployment
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
```

---

## License

This module is provided as-is under the MIT License. See LICENSE file for details.

---

**Module Maintained By:** Platform Engineering Team  
**Last Updated:** 2024-11-24  
**Terraform Version:** >= 1.0  
**Azure Provider Version:** >= 3.0

For questions or issues, please contact the Platform Engineering team or open an issue in the repository.
