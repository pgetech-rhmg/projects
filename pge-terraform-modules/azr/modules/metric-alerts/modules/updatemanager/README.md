# Azure Update Manager - Metric Alerts Module

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Variables](#variables)
- [Alert Details](#alert-details)
- [Severity Levels](#severity-levels)
- [Cost Analysis](#cost-analysis)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Overview

This Terraform module creates comprehensive monitoring alerts for **Azure Update Manager**, providing proactive monitoring for patch management, update compliance, maintenance windows, and deployment operations across virtual machines and Azure resources. The module monitors critical update management metrics to ensure security compliance, operational efficiency, and change management oversight.

Azure Update Manager is a unified service to help manage and govern updates for all your machines. You can monitor Windows and Linux machines across Azure, on-premises, and other cloud platforms from a single dashboard. This module focuses on update deployment monitoring, compliance tracking, patch installation oversight, and maintenance window management for enterprise-grade patch management operations.

## Features

- **Update Deployment Monitoring**: Real-time tracking of update deployment success and failure rates
- **Compliance Tracking**: Continuous monitoring of update compliance across virtual machine fleets
- **Patch Installation Oversight**: Detailed monitoring of patch installation success and failure patterns
- **Maintenance Window Management**: Enforcement of maintenance window policies and violation detection
- **Critical Update Alerting**: Immediate notification when critical security updates become available
- **Assessment Failure Detection**: Monitoring of update assessment operations and failure scenarios
- **Administrative Security**: Creation, deletion, and configuration change alerts for audit compliance
- **Multi-Subscription Support**: Enterprise-scale monitoring across multiple Azure subscriptions
- **Real-Time Alerting**: Hourly to daily evaluation frequency based on update criticality
- **Cost-Effective Monitoring**: Optimized alert configuration at $0.60 per subscription per month
- **Enterprise Integration**: Built-in support for PGE operational procedures and compliance requirements
- **Regulatory Compliance**: SOX, HIPAA, PCI-DSS compliance support for patch management governance

### Key Monitoring Capabilities
- **Security Compliance**: Ensure timely installation of critical security updates
- **Operational Excellence**: Monitor patch deployment success rates and maintenance windows
- **Change Management**: Track all update-related administrative operations for audit trails
- **Risk Management**: Early detection of update failures and compliance drift
- **Cost Optimization**: Efficient patch management through proactive monitoring and automation

## Prerequisites

- **Terraform**: Version >= 1.0
- **Azure Provider**: Version >= 3.0
- **Azure Permissions**: 
  - `Microsoft.Insights/scheduledQueryRules/write`
  - `Microsoft.Insights/activityLogAlerts/write`
  - `Microsoft.Insights/actionGroups/read`
  - `Microsoft.Maintenance/maintenanceConfigurations/read`
  - `Microsoft.Compute/virtualMachines/read`
- **Action Group**: Pre-configured action group for alert notifications
- **Log Analytics Workspace**: For update data collection and scheduled query rules
- **Virtual Machines**: VMs configured with Update Manager for monitoring
- **Update Manager**: Azure Update Manager enabled on target subscriptions

## Usage

### Basic Configuration

```hcl
module "update_manager_alerts" {
  source = "./modules/metricAlerts/updatemanager"
  
  # Resource Configuration
  resource_group_name               = "rg-production-management"
  action_group_resource_group_name  = "rg-monitoring"
  action_group                      = "pge-operations-actiongroup"
  
  # Subscription and VM Monitoring Scope
  subscription_ids = [
    "12345678-1234-1234-1234-123456789012",
    "87654321-4321-4321-4321-210987654321"
  ]
  
  vm_resource_ids = [
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-prod-vms/providers/Microsoft.Compute/virtualMachines/vm-web-01",
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-prod-vms/providers/Microsoft.Compute/virtualMachines/vm-app-01",
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-prod-vms/providers/Microsoft.Compute/virtualMachines/vm-db-01"
  ]
  
  # Environment Tags
  tags = {
    Environment        = "Production"
    Application        = "UpdateManagement"
    Owner             = "infrastructure-team@pge.com"
    CostCenter        = "IT-Operations"
    Compliance        = "SOX"
    DataClassification = "Internal"
  }
}
```

### Advanced Configuration with Custom Thresholds

```hcl
module "update_manager_alerts_critical" {
  source = "./modules/metricAlerts/updatemanager"
  
  # Resource Configuration
  resource_group_name               = "rg-production-management"
  action_group_resource_group_name  = "rg-monitoring"
  subscription_ids                 = ["12345678-1234-1234-1234-123456789012"]
  vm_resource_ids                  = var.critical_vm_resource_ids
  
  # Strict Compliance Thresholds for Critical Systems
  update_compliance_threshold              = 95    # Higher compliance requirement
  critical_update_available_threshold      = 1     # Immediate alert on any critical update
  patch_installation_failure_threshold    = 1     # Zero tolerance for patch failures
  update_assessment_failure_threshold     = 1     # Immediate assessment failure detection
  
  # Comprehensive Alert Coverage
  enable_update_deployment_failure_alert   = true
  enable_update_compliance_alert          = true
  enable_maintenance_window_alert         = true
  enable_patch_installation_failure_alert = true
  enable_update_assessment_failure_alert  = true
  enable_critical_update_available_alert  = true
  
  tags = {
    Environment = "Production"
    Tier        = "Critical"
    Compliance  = "SOX-Critical"
    Owner       = "security-team@pge.com"
  }
}
```

### Environment-Specific Configurations

#### Development Environment
```hcl
# Development Update Management - Relaxed Thresholds
update_compliance_threshold              = 80    # Lower compliance requirement
critical_update_available_threshold      = 5     # Allow more critical updates
patch_installation_failure_threshold    = 5     # Higher failure tolerance
maintenance_window_threshold            = 60    # Longer maintenance window flexibility
enable_maintenance_window_alert         = false # Disable strict window enforcement
```

#### Staging Environment
```hcl
# Staging Update Management - Moderate Thresholds
update_compliance_threshold              = 90    # Standard compliance
critical_update_available_threshold      = 2     # Moderate critical update tolerance
patch_installation_failure_threshold    = 2     # Moderate failure tolerance
maintenance_window_threshold            = 45    # Moderate window enforcement
enable_maintenance_window_alert         = true  # Enable window monitoring
```

#### Production Environment
```hcl
# Production Update Management - Strict Thresholds
update_compliance_threshold              = 95    # High compliance requirement
critical_update_available_threshold      = 1     # Immediate critical update alerting
patch_installation_failure_threshold    = 1     # Zero tolerance for failures
maintenance_window_threshold            = 30    # Strict window enforcement
enable_maintenance_window_alert         = true  # Full window monitoring
```

### Compliance-Specific Configurations

#### SOX Compliance
```hcl
# SOX Compliance - Strict Change Management
update_compliance_threshold              = 98    # Very high compliance
enable_update_deployment_failure_alert   = true
enable_maintenance_window_alert         = true
maintenance_window_threshold            = 15    # Tight window control
enable_update_assessment_failure_alert  = true
```

#### PCI-DSS Compliance
```hcl
# PCI-DSS Compliance - Security Focus
update_compliance_threshold              = 95
critical_update_available_threshold      = 1     # Immediate security update alerting
enable_critical_update_available_alert  = true
patch_installation_failure_threshold    = 1     # Zero security patch failures
```

#### HIPAA Compliance
```hcl
# HIPAA Compliance - Healthcare Security
update_compliance_threshold              = 95
critical_update_available_threshold      = 1
enable_update_assessment_failure_alert  = true
enable_patch_installation_failure_alert = true
maintenance_window_threshold            = 30
```

### Workload-Specific Configurations

#### Web Servers
```hcl
# Web Servers - High Availability Focus
update_compliance_threshold              = 90
maintenance_window_threshold            = 30    # Coordinated maintenance windows
enable_maintenance_window_alert         = true
critical_update_available_threshold      = 2
```

#### Database Servers
```hcl
# Database Servers - Critical System Protection
update_compliance_threshold              = 98    # Highest compliance
critical_update_available_threshold      = 1     # Immediate critical alerts
patch_installation_failure_threshold    = 1     # Zero failure tolerance
maintenance_window_threshold            = 15    # Strict maintenance control
```

#### Application Servers
```hcl
# Application Servers - Balanced Approach
update_compliance_threshold              = 95
critical_update_available_threshold      = 1
patch_installation_failure_threshold    = 2
maintenance_window_threshold            = 30
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group for Update Manager resources |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group for notifications |
| `location` | `string` | `"West US 3"` | Azure region for scheduled query rules |
| `subscription_ids` | `list(string)` | `[]` | List of subscription IDs to monitor |
| `vm_resource_ids` | `list(string)` | `[]` | List of VM resource IDs for update monitoring |

### Alert Enable/Disable Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_update_deployment_failure_alert` | `bool` | `true` | Enable update deployment failure monitoring |
| `enable_update_compliance_alert` | `bool` | `true` | Enable update compliance monitoring |
| `enable_maintenance_window_alert` | `bool` | `true` | Enable maintenance window monitoring |
| `enable_patch_installation_failure_alert` | `bool` | `true` | Enable patch installation failure monitoring |
| `enable_update_assessment_failure_alert` | `bool` | `true` | Enable update assessment failure monitoring |
| `enable_critical_update_available_alert` | `bool` | `true` | Enable critical update availability monitoring |

### Alert Threshold Variables

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `update_compliance_threshold` | `number` | `90` | Minimum update compliance percentage | 80-98% |
| `critical_update_available_threshold` | `number` | `1` | Critical updates threshold for alerting | 1-5 updates |
| `patch_installation_failure_threshold` | `number` | `1` | Failed patch installations threshold | 1-10 failures |
| `update_assessment_failure_threshold` | `number` | `1` | Update assessment failure threshold | 1-5 failures |
| `maintenance_window_threshold` | `number` | `30` | Maintenance window violation threshold (minutes) | 15-120 minutes |

### Tags Configuration

```hcl
tags = {
  AppId              = "123456"                      # Application identifier
  Env                = "Production"                  # Environment designation
  Owner              = "infrastructure-team@pge.com" # Team responsible
  Compliance         = "SOX"                         # Compliance requirement
  Notify             = "patch-team@pge.com"         # Notification contact
  DataClassification = "Internal"                    # Data sensitivity
  CostCenter         = "IT-Operations"              # Billing allocation
  CRIS               = "CRIS-12345"                 # Change request ID
  MaintenanceWindow  = "02:00-06:00"               # Maintenance schedule
}
```

## Alert Details

### 1. Update Deployment Started Alert
- **Alert Name**: `update-deployment-started-{subscription-ids}`
- **Operation**: `Microsoft.Maintenance/maintenanceConfigurations/write`
- **Severity**: Informational (Activity Log)
- **Frequency**: Immediate
- **Scope**: Subscription-level

**What this alert monitors**: Initiation of update deployments across Azure Update Manager, providing audit trail and deployment tracking.

**What to do when this alert fires**:
1. **Deployment Verification**: Confirm deployment was scheduled and authorized through change management
2. **Impact Assessment**: Review scope of deployment and affected systems
3. **Monitoring Activation**: Ensure monitoring is active for deployment progress and success
4. **Communication**: Notify stakeholders of deployment commencement
5. **Documentation**: Update deployment logs and change management records

### 2. Update Deployment Failed Alert
- **Alert Name**: `update-deployment-failed-{subscription-ids}`
- **Operation**: `Microsoft.Maintenance/applyUpdates/write`
- **Status**: `Failed`
- **Severity**: 1 (Critical)
- **Frequency**: Immediate
- **Scope**: Subscription-level

**What this alert monitors**: Failed update deployments that could leave systems vulnerable or non-compliant.

**What to do when this alert fires**:
1. **Immediate Assessment**: Identify failed deployment scope and affected systems
2. **Root Cause Analysis**: Investigate deployment failure reasons and error messages
3. **Rollback Planning**: Determine if rollback procedures are needed for partially updated systems
4. **Alternative Deployment**: Plan alternative deployment strategy or manual updates if required
5. **Incident Documentation**: Document failure for compliance and process improvement

### 3. Maintenance Configuration Change Alert
- **Alert Name**: `maintenance-config-change-{subscription-ids}`
- **Operation**: `Microsoft.Maintenance/maintenanceConfigurations/write`
- **Severity**: Warning (Activity Log)
- **Frequency**: Immediate
- **Scope**: Subscription-level

**What this alert monitors**: Changes to maintenance configurations including schedules, windows, and deployment settings.

**What to do when this alert fires**:
1. **Change Validation**: Review and validate maintenance configuration changes
2. **Impact Analysis**: Assess impact on scheduled maintenance windows and deployments
3. **Change Documentation**: Ensure changes are properly documented and approved
4. **Schedule Verification**: Verify maintenance schedules align with business requirements
5. **Compliance Check**: Confirm changes comply with organizational policies

### 4. Maintenance Configuration Deleted Alert
- **Alert Name**: `maintenance-config-deleted-{subscription-ids}`
- **Operation**: `Microsoft.Maintenance/maintenanceConfigurations/delete`
- **Severity**: Warning (Activity Log)
- **Frequency**: Immediate
- **Scope**: Subscription-level

**What this alert monitors**: Deletion of maintenance configurations that could disrupt update management processes.

**What to do when this alert fires**:
1. **Immediate Verification**: Confirm deletion was authorized and intentional
2. **Impact Assessment**: Evaluate impact on affected VMs and update schedules
3. **Recovery Planning**: Recreate maintenance configurations if deletion was unauthorized
4. **Schedule Continuity**: Ensure alternative maintenance schedules are in place
5. **Access Review**: Review who had deletion permissions and audit access controls

### 5. Update Assessment Triggered Alert
- **Alert Name**: `update-assessment-triggered-{subscription-ids}`
- **Operation**: `Microsoft.Maintenance/configurationAssignments/write`
- **Severity**: Informational (Activity Log)
- **Frequency**: Immediate
- **Scope**: Subscription-level

**What this alert monitors**: Initiation of update assessments across virtual machines for compliance and security evaluation.

**What to do when this alert fires**:
1. **Assessment Validation**: Confirm assessment was scheduled or triggered appropriately
2. **Scope Review**: Review assessment scope and targeted virtual machines
3. **Progress Monitoring**: Monitor assessment progress and completion status
4. **Results Planning**: Prepare for assessment results analysis and action planning
5. **Compliance Tracking**: Update compliance tracking systems with assessment status

### 6. VM Update Installation Failed Alert
- **Alert Name**: `vm-update-failed-{subscription-ids}`
- **Operation**: `Microsoft.Compute/virtualMachines/extensions/write`
- **Status**: `Failed`
- **Severity**: 1 (Critical)
- **Frequency**: Immediate
- **Scope**: Subscription-level

**What this alert monitors**: Failed update installations on individual virtual machines that could leave systems vulnerable.

**What to do when this alert fires**:
1. **VM Health Check**: Verify virtual machine health and availability
2. **Error Analysis**: Analyze installation failure error messages and logs
3. **Manual Installation**: Attempt manual update installation if safe to do so
4. **System Recovery**: Initiate system recovery procedures if VM is compromised
5. **Compliance Documentation**: Document failure for compliance and security tracking

### 7. Update Compliance Low Alert
- **Alert Name**: `update-compliance-low-{subscription-ids}`
- **Query Type**: Scheduled Query Rule
- **Threshold**: < 90% compliance (configurable)
- **Severity**: 2 (High)
- **Frequency**: P1D (Daily)
- **Window**: P1D (1 day)

**What this alert monitors**: Overall update compliance percentage across monitored virtual machines falling below acceptable thresholds.

**What to do when this alert fires**:
1. **Compliance Analysis**: Analyze compliance trends and identify non-compliant systems
2. **Gap Assessment**: Identify missing updates and their criticality levels
3. **Remediation Planning**: Plan immediate remediation for critical security updates
4. **Process Review**: Review update deployment processes for improvement opportunities
5. **Stakeholder Communication**: Notify compliance teams and management of status

### 8. Critical Updates Available Alert
- **Alert Name**: `critical-updates-available-{subscription-ids}`
- **Query Type**: Scheduled Query Rule
- **Threshold**: ≥ 1 critical update (configurable)
- **Severity**: 1 (Critical)
- **Frequency**: P1D (Daily)
- **Window**: P1D (1 day)

**What this alert monitors**: Availability of critical security updates that require immediate attention and installation.

**What to do when this alert fires**:
1. **Critical Update Assessment**: Review critical updates and their security implications
2. **Risk Evaluation**: Assess risk of delayed installation vs. update deployment risk
3. **Emergency Deployment**: Consider emergency maintenance window for critical security updates
4. **Prioritization**: Prioritize updates based on system criticality and exposure
5. **Stakeholder Notification**: Immediately notify security teams and system owners

### 9. Update Installation Failures Alert
- **Alert Name**: `update-installation-failures-{subscription-ids}`
- **Query Type**: Scheduled Query Rule
- **Threshold**: ≥ 1 failure (configurable)
- **Severity**: 1 (Critical)
- **Frequency**: PT1H (Hourly)
- **Window**: PT6H (6 hours)

**What this alert monitors**: Pattern of update installation failures across virtual machines indicating systemic issues.

**What to do when this alert fires**:
1. **Failure Pattern Analysis**: Identify common patterns in update installation failures
2. **System Health Review**: Check underlying system health and resource availability
3. **Update Conflicts**: Investigate potential conflicts with existing software or configurations
4. **Batch Processing**: Consider breaking large update batches into smaller deployments
5. **Infrastructure Assessment**: Review VM performance and capacity constraints

### 10. Update Assessment Failures Alert
- **Alert Name**: `update-assessment-failures-{subscription-ids}`
- **Query Type**: Scheduled Query Rule
- **Threshold**: ≥ 1 failure (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT6H (6 hours)
- **Window**: PT6H (6 hours)

**What this alert monitors**: Failed update assessments that prevent proper compliance evaluation and update planning.

**What to do when this alert fires**:
1. **Assessment Status Review**: Check update assessment service status and connectivity
2. **Agent Health**: Verify Update Manager agents are running and properly configured
3. **Network Connectivity**: Ensure VMs can communicate with Azure Update Manager services
4. **Permission Verification**: Check that necessary permissions are in place for assessments
5. **Manual Assessment**: Trigger manual assessments to validate automated process functionality

### 11. Maintenance Window Violations Alert
- **Alert Name**: `maintenance-window-violations-{subscription-ids}`
- **Query Type**: Scheduled Query Rule
- **Threshold**: > 0 violations (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT1H (Hourly)
- **Window**: PT1H (1 hour)

**What this alert monitors**: Updates installed outside of approved maintenance windows, indicating policy violations or emergency updates.

**What to do when this alert fires**:
1. **Violation Analysis**: Identify which updates were installed outside maintenance windows
2. **Authorization Check**: Verify if out-of-window updates were emergency-authorized
3. **Policy Review**: Review maintenance window policies and enforcement mechanisms
4. **Change Management**: Ensure proper change management approval for emergency updates
5. **Process Improvement**: Update procedures to prevent unauthorized maintenance window violations

## Severity Levels

### Severity 1 (Critical) - Security/Compliance Impact
- **Update Deployment Failures**: Failed deployments leaving systems vulnerable
- **VM Update Installation Failures**: Individual VM update failures creating security gaps
- **Critical Updates Available**: Security-critical updates requiring immediate attention
- **Update Installation Failures**: Systemic update installation problems

**Response Time**: 15 minutes
**Escalation**: Immediate notification to security team, patch management team, and on-call engineer

### Severity 2 (High) - Operational Impact
- **Update Compliance Low**: Compliance metrics below acceptable thresholds
- **Update Assessment Failures**: Assessment process failures affecting compliance visibility
- **Maintenance Window Violations**: Policy violations requiring review and correction

**Response Time**: 1 hour
**Escalation**: Notification to patch management team and compliance officers

### Informational/Warning - Administrative Events
- **Update Deployment Started**: Update deployment initiated
- **Update Assessment Triggered**: Assessment process started
- **Maintenance Configuration Changes**: Configuration modifications
- **Maintenance Configuration Deleted**: Configuration removal

**Response Time**: 4 hours
**Escalation**: Standard operational notification and audit trail

## Cost Analysis

### Alert Costs (Monthly)
- **6 Activity Log Alerts + 6 Scheduled Query Rules per Subscription**: 
  - 6 × FREE (Activity Log) + 6 × $0.10 (Query Rules) = **$0.60 per Subscription**
- **Multi-Subscription Deployment**: Scales with subscription count
- **Action Group**: FREE (included)
- **Activity Log Alerts**: FREE (included)

### Cost Examples by Environment

#### Small VM Environment (1 Subscription, 10 VMs)
- **Monthly Alert Cost**: $0.60
- **Annual Alert Cost**: $7.20

#### Medium Enterprise Environment (3 Subscriptions, 100 VMs)
- **Monthly Alert Cost**: $1.80
- **Annual Alert Cost**: $21.60

#### Large Multi-Subscription Environment (10 Subscriptions, 1000 VMs)
- **Monthly Alert Cost**: $6.00
- **Annual Alert Cost**: $72.00

#### Enterprise Global Environment (50 Subscriptions, 10000 VMs)
- **Monthly Alert Cost**: $30.00
- **Annual Alert Cost**: $360.00

### Return on Investment (ROI)

#### Cost of Update Management Issues
- **Security Breach from Unpatched Systems**: $1,000,000-10,000,000 per incident
- **Compliance Violations**: $100,000-1,000,000 in fines and penalties
- **System Downtime from Failed Updates**: $50,000-500,000/hour for critical systems
- **Manual Patch Management**: $200-1,000 per VM per month in manual efforts
- **Audit Failures**: $500,000-5,000,000 in compliance remediation costs

#### Alert Value Calculation
- **Monthly Alert Cost**: $0.60 per Subscription
- **Prevented Security Incidents**: 1 per year average across subscriptions
- **Cost Avoidance**: $5,000,000/year for enterprise environments
- **ROI**: 694,444,333% (($5,000,000 - $7.20) / $7.20 × 100)

#### Additional Benefits
- **Automated Compliance Tracking**: Continuous compliance monitoring and reporting
- **Proactive Security Management**: Early detection of critical security updates
- **Operational Efficiency**: Reduced manual patch management overhead
- **Audit Readiness**: Complete audit trails for compliance requirements
- **Risk Mitigation**: Proactive identification and resolution of update-related risks

### Update Manager Pricing Context
- **Azure Update Manager**: FREE (included with Azure VMs)
- **Log Analytics Workspace**: $2.30/GB ingested per month
- **Azure Automation**: $0.002 per minute of job runtime

**Alert Cost Impact**: Minimal compared to potential security breach costs and manual management overhead

## Best Practices

### Deployment Best Practices

#### 1. Environment-Specific Configuration
```hcl
# Production Environment - Strict compliance
update_compliance_threshold              = 95
critical_update_available_threshold      = 1
patch_installation_failure_threshold    = 1
maintenance_window_threshold            = 30
enable_maintenance_window_alert         = true

# Staging Environment - Moderate compliance  
update_compliance_threshold              = 90
critical_update_available_threshold      = 2
patch_installation_failure_threshold    = 2
maintenance_window_threshold            = 45
enable_maintenance_window_alert         = true

# Development Environment - Relaxed compliance
update_compliance_threshold              = 80
critical_update_available_threshold      = 5
patch_installation_failure_threshold    = 5
maintenance_window_threshold            = 60
enable_maintenance_window_alert         = false
```

#### 2. Compliance-Specific Monitoring
- **SOX Compliance**: Strict change management and maintenance window enforcement
- **PCI-DSS**: Focus on security updates and rapid deployment
- **HIPAA**: Comprehensive monitoring with emphasis on critical updates
- **FedRAMP**: Enhanced security monitoring and compliance tracking

#### 3. Workload-Specific Configurations
- **Web Servers**: Coordinated maintenance windows and high availability focus
- **Database Servers**: Zero-tolerance for failures and strict maintenance control
- **Application Servers**: Balanced approach with moderate thresholds

### Update Manager Configuration Best Practices

#### 1. Maintenance Configuration Setup
```bash
# Create maintenance configuration for production systems
az maintenance configuration create \
  --resource-group "rg-production-management" \
  --name "prod-maintenance-config" \
  --location "East US" \
  --maintenance-scope "InGuestPatch" \
  --visibility "Custom" \
  --start-date-time "2023-12-01 02:00" \
  --expiration-date-time "2024-12-01 02:00" \
  --duration "04:00" \
  --time-zone "Pacific Standard Time" \
  --recur-every "1Week" \
  --week-days "Saturday" \
  --reboot-setting "IfRequired" \
  --windows-classifications-to-include "Critical" "Security" \
  --windows-kb-numbers-to-include \
  --windows-kb-numbers-to-exclude \
  --linux-classifications-to-include "Critical" "Security"
```

#### 2. VM Assignment to Maintenance Configuration
```bash
# Assign VMs to maintenance configuration
az maintenance assignment create \
  --resource-group "rg-production-vms" \
  --location "East US" \
  --resource-name "vm-web-01" \
  --resource-type "virtualMachines" \
  --provider-name "Microsoft.Compute" \
  --configuration-assignment-name "prod-maintenance-assignment" \
  --maintenance-configuration-id "/subscriptions/{subscription-id}/resourcegroups/rg-production-management/providers/Microsoft.Maintenance/maintenanceConfigurations/prod-maintenance-config"
```

#### 3. Update Assessment Automation
```powershell
# PowerShell script for automated update assessment
function Start-UpdateAssessment {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$VMResourceIds,
        
        [Parameter(Mandatory=$false)]
        [string]$MaintenanceConfigurationId
    )
    
    foreach ($VMResourceId in $VMResourceIds) {
        Write-Host "Starting update assessment for VM: $VMResourceId" -ForegroundColor Green
        
        # Trigger update assessment
        $Assessment = Invoke-AzRestMethod -Uri "https://management.azure.com$VMResourceId/assessPatches?api-version=2021-11-01" -Method POST
        
        if ($Assessment.StatusCode -eq 202) {
            Write-Host "Assessment started successfully" -ForegroundColor Green
            
            # Get operation location for status tracking
            $OperationLocation = $Assessment.Headers['Azure-AsyncOperation']
            Write-Host "Operation Location: $OperationLocation" -ForegroundColor Yellow
        } else {
            Write-Host "Assessment failed with status code: $($Assessment.StatusCode)" -ForegroundColor Red
        }
    }
}

# Usage
$VMResourceIds = @(
    "/subscriptions/{sub}/resourceGroups/rg-prod-vms/providers/Microsoft.Compute/virtualMachines/vm-web-01",
    "/subscriptions/{sub}/resourceGroups/rg-prod-vms/providers/Microsoft.Compute/virtualMachines/vm-app-01"
)
Start-UpdateAssessment -VMResourceIds $VMResourceIds
```

### Monitoring and Compliance Best Practices

#### 1. Compliance Reporting Automation
```powershell
# PowerShell script for update compliance reporting
function Get-UpdateComplianceReport {
    param(
        [Parameter(Mandatory=$true)]
        [string]$WorkspaceName,
        
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory=$false)]
        [int]$Days = 30
    )
    
    $Query = @"
        UpdateSummary
        | where TimeGenerated > ago(${Days}d)
        | summarize 
            TotalComputers = dcount(Computer),
            ComputersNeedingUpdates = dcountif(Computer, CriticalUpdatesMissing > 0 or SecurityUpdatesMissing > 0),
            AvgCriticalUpdates = avg(CriticalUpdatesMissing),
            AvgSecurityUpdates = avg(SecurityUpdatesMissing),
            LastAssessment = max(TimeGenerated)
        | extend ComplianceRate = round(100.0 * (TotalComputers - ComputersNeedingUpdates) / TotalComputers, 2)
        | project 
            TotalComputers,
            ComputersNeedingUpdates,
            ComplianceRate,
            AvgCriticalUpdates,
            AvgSecurityUpdates,
            LastAssessment
"@
    
    Write-Host "Update Compliance Report" -ForegroundColor Green
    Write-Host "======================" -ForegroundColor Green
    
    $Results = Invoke-AzOperationalInsightsQuery -WorkspaceName $WorkspaceName -ResourceGroupName $ResourceGroupName -Query $Query
    
    foreach ($Result in $Results.Results) {
        Write-Host "Total Computers: $($Result.TotalComputers)" -ForegroundColor Yellow
        Write-Host "Computers Needing Updates: $($Result.ComputersNeedingUpdates)" -ForegroundColor Yellow
        Write-Host "Compliance Rate: $($Result.ComplianceRate)%" -ForegroundColor $(if ($Result.ComplianceRate -ge 95) { "Green" } elseif ($Result.ComplianceRate -ge 90) { "Yellow" } else { "Red" })
        Write-Host "Average Critical Updates Missing: $($Result.AvgCriticalUpdates)" -ForegroundColor Yellow
        Write-Host "Average Security Updates Missing: $($Result.AvgSecurityUpdates)" -ForegroundColor Yellow
        Write-Host "Last Assessment: $($Result.LastAssessment)" -ForegroundColor Yellow
    }
}

# Usage
Get-UpdateComplianceReport -WorkspaceName "law-production" -ResourceGroupName "rg-monitoring"
```

#### 2. Automated Patch Deployment
```bash
#!/bin/bash
# Bash script for automated patch deployment

SUBSCRIPTION_ID="12345678-1234-1234-1234-123456789012"
RESOURCE_GROUP="rg-production-management"
MAINTENANCE_CONFIG="prod-maintenance-config"

echo "Starting automated patch deployment process"
echo "=========================================="

# Get maintenance configuration
echo "1. Retrieving maintenance configuration"
MAINTENANCE_CONFIG_ID=$(az maintenance configuration show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$MAINTENANCE_CONFIG" \
  --query "id" -o tsv)

echo "   Configuration ID: $MAINTENANCE_CONFIG_ID"

# Get assigned VMs
echo "2. Getting assigned VMs"
ASSIGNED_VMS=$(az maintenance assignment list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[?maintenanceConfigurationId=='$MAINTENANCE_CONFIG_ID'].resourceId" -o tsv)

echo "   Found $(echo "$ASSIGNED_VMs" | wc -l) assigned VMs"

# Trigger update deployment
echo "3. Triggering update deployment"
for VM_ID in $ASSIGNED_VMS; do
  echo "   Deploying updates to: $(basename "$VM_ID")"
  
  az rest \
    --method post \
    --uri "https://management.azure.com${VM_ID}/installPatches?api-version=2021-11-01" \
    --body '{
      "rebootSetting": "IfRequired",
      "windowsParameters": {
        "classificationsToInclude": ["Critical", "Security"],
        "maxPatchPublishDate": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
      },
      "linuxParameters": {
        "classificationsToInclude": ["Critical", "Security"],
        "maxPatchPublishDate": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
      }
    }'
done

echo "4. Deployment process completed"
echo "   Monitor deployment status in Azure portal or via Azure CLI"
```

### Security and Compliance Best Practices

#### 1. RBAC Configuration for Update Manager
```bash
# Create custom role for Update Manager operations
az role definition create --role-definition '{
  "Name": "Update Manager Operator",
  "Description": "Can manage updates and maintenance configurations",
  "Actions": [
    "Microsoft.Maintenance/maintenanceConfigurations/*",
    "Microsoft.Maintenance/configurationAssignments/*",
    "Microsoft.Maintenance/applyUpdates/*",
    "Microsoft.Compute/virtualMachines/installPatches/action",
    "Microsoft.Compute/virtualMachines/assessPatches/action",
    "Microsoft.Insights/scheduledQueryRules/read"
  ],
  "NotActions": [
    "Microsoft.Maintenance/maintenanceConfigurations/delete"
  ],
  "AssignableScopes": ["/subscriptions/{subscription-id}"]
}'

# Assign role to Update Manager team
az role assignment create \
  --role "Update Manager Operator" \
  --assignee "update-team@pge.com" \
  --scope "/subscriptions/{subscription-id}"
```

#### 2. Compliance Automation
```powershell
# PowerShell script for compliance automation
function Set-ComplianceBaseline {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet("SOX", "PCI-DSS", "HIPAA", "FedRAMP")]
        [string]$ComplianceFramework
    )
    
    # Set compliance-specific thresholds
    $ComplianceSettings = @{
        "SOX" = @{
            UpdateCompliance = 98
            CriticalUpdateThreshold = 1
            MaintenanceWindowStrict = $true
        }
        "PCI-DSS" = @{
            UpdateCompliance = 95
            CriticalUpdateThreshold = 1
            SecurityFocus = $true
        }
        "HIPAA" = @{
            UpdateCompliance = 95
            CriticalUpdateThreshold = 1
            DataProtection = $true
        }
        "FedRAMP" = @{
            UpdateCompliance = 98
            CriticalUpdateThreshold = 1
            EnhancedSecurity = $true
        }
    }
    
    $Settings = $ComplianceSettings[$ComplianceFramework]
    
    Write-Host "Configuring compliance baseline for: $ComplianceFramework" -ForegroundColor Green
    Write-Host "Update Compliance Requirement: $($Settings.UpdateCompliance)%" -ForegroundColor Yellow
    Write-Host "Critical Update Threshold: $($Settings.CriticalUpdateThreshold)" -ForegroundColor Yellow
    
    # Additional framework-specific configurations would be implemented here
}

# Usage
Set-ComplianceBaseline -SubscriptionId "12345678-1234-1234-1234-123456789012" -ComplianceFramework "SOX"
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Update Assessment Failures
**Symptoms**: Update assessment failure alerts firing with VMs not reporting update status

**Possible Causes**:
- Update Manager agent not installed or running
- Network connectivity issues to Azure services
- Insufficient permissions for assessment operations
- VM performance or resource constraints

**Troubleshooting Steps**:
```bash
# Check VM agent status
az vm get-instance-view \
  --resource-group "rg-production-vms" \
  --name "vm-web-01" \
  --query "vmAgent.statuses"

# Verify VM extensions
az vm extension list \
  --resource-group "rg-production-vms" \
  --vm-name "vm-web-01" \
  --query "[?name=='MicrosoftMonitoringAgent']"

# Test connectivity to Update Manager services
az vm run-command invoke \
  --resource-group "rg-production-vms" \
  --name "vm-web-01" \
  --command-id "RunShellScript" \
  --scripts "curl -I https://management.azure.com"
```

**Resolution**:
- Install or reinstall Update Manager agent
- Verify network security group and firewall rules
- Check VM performance and available resources
- Validate managed identity or service principal permissions

#### 2. Patch Installation Failures
**Symptoms**: Patch installation failure alerts with updates failing to install

**Possible Causes**:
- Insufficient disk space for updates
- Application conflicts or locked files
- VM restart requirements not met
- Update package corruption or conflicts

**Troubleshooting Steps**:
```powershell
# Check disk space on VM
Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, 
    @{Name="Size(GB)";Expression={[math]::Round($_.Size/1GB,2)}},
    @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
    @{Name="PercentFree";Expression={[math]::Round(($_.FreeSpace/$_.Size)*100,2)}}

# Check Windows Update logs
Get-WindowsUpdateLog

# Review pending restart status
if (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA SilentlyContinue) { 
    Write-Host "Restart Required" 
}
```

**Resolution**:
- Free up disk space on affected VMs
- Schedule maintenance window for VM restarts
- Resolve application conflicts preventing updates
- Clear Windows Update cache and retry installation

#### 3. Maintenance Window Violations
**Symptoms**: Maintenance window violation alerts with updates installed outside approved windows

**Possible Causes**:
- Emergency security updates bypassing normal processes
- Misconfigured maintenance schedules
- Manual updates installed outside automation
- Time zone configuration issues

**Troubleshooting Steps**:
```bash
# Review recent update deployments
az maintenance applyupdate list \
  --resource-group "rg-production-management" \
  --query "[?status=='Succeeded' || status=='Failed'].{ResourceId:resourceId,Status:status,StartDateTime:startDateTime,EndDateTime:endDateTime}"

# Check maintenance configuration
az maintenance configuration show \
  --resource-group "rg-production-management" \
  --name "prod-maintenance-config" \
  --query "{StartDateTime:startDateTime,Duration:duration,TimeZone:timeZone,RecurEvery:recurEvery}"

# Review activity logs for manual interventions
az monitor activity-log list \
  --resource-group "rg-production-vms" \
  --start-time "2023-11-01T00:00:00Z" \
  --query "[?contains(operationName,'Microsoft.Compute/virtualMachines')]"
```

**Resolution**:
- Review and document emergency update justifications
- Adjust maintenance window configurations for proper time zones
- Implement stricter change management controls
- Update maintenance schedules to align with business requirements

#### 4. Low Update Compliance
**Symptoms**: Update compliance alerts firing with overall compliance below thresholds

**Possible Causes**:
- Delayed or failed update deployments
- VMs not properly assigned to maintenance configurations
- Excluded updates creating compliance gaps
- System compatibility issues preventing updates

**Troubleshooting Steps**:
```bash
# Check compliance status across VMs
az graph query -q "
  patchassessmentresources
  | where type =~ 'microsoft.compute/virtualmachines/patchassessmentresults'
  | extend 
    vmName = split(id, '/')[8],
    osType = properties.osType,
    criticalUpdates = properties.criticalAndSecurityPatchCount,
    otherUpdates = properties.otherPatchCount,
    assessmentTime = properties.lastModifiedTime
  | project vmName, osType, criticalUpdates, otherUpdates, assessmentTime
  | order by criticalUpdates desc
"

# Review maintenance assignments
az maintenance assignment list \
  --resource-group "rg-production-vms" \
  --query "[].{ResourceName:resourceName,ConfigurationId:maintenanceConfigurationId}"
```

**Resolution**:
- Ensure all VMs are properly assigned to maintenance configurations
- Review and reduce update exclusions where possible
- Investigate and resolve system compatibility issues
- Implement more frequent assessment and deployment cycles

### Advanced Monitoring Setup

#### 1. Custom Update Management Dashboard
```json
{
  "dashboard": {
    "title": "Azure Update Manager Compliance Dashboard",
    "panels": [
      {
        "title": "Overall Compliance Rate",
        "query": "UpdateSummary | summarize ComplianceRate = avg(100 * (TotalUpdatesMissing + 1 - TotalUpdatesMissing) / (TotalUpdatesMissing + 1)) | render gauge"
      },
      {
        "title": "Critical Updates Available",
        "query": "Update | where UpdateState == 'Needed' and Classification == 'Critical Updates' | summarize count() by Computer | render columnchart"
      },
      {
        "title": "Update Installation Success Rate",
        "query": "Update | where UpdateState in ('Installed', 'Failed') | summarize Installed=countif(UpdateState=='Installed'), Failed=countif(UpdateState=='Failed') | extend SuccessRate = 100.0 * Installed / (Installed + Failed)"
      },
      {
        "title": "Compliance Trend",
        "query": "UpdateSummary | summarize ComplianceRate = avg(100 * (TotalUpdatesMissing + 1 - TotalUpdatesMissing) / (TotalUpdatesMissing + 1)) by bin(TimeGenerated, 1d) | render timechart"
      }
    ]
  }
}
```

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

**Note**: This module is designed for Azure Update Manager monitoring and follows PGE operational standards. Ensure proper testing in non-production environments before deploying to production workloads. Regular review and adjustment of alert thresholds based on actual update patterns, compliance requirements, and organizational policies is recommended for optimal patch management effectiveness.