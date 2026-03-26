# Changelog

All notable changes to the Azure Update Manager Monitoring module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added
- Initial release of Azure Update Manager Monitoring module
- **Activity Log Alerts** (6 total):
  - Update Deployment Started Alert - Monitors deployment initiation
  - Update Deployment Failed Alert - Monitors deployment failures
  - Maintenance Configuration Change Alert - Monitors config modifications
  - Maintenance Configuration Deleted Alert - Monitors config deletions
  - Update Assessment Triggered Alert - Monitors assessment operations
  - VM Update Failed Alert - Monitors VM-level update failures
- **Scheduled Query Rules** (6 total):
  - Update Compliance Low Alert (Severity 2) - Monitors compliance percentage
  - Critical Updates Available Alert (Severity 1) - Monitors critical/security updates
  - Update Installation Failures Alert (Severity 1) - Monitors installation failures
  - Update Assessment Failures Alert (Severity 2) - Monitors assessment issues
  - Maintenance Window Violations Alert (Severity 2) - Monitors off-hours updates
- **Features**:
  - Subscription-level activity log monitoring via `subscription_ids` list
  - VM-specific compliance monitoring via `vm_resource_ids` list
  - Configurable alert thresholds for all monitoring scenarios
  - Selective alert enablement via feature flags
  - Log Analytics-based scheduled query rules for advanced monitoring
  - Update compliance tracking with configurable percentage thresholds
  - Critical update detection for immediate response
  - Maintenance window violation detection (2-6 AM, weekdays)
  - Comprehensive outputs including alert IDs and configuration summary
  - Support for custom tags on all alert resources
- **Examples**:
  - Production Update Manager with full monitoring (5 VMs, 95% compliance)
  - Development Update Manager with relaxed monitoring (3 VMs, 80% compliance)
  - Basic Update Manager with minimal monitoring (1 VM, 70% compliance)
  - Environment-specific threshold configurations
  - Cost-optimized configurations for different environments
- **Documentation**:
  - Comprehensive README with usage instructions
  - Detailed examples with multiple deployment patterns
  - Alert descriptions and threshold guidance
  - Troubleshooting guide for common issues
  - Cost optimization recommendations
  - Log Analytics query examples

### Requirements
- Terraform >= 1.0
- AzureRM Provider >= 3.0, < 5.0
- Azure VMs enrolled in Azure Update Manager
- Log Analytics workspace for scheduled query rules
- Pre-configured Azure Monitor Action Group
- Update Management or Azure Update Manager solution enabled

### Configuration
- **Alert Categories**:
  - Update Deployment Monitoring (2 activity log alerts)
  - Maintenance Configuration Monitoring (2 activity log alerts)
  - Assessment Monitoring (1 activity log alert + 1 scheduled query rule)
  - Update Failure Monitoring (1 activity log alert + 1 scheduled query rule)
  - Compliance Monitoring (1 scheduled query rule)
  - Critical Update Monitoring (1 scheduled query rule)
  - Maintenance Window Monitoring (1 scheduled query rule)
- **Supported Operations**:
  - Microsoft.Maintenance/maintenanceConfigurations/*
  - Microsoft.Maintenance/applyUpdates/*
  - Microsoft.Maintenance/configurationAssignments/*
  - Microsoft.Compute/virtualMachines/extensions/*
- **Log Analytics Tables**:
  - Update (update records, classifications, states)
  - UpdateSummary (assessment summaries, compliance)
- **Default Thresholds**:
  - Update Deployment Failure: >= 1 failure
  - Update Compliance: < 90%
  - Patch Installation Failure: >= 1 failure
  - Update Assessment Failure: >= 1 failure
  - Critical Update Available: >= 1 update
  - Maintenance Window: Outside 2-6 AM weekdays
- **Default Evaluation Frequencies**:
  - Update Compliance: Daily (P1D)
  - Critical Updates: Daily (P1D)
  - Installation Failures: Hourly (PT1H)
  - Assessment Failures: Every 6 hours (PT6H)
  - Maintenance Violations: Hourly (PT1H)

### Notes
- Activity log alerts require `subscription_ids` to be provided
- Scheduled query rules require both `subscription_ids` and `vm_resource_ids` to be provided
- All alerts disabled if respective lists are empty
- Log Analytics workspace must have Update Management solution enabled
- Scheduled query rules evaluate against Update and UpdateSummary tables
- Maintenance window violations check for updates outside 2-6 AM on weekdays
- Update compliance calculation: 100 - (needed updates / total updates * 100)
- Critical updates include both "Critical Updates" and "Security Updates" classifications
