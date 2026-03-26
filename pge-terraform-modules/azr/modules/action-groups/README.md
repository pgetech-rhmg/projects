# Azure Monitor Action Groups - AMBA Module

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Variables](#variables)
- [Action Group Types](#action-group-types)
- [Configuration Examples](#configuration-examples)
- [Cost Analysis](#cost-analysis)
- [Troubleshooting](#troubleshooting)

## Overview

This Terraform module creates and manages **Azure Monitor Action Groups** for the Azure Monitor Baseline Alerts (AMBA) framework. Action Groups define **who gets notified** and **how they get notified** when an Azure Monitor alert is triggered. This module provides a centralized, scalable approach to managing notification endpoints across your Azure monitoring infrastructure.

Action Groups are the cornerstone of Azure alerting, serving as reusable notification templates that can be referenced by multiple alerts across different Azure services. This module enables enterprise-grade alerting with proper separation of concerns, allowing different teams (Operations, Security, DevOps, etc.) to receive appropriate notifications based on alert context and severity.

## Features

- **Centralized Notification Management**: Single source of truth for all alert notification endpoints
- **Multi-Team Support**: Separate action groups for different operational teams and responsibilities  
- **Email Notification Integration**: Built-in email receiver configuration with common alert schema
- **Scalable Architecture**: Support for multiple action groups with different configurations
- **Enterprise Ready**: Designed for PGE operational standards and compliance requirements
- **Cost Effective**: Action Groups are FREE - no additional charges for basic notification functionality
- **Global Availability**: Action Groups work globally across all Azure regions
- **Common Alert Schema**: Standardized alert payload format for consistent notification content

### Supported Notification Types
- **Email Notifications**: Primary notification method with rich HTML formatting
- **Extensible Design**: Framework ready for SMS, voice, webhook, and Logic App integrations
- **ITSM Integration Ready**: Structure supports ServiceNow, PagerDuty, and other ITSM platforms
- **Microsoft Teams Ready**: Framework supports Teams channel notifications

## Prerequisites

- **Terraform**: Version >= 1.0
- **Azure Provider**: Version >= 3.0
- **Azure Permissions**: 
  - `Microsoft.Insights/actionGroups/write`
  - `Microsoft.Insights/actionGroups/read`
  - `Microsoft.Resources/resourceGroups/read`
- **Resource Groups**: Pre-existing resource groups for action group deployment
- **Email Addresses**: Valid operational email addresses or distribution lists

## Usage

### Basic Configuration

```hcl
module "action_groups" {
  source = "./modules/actionGroups"
  
  action_groups = [
    {
      name                = "pge-operations-actiongroup"
      short_name         = "pge-ops"
      resource_group_name = "rg-monitoring"
      location           = "global"
      enabled            = true
      email_addresses    = [
        "operations-team@pge.com",
        "infrastructure-alerts@pge.com"
      ]
    }
  ]
  
  tags = {
    Environment        = "Production"
    Application        = "Monitoring"
    Owner             = "monitoring-team@pge.com"
    CostCenter        = "IT-Operations"
    Compliance        = "SOX"
    DataClassification = "Internal"
  }
}
```

### Multi-Team Enterprise Configuration

```hcl
module "enterprise_action_groups" {
  source = "./modules/actionGroups"
  
  action_groups = [
    # Operations Team - General Infrastructure Alerts
    {
      name                = "pge-operations-actiongroup"
      short_name         = "pge-ops"
      resource_group_name = "rg-monitoring-prod"
      location           = "global"
      enabled            = true
      email_addresses    = [
        "operations-team@pge.com",
        "infrastructure-team@pge.com",
        "sre-team@pge.com"
      ]
    },
    
    # Security Team - Security and Compliance Alerts
    {
      name                = "pge-security-actiongroup"  
      short_name         = "pge-sec"
      resource_group_name = "rg-monitoring-prod"
      location           = "global"
      enabled            = true
      email_addresses    = [
        "security-team@pge.com",
        "soc-team@pge.com",
        "compliance-team@pge.com"
      ]
    },
    
    # Database Team - Database-Specific Alerts
    {
      name                = "pge-database-actiongroup"
      short_name         = "pge-dba"
      resource_group_name = "rg-monitoring-prod"
      location           = "global"
      enabled            = true
      email_addresses    = [
        "dba-team@pge.com",
        "database-ops@pge.com"
      ]
    },
    
    # Application Team - Application Performance Alerts
    {
      name                = "pge-application-actiongroup"
      short_name         = "pge-app"
      resource_group_name = "rg-monitoring-prod"  
      location           = "global"
      enabled            = true
      email_addresses    = [
        "application-team@pge.com",
        "dev-ops@pge.com"
      ]
    },
    
    # Network Team - Network Infrastructure Alerts  
    {
      name                = "pge-network-actiongroup"
      short_name         = "pge-net"
      resource_group_name = "rg-monitoring-prod"
      location           = "global"
      enabled            = true
      email_addresses    = [
        "network-team@pge.com",
        "network-ops@pge.com"
      ]
    }
  ]
  
  tags = {
    Environment        = "Production"
    Application        = "EnterpriseMonitoring"
    Owner             = "monitoring-team@pge.com"
    CostCenter        = "IT-Operations"
    Compliance        = "SOX"
    DataClassification = "Internal"
    AlertingFramework  = "AMBA"
  }
}
```

### Environment-Specific Configurations

#### Production Environment
```hcl
# Production - Full operational team coverage
action_groups = [
  {
    name                = "pge-prod-operations-actiongroup"
    short_name         = "prod-ops"
    resource_group_name = "rg-monitoring-prod"
    enabled            = true
    email_addresses    = [
      "prod-operations@pge.com",
      "prod-sre@pge.com",
      "prod-manager@pge.com"
    ]
  },
  {
    name                = "pge-prod-security-actiongroup"
    short_name         = "prod-sec"
    resource_group_name = "rg-monitoring-prod"
    enabled            = true
    email_addresses    = [
      "prod-security@pge.com",
      "soc-prod@pge.com"
    ]
  }
]
```

#### Staging Environment
```hcl
# Staging - Reduced notification scope
action_groups = [
  {
    name                = "pge-staging-actiongroup"
    short_name         = "stg-ops"
    resource_group_name = "rg-monitoring-staging"
    enabled            = true
    email_addresses    = [
      "staging-team@pge.com",
      "qa-team@pge.com"
    ]
  }
]
```

#### Development Environment
```hcl
# Development - Minimal notifications
action_groups = [
  {
    name                = "pge-dev-actiongroup"
    short_name         = "dev-ops"
    resource_group_name = "rg-monitoring-dev"
    enabled            = true
    email_addresses    = [
      "dev-team@pge.com"
    ]
  }
]
```

### Compliance-Specific Configurations

#### SOX Compliance Action Groups
```hcl
# SOX Compliance - Audit and Financial Systems
action_groups = [
  {
    name                = "pge-sox-compliance-actiongroup"
    short_name         = "sox-comp"
    resource_group_name = "rg-compliance-monitoring"
    enabled            = true
    email_addresses    = [
      "sox-compliance@pge.com",
      "financial-systems@pge.com",
      "audit-team@pge.com",
      "compliance-officer@pge.com"
    ]
  }
]

tags = {
  Compliance         = "SOX-Critical"
  DataClassification = "Confidential"
  AuditRequired      = "true"
}
```

#### HIPAA Compliance Action Groups
```hcl
# HIPAA Compliance - Healthcare Data Protection
action_groups = [
  {
    name                = "pge-hipaa-compliance-actiongroup"
    short_name         = "hipaa-sec"
    resource_group_name = "rg-healthcare-monitoring"
    enabled            = true
    email_addresses    = [
      "hipaa-compliance@pge.com",
      "healthcare-security@pge.com",
      "privacy-officer@pge.com"
    ]
  }
]

tags = {
  Compliance         = "HIPAA"
  DataClassification = "PHI"
  SecurityTier       = "High"
}
```

#### PCI-DSS Compliance Action Groups
```hcl
# PCI-DSS Compliance - Payment Card Industry
action_groups = [
  {
    name                = "pge-pci-compliance-actiongroup"
    short_name         = "pci-sec"
    resource_group_name = "rg-payment-monitoring"
    enabled            = true
    email_addresses    = [
      "pci-compliance@pge.com",
      "payment-security@pge.com",
      "card-data-officer@pge.com"
    ]
  }
]

tags = {
  Compliance         = "PCI-DSS"
  DataClassification = "Card-Holder-Data"
  SecurityTier       = "Critical"
}
```

## Variables

### Action Groups Configuration

| Variable | Type | Required | Description |
|----------|------|----------|-------------|
| `action_groups` | `list(object)` | Yes | List of action group configurations |

#### Action Group Object Structure

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | `string` | Yes | - | Action group name (must be unique within resource group) |
| `short_name` | `string` | Yes | - | Short name for action group (max 12 characters) |
| `resource_group_name` | `string` | Yes | - | Resource group for action group deployment |
| `location` | `string` | No | `"global"` | Azure region (use "global" for action groups) |
| `enabled` | `bool` | No | `true` | Enable/disable the action group |
| `email_addresses` | `list(string)` | Yes | - | List of email addresses for notifications |

### Tags Configuration

```hcl
tags = {
  AppId              = "123456"                      # Application identifier
  Env                = "Production"                  # Environment designation  
  Owner              = "monitoring-team@pge.com"     # Team responsible
  Compliance         = "SOX"                         # Compliance requirement
  Notify             = "operations@pge.com"          # Primary notification contact
  DataClassification = "Internal"                    # Data sensitivity level
  CostCenter         = "IT-Operations"              # Billing allocation
  CRIS               = "CRIS-12345"                 # Change request ID
  AlertingFramework  = "AMBA"                       # Framework identifier
  Purpose            = "AlertNotifications"          # Resource purpose
}
```

## Action Group Types

### 1. Operations Action Groups
**Purpose**: General infrastructure and operational alerts  
**Use Cases**: VM alerts, storage alerts, network alerts, performance monitoring  
**Recipients**: Operations team, SRE team, infrastructure team

```hcl
{
  name                = "pge-operations-actiongroup"
  short_name         = "pge-ops"
  resource_group_name = "rg-monitoring"
  email_addresses    = [
    "operations@pge.com",
    "sre-team@pge.com",
    "infrastructure@pge.com"
  ]
}
```

### 2. Security Action Groups  
**Purpose**: Security-related alerts and compliance monitoring  
**Use Cases**: DDoS alerts, security events, access violations, compliance breaches  
**Recipients**: Security team, SOC team, compliance team

```hcl
{
  name                = "pge-security-actiongroup"
  short_name         = "pge-sec"
  resource_group_name = "rg-monitoring"
  email_addresses    = [
    "security@pge.com",
    "soc-team@pge.com",
    "compliance@pge.com"
  ]
}
```

### 3. Application Action Groups
**Purpose**: Application performance and availability alerts  
**Use Cases**: App Service alerts, Function App alerts, Application Insights alerts  
**Recipients**: Application team, DevOps team, development team

```hcl
{
  name                = "pge-application-actiongroup"
  short_name         = "pge-app"
  resource_group_name = "rg-monitoring"
  email_addresses    = [
    "application-team@pge.com",
    "devops@pge.com"
  ]
}
```

### 4. Database Action Groups
**Purpose**: Database performance, availability, and backup alerts  
**Use Cases**: SQL Database alerts, Cosmos DB alerts, Redis alerts  
**Recipients**: Database team, DBA team, data engineering team

```hcl
{
  name                = "pge-database-actiongroup"
  short_name         = "pge-dba"
  resource_group_name = "rg-monitoring"
  email_addresses    = [
    "dba-team@pge.com",
    "database-ops@pge.com"
  ]
}
```

### 5. Network Action Groups
**Purpose**: Network infrastructure and connectivity alerts  
**Use Cases**: VNet alerts, load balancer alerts, traffic manager alerts  
**Recipients**: Network team, network operations, connectivity specialists

```hcl
{
  name                = "pge-network-actiongroup"
  short_name         = "pge-net"
  resource_group_name = "rg-monitoring"
  email_addresses    = [
    "network-team@pge.com",
    "network-ops@pge.com"
  ]
}
```

## Configuration Examples

### 1. Multi-Region Deployment
```hcl
module "action_groups_east" {
  source = "./modules/actionGroups"
  
  action_groups = [
    {
      name                = "pge-eastus-operations-actiongroup"
      short_name         = "east-ops"
      resource_group_name = "rg-monitoring-eastus"
      email_addresses    = ["eastus-ops@pge.com"]
    }
  ]
}

module "action_groups_west" {
  source = "./modules/actionGroups"
  
  action_groups = [
    {
      name                = "pge-westus-operations-actiongroup"
      short_name         = "west-ops"
      resource_group_name = "rg-monitoring-westus"
      email_addresses    = ["westus-ops@pge.com"]
    }
  ]
}
```

### 2. Severity-Based Action Groups
```hcl
# Critical alerts - Immediate response required
{
  name                = "pge-critical-actiongroup"
  short_name         = "critical"
  resource_group_name = "rg-monitoring"
  email_addresses    = [
    "on-call-engineer@pge.com",
    "duty-manager@pge.com",
    "escalation-list@pge.com"
  ]
}

# Warning alerts - Standard operations response
{
  name                = "pge-warning-actiongroup"  
  short_name         = "warning"
  resource_group_name = "rg-monitoring"
  email_addresses    = [
    "operations@pge.com",
    "monitoring@pge.com"
  ]
}

# Informational alerts - FYI notifications
{
  name                = "pge-info-actiongroup"
  short_name         = "info"
  resource_group_name = "rg-monitoring"
  email_addresses    = [
    "monitoring@pge.com"
  ]
}
```

### 3. Business Hours vs. After Hours
```hcl
# Business hours action group (8 AM - 6 PM)
{
  name                = "pge-business-hours-actiongroup"
  short_name         = "biz-hrs"
  resource_group_name = "rg-monitoring"
  email_addresses    = [
    "business-hours-team@pge.com",
    "day-shift-ops@pge.com"
  ]
}

# After hours action group (6 PM - 8 AM, weekends)
{
  name                = "pge-after-hours-actiongroup"
  short_name         = "after-hrs"
  resource_group_name = "rg-monitoring"
  email_addresses    = [
    "on-call-engineer@pge.com",
    "night-shift-ops@pge.com",
    "weekend-support@pge.com"
  ]
}
```

## Cost Analysis

### Action Group Costs

**Azure Monitor Action Groups are FREE** for basic email, SMS, and voice notifications with the following limits:

| Notification Type | Free Tier Limit | Overage Cost |
|-------------------|-----------------|--------------|
| Email | 1,000 emails/month | $0.20 per 1,000 additional emails |
| SMS | 100 SMS/month | $0.20 per additional SMS |
| Voice | 10 calls/month | $0.65 per additional call |
| Webhook/Logic App | Unlimited | FREE |
| Azure Function | Unlimited | Function execution costs apply |

### Cost Examples

#### Small Environment (1 Action Group, 100 alerts/month)
- **Email Notifications**: FREE (under 1,000/month limit)
- **Monthly Cost**: $0.00
- **Annual Cost**: $0.00

#### Medium Environment (5 Action Groups, 2,500 alerts/month)  
- **Email Notifications**: $0.30/month (1,500 overage emails × $0.20/1,000)
- **Monthly Cost**: $0.30
- **Annual Cost**: $3.60

#### Large Environment (15 Action Groups, 10,000 alerts/month)
- **Email Notifications**: $1.80/month (9,000 overage emails × $0.20/1,000)
- **Monthly Cost**: $1.80  
- **Annual Cost**: $21.60

#### Enterprise Environment (50 Action Groups, 50,000 alerts/month)
- **Email Notifications**: $9.80/month (49,000 overage emails × $0.20/1,000)
- **Monthly Cost**: $9.80
- **Annual Cost**: $117.60

### Cost Optimization Strategies

1. **Consolidate Similar Notifications**: Use distribution lists instead of multiple individual emails
2. **Alert Tuning**: Optimize alert thresholds to reduce false positives
3. **Smart Grouping**: Use Azure Monitor's smart grouping to reduce notification volume
4. **Webhook Integration**: Use webhooks for high-volume scenarios to avoid email costs
5. **Business Hours Configuration**: Route non-critical alerts to different action groups with lower frequency

## Troubleshooting

### Common Issues and Solutions

#### 1. Action Group Not Receiving Notifications
**Symptoms**: Alerts fire but no email notifications received

**Possible Causes**:
- Email addresses in spam/junk folder
- Action group disabled
- Email receiver configuration issues
- Distribution list not configured properly

**Troubleshooting Steps**:
```bash
# Verify action group status
az monitor action-group show \
  --resource-group "rg-monitoring" \
  --name "pge-operations-actiongroup" \
  --query "{Name:name, Enabled:enabled, EmailReceivers:emailReceivers[].{Name:name, Email:emailAddress}}"

# Check action group activity log
az monitor activity-log list \
  --resource-group "rg-monitoring" \
  --start-time "2023-11-01T00:00:00Z" \
  --query "[?contains(resourceId, 'actionGroups')]"
```

**Resolution**:
- Verify action group is enabled (`"enabled": true`)
- Check spam/junk folders for notifications
- Validate email addresses are correct and active
- Test with individual email address before using distribution list

#### 2. Action Group Email Format Issues  
**Symptoms**: Emails received but content is not formatted correctly

**Possible Causes**:
- Common alert schema disabled
- Custom payload formatting issues
- Email client not supporting HTML format

**Troubleshooting Steps**:
```bash
# Verify common alert schema setting
az monitor action-group show \
  --resource-group "rg-monitoring" \
  --name "pge-operations-actiongroup" \
  --query "emailReceivers[].useCommonAlertSchema"
```

**Resolution**:
- Ensure `use_common_alert_schema = true` in Terraform configuration
- Update action group if schema setting is incorrect
- Verify email clients support HTML formatting

#### 3. Terraform Deployment Issues
**Symptoms**: Terraform fails to create or update action groups

**Common Errors**:
```bash
# Error: Short name too long
Error: expected length of short_name to be in the range (1 - 12)

# Error: Invalid email format  
Error: expected "email_address" to be a valid email address

# Error: Duplicate action group name
Error: Action Group "pge-operations-actiongroup" already exists
```

**Resolution**:
```hcl
# Fix short name length (max 12 characters)
short_name = "pge-ops"      # Good (8 chars)
short_name = "pge-operations"  # Bad (15 chars - too long)

# Validate email format
email_addresses = [
  "valid@pge.com",          # Good - valid format
  "invalid-email"           # Bad - invalid format
]

# Ensure unique names within resource group
name = "pge-operations-actiongroup-${var.environment}"  # Environment-specific naming
```

#### 4. Email Delivery Issues
**Symptoms**: Action group configured correctly but emails not being delivered

**Troubleshooting Steps**:
```powershell
# Test email delivery using PowerShell
function Test-ActionGroupEmail {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory=$true)]
        [string]$ActionGroupName,
        
        [Parameter(Mandatory=$true)]
        [string]$TestEmail
    )
    
    Write-Host "Testing email delivery for Action Group: $ActionGroupName" -ForegroundColor Green
    
    # Get action group details
    $ActionGroup = Get-AzActionGroup -ResourceGroupName $ResourceGroupName -Name $ActionGroupName
    
    if ($ActionGroup) {
        Write-Host "Action Group Status: $($ActionGroup.Enabled)" -ForegroundColor Cyan
        
        # Check if test email is in receivers list
        $EmailFound = $ActionGroup.EmailReceivers | Where-Object { $_.EmailAddress -eq $TestEmail }
        
        if ($EmailFound) {
            Write-Host "✅ Email address found in action group" -ForegroundColor Green
        } else {
            Write-Host "❌ Email address not found in action group" -ForegroundColor Red
            Write-Host "Current receivers:" -ForegroundColor Yellow
            foreach ($Receiver in $ActionGroup.EmailReceivers) {
                Write-Host "  - $($Receiver.EmailAddress)" -ForegroundColor White
            }
        }
        
        # Provide troubleshooting steps
        Write-Host "`nTroubleshooting Steps:" -ForegroundColor Cyan
        Write-Host "1. Check spam/junk folder" -ForegroundColor White
        Write-Host "2. Verify email server accepts emails from noreply@email.azure.com" -ForegroundColor White
        Write-Host "3. Check corporate firewall settings for Azure Monitor" -ForegroundColor White
        Write-Host "4. Verify distribution list configuration (if applicable)" -ForegroundColor White
        
    } else {
        Write-Host "❌ Action Group not found: $ActionGroupName" -ForegroundColor Red
    }
}

# Usage
Test-ActionGroupEmail -ResourceGroupName "rg-monitoring" -ActionGroupName "pge-operations-actiongroup" -TestEmail "test@pge.com"
```

**Resolution**:
- Add `noreply@email.azure.com` to email whitelist
- Check corporate firewall and email security settings
- Verify distribution list memberships and forwarding rules
- Test with individual email addresses before using distribution lists