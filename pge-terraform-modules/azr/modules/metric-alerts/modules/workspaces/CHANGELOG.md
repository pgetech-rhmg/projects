# Changelog

All notable changes to the Azure Log Analytics Workspace Monitoring module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added

#### Scheduled Query Rules (6 total)
- **Heartbeat Alert**: `workspace-heartbeat-missing`
  - Severity: 2 (Warning)
  - Query: Detects agents that haven't sent heartbeat in 10 minutes within 15-minute window
  - Evaluation frequency: PT5M (5 minutes)
  - Window duration: PT15M (15 minutes)
  - Default threshold: 5 missing heartbeats
  - Monitors agent health and connectivity across all monitored workspaces
  - Critical for ensuring continuous data collection

- **Query Performance Alert**: `workspace-query-performance-slow`
  - Severity: 3 (Informational)
  - Query: Identifies queries exceeding performance threshold from Operation table
  - Evaluation frequency: PT15M (15 minutes)
  - Window duration: PT30M (30 minutes)
  - Default threshold: 30,000ms (30 seconds)
  - Monitors workspace query efficiency
  - Helps identify and optimize slow-running queries

- **Data Retention Alert**: `workspace-data-retention-expiring`
  - Severity: 3 (Informational)
  - Query: Warns when billable data approaches retention limit
  - Evaluation frequency: P1D (1 day)
  - Window duration: P1D (1 day)
  - Default warning period: 7 days before expiry
  - Configurable retention days (default: 30)
  - Prevents unexpected data loss from retention policies

- **Error Rate Alert**: `workspace-error-rate-high`
  - Severity: 2 (Warning)
  - Query: Calculates error percentage from Operation table (Failed vs Total)
  - Evaluation frequency: PT15M (15 minutes)
  - Window duration: PT30M (30 minutes)
  - Default threshold: 10% error rate
  - Monitors operational health of workspace
  - Detects systemic issues in data collection or processing

- **Agent Connection Alert**: `workspace-agent-connection-lost`
  - Severity: 3 (Informational)
  - Query: Detects connection/timeout issues from Operation table (Data Collection category)
  - Evaluation frequency: PT15M (15 minutes)
  - Window duration: PT1H (1 hour)
  - Default threshold: 5 connection issues per computer
  - Monitors network connectivity for agents
  - Identifies infrastructure or network problems

- **Custom Table Ingestion Alert**: `workspace-custom-table-ingestion-low`
  - Severity: 3 (Informational)
  - Query: Monitors data volume for specified custom tables from Usage table
  - Evaluation frequency: PT30M (30 minutes)
  - Window duration: PT2H (2 hours)
  - Default threshold: 100 MB minimum ingestion
  - Configurable custom table list
  - Ensures critical custom data is being ingested properly

#### Diagnostic Settings (2 total)
- **Event Hub Integration**: `send-workspace-logs-to-eventhub`
  - Captures Audit log category
  - Supports cross-subscription Event Hub configuration
  - Use case: SIEM integration, external monitoring, compliance
  - Conditionally enabled based on Event Hub name availability

- **Log Analytics Integration**: `send-workspace-logs-to-loganalytics`
  - Captures Audit log category
  - Includes AllMetrics for comprehensive monitoring
  - Supports cross-subscription Log Analytics workspace configuration
  - Use case: Centralized workspace audit logging, KQL queries, dashboards
  - Conditionally enabled based on Log Analytics workspace name availability

#### Log Categories
- **Audit**: Workspace management and access events
  - Configuration changes
  - Access and authentication events
  - Query execution (administrative)
  - Data collection modifications
  - Workspace management operations
  - Essential for compliance and security monitoring

#### Module Features
- **Multi-Workspace Support**: Monitor multiple Log Analytics Workspaces with a single module call
- **Cross-Subscription Diagnostics**: Event Hub and Log Analytics can be in different subscriptions
- **Flexible Alert Configuration**: Enable/disable each alert type independently
- **Configurable Thresholds**: Customize sensitivity for each alert type
- **Custom Table Monitoring**: Specify which custom tables to monitor for ingestion
- **Retention Management**: Configurable retention period and warning days
- **Comprehensive Outputs**: Alert IDs, diagnostic setting IDs, monitored resources, configuration summary
- **Tagging Support**: Apply consistent tags to all monitoring resources

#### Examples
- **Production Example**: 3 workspaces (security, operations, applications) with all 6 alerts and full diagnostics
- **Development Example**: 2 workspaces with core alerts (3) and Log Analytics only
- **Basic Example**: 1 workspace with heartbeat alert only (minimal monitoring)
- All examples include proper tagging and documentation

#### Documentation
- Comprehensive README with module overview and usage instructions
- Detailed examples README with scenario-based guidance
- Variable descriptions and validation rules
- KQL query optimization guidance
- Cost optimization strategies
- Troubleshooting guide for each alert type

#### Infrastructure
- Terraform version constraint: >= 1.0
- Azure provider version constraint: >= 3.0, < 5.0
- Proper version pinning for registry compatibility
- Formatted code following Terraform best practices

### Implementation Notes

#### Query Design Philosophy
All queries are designed for:
- **Performance**: Time filters first, indexed columns, minimal aggregation
- **Accuracy**: Clear thresholds, appropriate aggregation methods
- **Reliability**: Handle missing data gracefully, avoid false positives

#### Alert Threshold Recommendations
- **Production**:
  - Heartbeat: 3 (strict monitoring)
  - Query Performance: 20,000ms (20 seconds)
  - Error Rate: 5% (tight control)
  - Agent Connection: 3 (sensitive)
  - Custom Table: 50 MB (environment-specific)

- **Development**:
  - Heartbeat: 10 (more lenient)
  - Query Performance: 60,000ms (60 seconds)
  - Error Rate: 20% (relaxed)

- **Test**:
  - Heartbeat: 10 (minimal monitoring)

#### Diagnostic Settings Logic
- **Event Hub**: Enabled when `enable_diagnostic_settings = true` AND `eventhub_name != ""`
- **Log Analytics**: Enabled when `enable_diagnostic_settings = true` AND `log_analytics_workspace_name != ""`
- **Flexibility**: Can enable one, both, or neither diagnostic destination

#### Cross-Subscription Support
Allows centralized monitoring infrastructure:
```hcl
# Event Hub in shared services subscription
eventhub_subscription_id = "different-subscription-id"
eventhub_resource_group_name = "rg-shared-monitoring"

# Central Log Analytics in shared subscription  
log_analytics_subscription_id = "another-subscription-id"
log_analytics_resource_group_name = "rg-central-logging"
```

#### Custom Table Monitoring
Best practices:
- Use custom tables with predictable ingestion patterns
- Monitor business-critical custom data sources
- Adjust thresholds based on expected data volume
- Custom table names typically end with `_CL`

### Testing

- ✅ Terraform fmt: Code formatting validated
- ✅ Terraform init: Provider initialization successful
- ✅ Terraform validate: Configuration syntax validated
- ✅ Examples validated: All three example configurations tested
- ✅ KQL queries tested: All queries validated in Azure Portal

### Breaking Changes

None - Initial release

### Migration Guide

Not applicable - Initial release

### Known Issues

1. **Operation Table Availability**: Some queries rely on the Operation table which may not be populated immediately in new workspaces. Allow 24-48 hours for initial data collection.

2. **Custom Table Naming**: Custom table names must be specified exactly as they appear in the workspace, including the `_CL` suffix for custom log tables.

3. **Heartbeat Data Dependency**: Heartbeat alert requires agents to be connected and sending data. New workspaces without agents will not trigger this alert.

4. **Query Performance Metric**: The query performance alert uses OperationKey field which may vary in format. Adjust threshold based on actual observed values.

5. **Retention Alert Accuracy**: Data retention alert assumes consistent data ingestion. Sparse or inconsistent ingestion may cause inaccurate warnings.

### Dependencies

- **Required Providers**:
  - hashicorp/azurerm >= 3.0, < 5.0

- **Required Resources**:
  - Azure Log Analytics Workspace(s)
  - Azure Monitor Action Group
  - Resource Group(s)

- **Optional Resources**:
  - Event Hub Namespace and Event Hub (for SIEM integration)
  - Central Log Analytics Workspace (for audit log aggregation)
  - Log Analytics Agents (for heartbeat monitoring)

- **Data Requirements**:
  - Heartbeat table: Requires agents sending heartbeat data
  - Operation table: Requires workspace operations data (auto-collected)
  - Usage table: Requires workspace usage data (auto-collected)

### Security Considerations

- **Audit Logs**: Contain sensitive workspace configuration and access information
- **Query Logging**: Operation table may contain query text (review for sensitive data)
- **Access Control**: Ensure diagnostic destinations have appropriate access controls
- **Compliance**: Supports regulatory requirements for workspace access monitoring
- **Alert Notifications**: Ensure action group recipients are authorized

### Performance Impact

- **Query Execution**: All queries optimized with time filters and indexed columns
- **Evaluation Frequency**: Ranges from PT5M (5 minutes) to P1D (1 day)
- **Workspace Impact**: Minimal - queries are read-only and optimized
- **Cost**: Scheduled query rules: ~$0.50/rule/month per alert
- **Data Ingestion**: Diagnostic settings add minimal audit log volume

## [Unreleased]

### Planned Features
- Support for capacity-based pricing alerts
- Integration with Azure Policy for compliance monitoring
- Advanced query performance analytics
- Workspace health scoring
- Multi-region workspace aggregation
- Data export monitoring alerts

---

## Version History Summary

| Version | Date | Scheduled Query Rules | Diagnostics | Key Features |
|---------|------|----------------------|-------------|--------------|
| 1.0.0 | 2024-01-15 | 6 | 2 | Initial release with comprehensive workspace monitoring |

---

## Upgrading

### To 1.0.0
Initial release - no upgrade required.

---

## Support

For issues, questions, or contributions:
1. Review the module README and examples
2. Check Azure Log Analytics Workspace documentation
3. Test KQL queries in Azure Portal
4. Verify workspace data ingestion and table availability
5. Contact your Azure administrator or cloud platform team

---

## Contributors

This module is maintained by the Cloud Center of Excellence (CCoE) team.

---

## License

This module follows the same license as the parent repository.
