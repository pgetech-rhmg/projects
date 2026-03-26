# Changelog

All notable changes to the Azure Virtual Network Monitoring module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added

#### Metric Alerts (1 total)
- **DDoS Attack Detection Alert**: `if_under_DDOS_Attack`
  - Monitors `IfUnderDDoSAttack` metric from `Microsoft.Network/virtualNetworks`
  - Severity: 1 (Warning)
  - Default threshold: 0 (triggers on any DDoS attack detected)
  - Evaluation frequency: PT1M (1 minute)
  - Evaluation window: PT5M (5 minutes)
  - Aggregation: Maximum
  - Provides immediate notification when VNet is under DDoS attack
  - Critical for rapid incident response and mitigation

#### Diagnostic Settings (2 total)
- **Event Hub Integration**: `send-vnet-logs-to-eventhub`
  - Captures VMProtectionAlerts log category
  - Supports cross-subscription Event Hub configuration
  - Use case: SIEM integration, external monitoring, compliance
  - Conditionally enabled based on Event Hub name availability

- **Log Analytics Integration**: `send-vnet-logs-to-loganalytics`
  - Captures VMProtectionAlerts log category
  - Includes AllMetrics for comprehensive monitoring
  - Supports cross-subscription Log Analytics workspace configuration
  - Use case: Centralized logging, KQL queries, Azure dashboards
  - Conditionally enabled based on Log Analytics workspace name availability

#### Log Categories
- **VMProtectionAlerts**: Network security and protection events
  - DDoS attack detection events
  - Network protection alerts
  - Security policy violations
  - Threat intelligence matches
  - Essential for security monitoring and incident response

#### Module Features
- **Multi-VNet Support**: Monitor multiple Virtual Networks with a single module call
- **Cross-Subscription Diagnostics**: Event Hub and Log Analytics can be in different subscriptions
- **Flexible Configuration**: Enable/disable diagnostic settings independently
- **Comprehensive Outputs**: Alert IDs, diagnostic setting IDs, monitored resources, configuration summary
- **Tagging Support**: Apply consistent tags to all monitoring resources

#### Examples
- **Production Example**: 3 VNets (hub-spoke topology) with both Event Hub and Log Analytics
- **Development Example**: 2 VNets with Log Analytics only (cost-optimized)
- **Basic Example**: 1 VNet with alerts only (minimal monitoring)
- All examples include proper tagging and documentation

#### Documentation
- Comprehensive README with module overview and usage instructions
- Detailed examples README with scenario-based guidance
- Variable descriptions and validation rules
- DDoS Protection Plan guidance and best practices
- Cost optimization strategies
- Troubleshooting guide

#### Infrastructure
- Terraform version constraint: >= 1.0
- Azure provider version constraint: >= 3.0, < 5.0
- Proper version pinning for registry compatibility
- Formatted code following Terraform best practices

### Implementation Notes

#### DDoS Protection Context
The `IfUnderDDoSAttack` metric is most effective when used with Azure DDoS Protection Standard plan:
- **Without Standard Plan**: Basic protection included, but limited metrics
- **With Standard Plan**: Enhanced detection, auto-mitigation, real-time metrics, attack analytics
- **Cost**: DDoS Protection Standard is $2,944/month at subscription level (protects all VNets)
- **Recommendation**: Enable Standard plan for production workloads

#### Alert Threshold
- Default threshold: 0 (recommended)
- Triggers on any detected DDoS attack
- Alternative thresholds generally not recommended as they may miss attacks
- Metric values: 0 = no attack, 1 = attack in progress

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

# Log Analytics in central logging subscription  
log_analytics_subscription_id = "another-subscription-id"
log_analytics_resource_group_name = "rg-central-logging"
```

### Testing

- ✅ Terraform fmt: Code formatting validated
- ✅ Terraform init: Provider initialization successful
- ✅ Terraform validate: Configuration syntax validated
- ✅ Examples validated: All three example configurations tested
- ✅ Variable validation: Input constraints verified

### Breaking Changes

None - Initial release

### Migration Guide

Not applicable - Initial release

### Known Issues

1. **Metric Availability**: The `IfUnderDDoSAttack` metric requires Azure DDoS Protection to be enabled (Basic or Standard). Without DDoS Protection, the metric may not populate.

2. **Deprecated Dynamic Blocks**: Terraform provider shows warnings about deprecated dynamic blocks in metric alert criteria. These warnings are cosmetic and do not affect functionality. Updates will be made when the provider offers a stable alternative.

3. **Cross-Subscription IAM**: When using cross-subscription diagnostic settings, ensure the deployment identity has appropriate permissions on the target Event Hub namespace and Log Analytics workspace.

### Dependencies

- **Required Providers**:
  - hashicorp/azurerm >= 3.0, < 5.0

- **Required Resources**:
  - Azure Virtual Network(s)
  - Azure Monitor Action Group
  - Resource Group(s)

- **Optional Resources**:
  - Event Hub Namespace and Event Hub (for SIEM integration)
  - Log Analytics Workspace (for centralized logging)
  - DDoS Protection Standard Plan (for enhanced protection)

### Security Considerations

- **Network Protection**: Alert provides immediate notification of DDoS attacks
- **Log Security**: VMProtectionAlerts contain sensitive network security information
- **Access Control**: Ensure diagnostic destinations have appropriate access controls
- **Compliance**: Supports regulatory requirements for network monitoring and logging

### Performance Impact

- **Alert Evaluation**: Every 1 minute (PT1M frequency)
- **Metric Collection**: Azure platform-managed, no performance impact on VNets
- **Log Volume**: VMProtectionAlerts typically low volume unless under attack
- **Cost**: Minimal - approximately $0.10-2/month per VNet depending on configuration

## [Unreleased]

### Planned Features
- Support for additional VNet metrics as they become available
- Integration with Azure Policy for compliance monitoring
- Custom alert rules for specific attack patterns
- Enhanced cross-region monitoring capabilities

---

## Version History Summary

| Version | Date | Alerts | Diagnostics | Key Features |
|---------|------|--------|-------------|--------------|
| 1.0.0 | 2024-01-15 | 1 | 2 | Initial release with DDoS attack detection |

---

## Upgrading

### To 1.0.0
Initial release - no upgrade required.

---

## Support

For issues, questions, or contributions:
1. Review the module README and examples
2. Check Azure Virtual Network and DDoS Protection documentation
3. Verify VNet configuration and DDoS Protection status
4. Contact your Azure administrator or cloud platform team

---

## Contributors

This module is maintained by the Cloud Center of Excellence (CCoE) team.

---

## License

This module follows the same license as the parent repository.
