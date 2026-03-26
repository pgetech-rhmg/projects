# Cosmos DB Metric Alerts Module - Examples

This directory contains examples demonstrating how to use the Cosmos DB metric alerts module.

## Examples

### 1. Production Environment
Demonstrates a production setup with:
- Strict availability threshold (99.99%)
- Low latency tolerance (5ms)
- Conservative RU consumption limits (8000 RU)
- Low normalized RU threshold (70%)
- Strict capacity thresholds
- All alert categories enabled
- Diagnostic settings to Event Hub and Log Analytics
- Support for multiple Cosmos DB accounts across regions

### 2. Development Environment
Shows a development configuration with:
- Relaxed availability threshold (99.0%)
- Higher latency tolerance (20ms)
- Higher RU consumption limits (15000 RU)
- Relaxed normalized RU threshold (90%)
- More lenient capacity thresholds
- Diagnostic settings enabled
- Single region deployment

### 3. Basic Configuration
Minimal setup using:
- Default thresholds from variables.tf
- Single Cosmos DB account
- Diagnostic settings disabled
- Suitable for testing or non-critical environments

## Usage

```hcl
module "cosmos_alerts" {
  source = "path/to/modules/metricAlerts/cosmos"

  resource_group_name                = "rg-cosmos-prod"
  action_group_resource_group_name   = "rg-monitoring-prod"
  action_group                       = "pge-operations-actiongroup"
  
  cosmos_account_names = [
    "cosmos-app-prod-eastus",
    "cosmos-app-prod-westus"
  ]

  # Customize thresholds as needed
  cosmos_availability_threshold                = 99.99
  cosmos_server_side_latency_threshold         = 5
  cosmos_ru_consumption_threshold              = 8000
  cosmos_normalized_ru_consumption_threshold   = 70

  # Enable diagnostic settings
  enable_diagnostic_settings           = true
  eventhub_namespace_name              = "evhns-monitoring-prod"
  eventhub_name                        = "evh-cosmos-logs"
  log_analytics_workspace_name         = "law-security-prod"

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
```

## Outputs

All examples demonstrate how to access module outputs:

- `alert_ids` - Map of all alert resource IDs
- `alert_names` - Map of all alert names
- `diagnostic_settings` - Diagnostic settings configuration
- `monitored_cosmos_accounts` - List of monitored Cosmos DB accounts
- `action_group_id` - Action group resource ID

## Alert Types

The module creates the following metric alerts for each Cosmos DB account:

1. **Availability Alert** (Severity 1)
   - Metric: ServiceAvailability
   - Triggers when availability drops below threshold
   - Default: 99.9%

2. **Server Side Latency Alert** (Severity 2)
   - Metric: ServerSideLatency
   - Monitors backend processing time
   - Default: 10ms

3. **RU Consumption Alert** (Severity 2)
   - Metric: TotalRequestUnits
   - Tracks total request units consumed
   - Default: 10,000 RU

4. **Normalized RU Consumption Alert** (Severity 2)
   - Metric: NormalizedRUConsumption
   - Monitors RU usage percentage
   - Default: 80%

5. **Total Requests Alert** (Severity 3)
   - Metric: TotalRequests
   - Monitors request volume
   - Default: 10,000 requests

6. **Metadata Requests Alert** (Severity 2)
   - Metric: MetadataRequests
   - Tracks metadata operations
   - Default: 100 requests

7. **Data Usage Alert** (Severity 2)
   - Metric: DataUsage
   - Monitors data storage
   - Default: 80 GB

8. **Index Usage Alert** (Severity 2)
   - Metric: IndexUsage
   - Tracks index storage
   - Default: 10 GB

9. **Provisioned Throughput Alert** (Severity 2)
   - Metric: ProvisionedThroughput
   - Monitors provisioned RU/s
   - Default: 40,000 RU/s

## Diagnostic Settings

When enabled, the module creates diagnostic settings to:
- Send activity logs to Event Hub
- Send security logs to Log Analytics workspace
- Support cross-subscription scenarios

## Cross-Subscription Support

The module supports Event Hub and Log Analytics in different subscriptions:

```hcl
eventhub_subscription_id            = "00000000-0000-0000-0000-000000000000"
eventhub_resource_group_name        = "rg-eventhub-prod"
log_analytics_subscription_id       = "00000000-0000-0000-0000-000000000000"
log_analytics_resource_group_name   = "rg-loganalytics-prod"
```

## Prerequisites

- Azure subscription with appropriate permissions
- Existing Cosmos DB accounts
- Existing action group for alert notifications
- (Optional) Event Hub namespace and Log Analytics workspace for diagnostic settings

## Notes

- All thresholds are customizable per environment
- Alert creation is conditional based on `cosmos_account_names` list
- Empty `cosmos_account_names` list disables all alert creation
- Diagnostic settings can be independently enabled/disabled
- Tags are applied to all alert resources
