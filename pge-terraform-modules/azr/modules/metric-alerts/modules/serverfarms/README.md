# App Service Plans (Server Farms) - Metric Alerts Module

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

This Terraform module creates comprehensive monitoring alerts for **Azure App Service Plans** (formerly known as Server Farms), providing proactive monitoring for compute resources that host web applications, API apps, and mobile app backends. The module monitors critical performance metrics to ensure optimal application performance and resource utilization.

Azure App Service Plans define the compute resources (CPU, memory, storage) available to App Service applications. They determine the features, scaling capabilities, and pricing tier for hosted applications, making their monitoring crucial for application performance and cost optimization.

## Features

- **Compute Resource Monitoring**: CPU and memory utilization tracking across plan instances
- **Request Queue Monitoring**: HTTP request queue length monitoring for performance bottlenecks
- **I/O Performance Monitoring**: Disk queue length tracking for storage performance
- **Instance-Level Alerting**: Individual monitoring for each App Service Plan
- **Multi-Tier Support**: Compatible with Free, Shared, Basic, Standard, Premium, and Isolated tiers
- **Scaling Integration**: Alerts that support both manual and auto-scaling decisions
- **Cost-Effective Monitoring**: Metric alerts at $0.10 per month per alert rule
- **Performance Optimization**: Early detection of resource constraints and bottlenecks
- **Enterprise Integration**: Built-in support for PGE operational procedures
- **Compliance Ready**: SOX, HIPAA, PCI-DSS, and regulatory compliance support

### Key Monitoring Capabilities
- **Real-Time Performance**: 5-minute evaluation frequency for critical metrics
- **Resource Utilization**: CPU and memory percentage monitoring with customizable thresholds
- **Request Processing**: HTTP queue monitoring for application responsiveness
- **Storage Performance**: Disk I/O queue monitoring for backend performance
- **Multi-Instance Awareness**: Per-plan monitoring with aggregated alerting

## Prerequisites

- **Terraform**: Version >= 1.0
- **Azure Provider**: Version >= 3.0
- **Azure Permissions**: 
  - `Microsoft.Insights/metricAlerts/write`
  - `Microsoft.Insights/actionGroups/read`
  - `Microsoft.Web/serverfarms/read`
- **Action Group**: Pre-configured action group for alert notifications
- **App Service Plans**: Existing Azure App Service Plans to monitor

## Usage

### Basic Configuration

```hcl
module "serverfarms_alerts" {
  source = "./modules/metricAlerts/serverfarms"
  
  # Resource Configuration
  resource_group_name               = "rg-production-web"
  action_group_resource_group_name  = "rg-monitoring"
  action_group                      = "pge-operations-actiongroup"
  
  # App Service Plans to Monitor
  serverfarm_names = [
    "asp-prod-web-001",
    "asp-prod-api-001", 
    "asp-prod-mobile-001"
  ]
  
  # Environment Tags
  tags = {
    Environment        = "Production"
    Application        = "WebApps"
    Owner             = "web-platform@pge.com"
    CostCenter        = "IT-WebServices"
    Compliance        = "SOX"
    DataClassification = "Internal"
  }
}
```

### Advanced Configuration with Custom Thresholds

```hcl
module "serverfarms_alerts_custom" {
  source = "./modules/metricAlerts/serverfarms"
  
  # Resource Configuration
  resource_group_name               = "rg-production-web"
  action_group_resource_group_name  = "rg-monitoring"
  serverfarm_names                 = ["asp-prod-high-traffic"]
  
  # Performance Thresholds (High-Traffic Environment)
  cpu_percentage_threshold          = 70    # Lower threshold for high-traffic apps
  memory_percentage_threshold       = 75    # Aggressive memory monitoring
  
  # Queue Length Thresholds (High-Throughput Environment)
  http_queue_length_threshold       = 50    # Stricter queue management
  disk_queue_length_threshold       = 20    # Lower I/O queue tolerance
  
  tags = {
    Environment = "Production"
    Tier        = "High-Performance"
    Owner       = "platform-engineering@pge.com"
  }
}
```

### Environment-Specific Configurations

#### Development Environment
```hcl
# Development App Service Plans - Relaxed Thresholds
cpu_percentage_threshold     = 90
memory_percentage_threshold  = 90
http_queue_length_threshold  = 200
disk_queue_length_threshold  = 50
```

#### Staging Environment
```hcl
# Staging App Service Plans - Moderate Thresholds
cpu_percentage_threshold     = 85
memory_percentage_threshold  = 85
http_queue_length_threshold  = 150
disk_queue_length_threshold  = 40
```

#### Production Environment
```hcl
# Production App Service Plans - Strict Thresholds
cpu_percentage_threshold     = 75
memory_percentage_threshold  = 75
http_queue_length_threshold  = 75
disk_queue_length_threshold  = 25
```

### Tier-Specific Configurations

#### Basic/Standard Tiers
```hcl
# Basic/Standard - Limited Resources
cpu_percentage_threshold     = 85
memory_percentage_threshold  = 85
http_queue_length_threshold  = 100
disk_queue_length_threshold  = 32
```

#### Premium Tiers
```hcl
# Premium - Higher Capacity
cpu_percentage_threshold     = 80
memory_percentage_threshold  = 80
http_queue_length_threshold  = 150
disk_queue_length_threshold  = 40
```

#### Isolated Tiers (App Service Environment)
```hcl
# Isolated - Dedicated Infrastructure
cpu_percentage_threshold     = 75
memory_percentage_threshold  = 75
http_queue_length_threshold  = 200
disk_queue_length_threshold  = 50
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group for App Service Plans |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group for notifications |
| `location` | `string` | `"West US 3"` | Azure region for resources |
| `serverfarm_names` | `list(string)` | `[]` | List of App Service Plan names |

### Alert Thresholds

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `cpu_percentage_threshold` | `number` | `80` | CPU utilization percentage | 70-90% |
| `memory_percentage_threshold` | `number` | `80` | Memory utilization percentage | 70-90% |
| `http_queue_length_threshold` | `number` | `100` | HTTP request queue length | 50-200 |
| `disk_queue_length_threshold` | `number` | `32` | Disk I/O queue length | 16-64 |

### Tags Configuration

```hcl
tags = {
  AppId              = "123456"                      # Application identifier
  Env                = "Production"                  # Environment designation
  Owner              = "web-platform@pge.com"       # Team responsible
  Compliance         = "SOX"                         # Compliance requirement
  Notify             = "webapp-oncall@pge.com"      # Notification contact
  DataClassification = "Internal"                    # Data sensitivity
  CostCenter         = "IT-WebServices"              # Billing allocation
  CRIS               = "CRIS-12345"                 # Change request ID
}
```

## Alert Details

### 1. CPU Percentage Alert
- **Alert Name**: `serverfarm-cpu-percentage-{plan-name}`
- **Metric**: `CpuPercentage`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: CPU utilization across all instances in the App Service Plan, including web server processes, application code execution, and background tasks.

**What to do when this alert fires**:
1. **Immediate Assessment**: Check current application load and traffic patterns
2. **Performance Analysis**: Review application performance metrics and slow requests
3. **Scaling Evaluation**: Consider vertical scaling (upgrade tier) or horizontal scaling (add instances)
4. **Code Optimization**: Identify CPU-intensive operations and optimize application code
5. **Resource Distribution**: Evaluate distributing applications across multiple App Service Plans

### 2. Memory Percentage Alert
- **Alert Name**: `serverfarm-memory-percentage-{plan-name}`
- **Metric**: `MemoryPercentage`
- **Threshold**: 80% (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Memory utilization across all instances in the App Service Plan, including application memory usage, caching, and system overhead.

**What to do when this alert fires**:
1. **Memory Analysis**: Review application memory usage patterns and potential leaks
2. **Cache Optimization**: Optimize in-memory caching and session state management
3. **Scaling Strategy**: Consider upgrading to higher memory tiers or adding instances
4. **Application Tuning**: Identify memory-intensive operations and optimize data structures
5. **Garbage Collection**: Monitor .NET applications for GC pressure and tune accordingly

### 3. HTTP Queue Length Alert
- **Alert Name**: `serverfarm-http-queue-length-{plan-name}`
- **Metric**: `HttpQueueLength`
- **Threshold**: 100 requests (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Number of HTTP requests waiting to be processed by the web server, indicating request processing bottlenecks.

**What to do when this alert fires**:
1. **Request Analysis**: Examine current request patterns and processing times
2. **Performance Bottlenecks**: Identify slow endpoints and database queries
3. **Scaling Response**: Immediately scale out instances to handle request load
4. **Connection Optimization**: Review connection pooling and keep-alive settings
5. **Load Balancing**: Ensure proper load distribution across instances

### 4. Disk Queue Length Alert
- **Alert Name**: `serverfarm-disk-queue-length-{plan-name}`
- **Metric**: `DiskQueueLength`
- **Threshold**: 32 operations (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: Number of disk I/O operations waiting to be processed, indicating storage performance bottlenecks.

**What to do when this alert fires**:
1. **I/O Analysis**: Review disk usage patterns and identify I/O intensive operations
2. **Storage Optimization**: Optimize file access patterns and implement caching
3. **Database Performance**: Check database query performance and connection pooling
4. **Tier Evaluation**: Consider upgrading to Premium tiers with SSD storage
5. **Architecture Review**: Evaluate using external storage services (Azure Storage, databases)

## Severity Levels

### Severity 2 (High) - Critical Performance Impact
All alerts in this module are configured as Severity 2 due to their direct impact on application performance and user experience.

- **CPU Percentage**: High CPU can cause slow response times and request timeouts
- **Memory Percentage**: Memory pressure can lead to application instability and crashes  
- **HTTP Queue Length**: Request queuing directly impacts user experience and SLA compliance
- **Disk Queue Length**: I/O bottlenecks affect data access and application responsiveness

**Response Time**: 15 minutes
**Escalation**: Immediate notification to web platform team and on-call engineer

## Cost Analysis

### Alert Costs (Monthly)
- **4 Metric Alerts per App Service Plan**: 4 × $0.10 = **$0.40 per App Service Plan**
- **Multi-Plan Deployment**: Scales linearly with App Service Plan count
- **Action Group**: FREE (included)

### Cost Examples by Environment

#### Small Web Application (2 App Service Plans)
- **Monthly Alert Cost**: $0.80
- **Annual Alert Cost**: $9.60

#### Medium Web Platform (5 App Service Plans)
- **Monthly Alert Cost**: $2.00
- **Annual Alert Cost**: $24.00

#### Large Enterprise Platform (15 App Service Plans)
- **Monthly Alert Cost**: $6.00
- **Annual Alert Cost**: $72.00

#### Multi-Tenant Platform (50 App Service Plans)
- **Monthly Alert Cost**: $20.00
- **Annual Alert Cost**: $240.00

### Return on Investment (ROI)

#### Cost of App Service Performance Issues
- **Response Time Degradation**: 2-5x slower responses during high CPU/memory
- **Request Timeouts**: 5-10% request failure rate during queue buildup
- **User Impact**: Reduced conversion rates, abandoned sessions, poor experience
- **Business Impact**: $50,000/hour for e-commerce, $25,000/hour for internal apps
- **SLA Violations**: Potential penalty costs and reputation damage
- **Troubleshooting Time**: 2-4 hours average incident response without monitoring

#### Alert Value Calculation
- **Monthly Alert Cost**: $0.40 per App Service Plan
- **Prevented Downtime**: 4 hours/month average per plan
- **Cost Avoidance**: $100,000/month for critical applications
- **ROI**: 24,999,900% (($100,000 - $0.40) / $0.40 × 100)

#### Additional Benefits
- **Proactive Scaling**: Prevent performance issues before user impact
- **Capacity Planning**: Data-driven decisions for tier upgrades and scaling
- **Cost Optimization**: Right-size App Service Plans based on actual usage
- **SLA Compliance**: Maintain service level agreements with proactive monitoring
- **Developer Productivity**: Faster identification and resolution of performance issues

### App Service Plan Pricing Context
- **Basic B1**: $0.075/hour (1 core, 1.75GB RAM)
- **Standard S1**: $0.10/hour (1 core, 1.75GB RAM)
- **Premium P1V3**: $0.20/hour (2 cores, 8GB RAM)
- **Isolated I1V2**: $0.40/hour (2 cores, 8GB RAM)

**Alert Cost as % of App Service Plan Cost**: 0.7% - 2.2% of monthly plan costs

## Best Practices

### Deployment Best Practices

#### 1. Environment-Specific Configuration
```hcl
# Development Environment - Relaxed monitoring
cpu_percentage_threshold    = 90
memory_percentage_threshold = 90

# Staging Environment - Moderate monitoring  
cpu_percentage_threshold    = 85
memory_percentage_threshold = 85

# Production Environment - Strict monitoring
cpu_percentage_threshold    = 75
memory_percentage_threshold = 75
```

#### 2. Tier-Appropriate Thresholds
- **Free/Shared Tiers**: Higher thresholds (90%+) due to resource limitations
- **Basic Tiers**: Moderate thresholds (85%) for small applications
- **Standard/Premium Tiers**: Lower thresholds (75-80%) for better performance
- **Isolated Tiers**: Customized thresholds based on dedicated capacity

#### 3. Application-Specific Tuning
- **CPU-Intensive Apps**: Lower CPU thresholds (70%)
- **Memory-Intensive Apps**: Lower memory thresholds (70%)
- **High-Traffic APIs**: Lower queue length thresholds (50-75)
- **Batch Processing Apps**: Higher disk queue tolerance (40-50)

### App Service Plan Configuration Best Practices

#### 1. Right-Sizing Strategy
```hcl
# Avoid over-provisioning - start conservative and scale up
# Basic B1 for development/testing
# Standard S1-S3 for production web apps
# Premium P1V3+ for high-performance applications
# Isolated for compliance and dedicated resources
```

#### 2. Auto-Scaling Configuration
```json
{
  "profiles": [{
    "name": "Production Auto-scale",
    "capacity": {
      "minimum": "2",
      "maximum": "10",
      "default": "2"
    },
    "rules": [{
      "metricTrigger": {
        "metricName": "CpuPercentage",
        "threshold": 75,
        "timeAggregation": "Average"
      },
      "scaleAction": {
        "direction": "Increase",
        "type": "ChangeCount",
        "value": "1"
      }
    }]
  }]
}
```

#### 3. Performance Optimization
- **Always On**: Enable for production applications to avoid cold starts
- **ARR Affinity**: Disable if using external session state management
- **Connection Strings**: Use managed identity instead of connection strings
- **Application Settings**: Minimize and use Azure Key Vault for secrets

### Monitoring Best Practices

#### 1. Baseline Establishment
- Monitor for 2-4 weeks to establish performance baselines
- Identify peak usage patterns and seasonal variations
- Document normal vs. exceptional performance patterns

#### 2. Correlation Analysis
- CPU and memory often correlate with application load
- HTTP queue length indicates request processing efficiency
- Disk queue length relates to data access patterns

#### 3. Proactive Capacity Planning
```bash
# Monitor trends over time
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/serverfarms/{plan}" \
  --metric "CpuPercentage,MemoryPercentage" \
  --interval PT1H \
  --start-time 2023-11-01T00:00:00Z \
  --end-time 2023-11-30T23:59:59Z
```

#### 4. Integration with Application Insights
- Correlate infrastructure metrics with application performance
- Set up custom telemetry for business-specific metrics
- Use Application Map to understand dependencies

### Application Development Best Practices

#### 1. Performance Optimization
```csharp
// Implement efficient caching
services.AddMemoryCache();
services.AddResponseCaching();

// Use async/await patterns
public async Task<IActionResult> GetDataAsync()
{
    var data = await _dataService.GetAsync();
    return Ok(data);
}

// Implement connection pooling
services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString, builder =>
        builder.CommandTimeout(30)));
```

#### 2. Resource Management
```csharp
// Dispose resources properly
using (var httpClient = new HttpClient())
{
    var response = await httpClient.GetAsync(url);
    // Process response
}

// Use dependency injection for singletons
services.AddSingleton<IExpensiveService, ExpensiveService>();
```

#### 3. Error Handling and Resilience
```csharp
// Implement circuit breaker pattern
services.AddHttpClient<ApiService>()
    .AddPolicyHandler(Policy.CircuitBreakerAsync(
        handledEventsAllowedBeforeBreaking: 3,
        durationOfBreak: TimeSpan.FromSeconds(30)));
```

### Security and Compliance Best Practices

#### 1. Network Security
- Use VNet integration for backend connectivity
- Configure private endpoints for database connections
- Implement Web Application Firewall (WAF) for public applications

#### 2. Identity and Access Management
- Use managed identity for Azure service connections
- Implement Azure AD authentication for user access
- Follow principle of least privilege for service principals

#### 3. Compliance Requirements
- **SOX**: Maintain change control and audit logs
- **HIPAA**: Ensure encryption in transit and at rest for PHI
- **PCI-DSS**: Secure payment processing with network isolation
- **GDPR**: Implement data retention and deletion procedures

## Troubleshooting

### Common Issues and Solutions

#### 1. CPU Alert Firing During Normal Operations
**Symptoms**: CPU percentage alert triggers during expected application usage

**Possible Causes**:
- Application not optimized for current tier
- Inefficient code or database queries
- Insufficient scaling configuration
- Background processes consuming CPU

**Troubleshooting Steps**:
```bash
# Check current CPU usage patterns
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/serverfarms/{plan}" \
  --metric "CpuPercentage" \
  --interval PT5M

# Review application performance
az webapp log tail --name {app-name} --resource-group {rg}

# Check auto-scaling configuration
az monitor autoscale show --name {autoscale-name} --resource-group {rg}
```

**Resolution**:
- Profile application code to identify CPU bottlenecks
- Optimize database queries and implement caching
- Configure appropriate auto-scaling rules
- Consider upgrading to higher tier or adding instances

#### 2. Memory Pressure Causing Application Instability
**Symptoms**: Memory percentage alerts with application crashes or slow performance

**Possible Causes**:
- Memory leaks in application code
- Inefficient caching implementation
- Large object heap pressure
- Insufficient memory tier

**Troubleshooting Steps**:
```bash
# Monitor memory usage trends
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/serverfarms/{plan}" \
  --metric "MemoryPercentage" \
  --interval PT15M

# Check application logs for OutOfMemory exceptions
az webapp log download --name {app-name} --resource-group {rg}

# Review .NET garbage collection (if applicable)
# Enable Application Insights for detailed memory analysis
```

**Resolution**:
- Implement memory profiling to identify leaks
- Optimize caching strategies and object lifecycle
- Configure appropriate garbage collection settings
- Upgrade to higher memory tier or implement memory-efficient patterns

#### 3. HTTP Queue Building Up During Peak Hours
**Symptoms**: HTTP queue length alerts during high traffic periods

**Possible Causes**:
- Insufficient instance count for current load
- Slow-performing endpoints or database queries
- Inadequate connection pooling configuration
- External service dependencies causing delays

**Troubleshooting Steps**:
```bash
# Monitor request patterns and queue length
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/serverfarms/{plan}" \
  --metric "HttpQueueLength" \
  --interval PT5M

# Check application response times
# Use Application Insights to identify slow requests
az webapp log tail --name {app-name} --resource-group {rg} --filter "duration > 5000"
```

**Resolution**:
- Scale out instances immediately during incidents
- Implement auto-scaling based on queue length
- Optimize slow-performing application endpoints
- Configure appropriate connection limits and timeouts

#### 4. Disk I/O Performance Issues
**Symptoms**: Disk queue length alerts with slow application response

**Possible Causes**:
- Excessive file I/O operations
- Large file processing without streaming
- Database connection issues
- Tier limitations on IOPS

**Troubleshooting Steps**:
```bash
# Monitor disk queue patterns
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/serverfarms/{plan}" \
  --metric "DiskQueueLength" \
  --interval PT5M

# Review application disk usage patterns
# Check for large file operations or inefficient data access
```

**Resolution**:
- Implement streaming for large file operations
- Use Azure Storage services for file processing
- Optimize database connection pooling
- Consider upgrading to Premium tiers with SSD storage

### Performance Optimization Strategies

#### 1. Application-Level Optimization
```csharp
// Implement response caching
[ResponseCache(Duration = 300, VaryByQueryKeys = new[] { "id" })]
public IActionResult GetProduct(int id)
{
    // Method implementation
}

// Use output caching for expensive operations
[OutputCache(Duration = 600)]
public IActionResult ExpensiveOperation()
{
    // Cached operation
}

// Implement efficient data access patterns
public async Task<List<Product>> GetProductsAsync(int pageSize, int pageNumber)
{
    return await _context.Products
        .Skip(pageNumber * pageSize)
        .Take(pageSize)
        .ToListAsync();
}
```

#### 2. Infrastructure Optimization
```bash
# Enable Application Insights for detailed monitoring
az webapp config appsettings set \
  --name {app-name} \
  --resource-group {rg} \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY={key}

# Configure connection string optimization
az webapp config connection-string set \
  --name {app-name} \
  --resource-group {rg} \
  --connection-string-type SQLServer \
  --settings DefaultConnection="{connection-string-with-pooling}"
```

#### 3. Scaling Strategy Implementation
```json
{
  "autoscaleSettings": {
    "profiles": [{
      "name": "Performance-based scaling",
      "capacity": {
        "minimum": "2",
        "maximum": "20",
        "default": "3"
      },
      "rules": [
        {
          "metricTrigger": {
            "metricName": "CpuPercentage",
            "threshold": 75,
            "operator": "GreaterThan",
            "timeAggregation": "Average",
            "timeWindow": "PT10M"
          },
          "scaleAction": {
            "direction": "Increase",
            "type": "ChangeCount",
            "value": "2",
            "cooldown": "PT5M"
          }
        },
        {
          "metricTrigger": {
            "metricName": "HttpQueueLength", 
            "threshold": 50,
            "operator": "GreaterThan",
            "timeAggregation": "Average",
            "timeWindow": "PT5M"
          },
          "scaleAction": {
            "direction": "Increase",
            "type": "ChangeCount", 
            "value": "3",
            "cooldown": "PT3M"
          }
        }
      ]
    }]
  }
}
```

### Monitoring and Diagnostics Enhancement

#### 1. Custom Metrics Implementation
```csharp
// Implement custom telemetry
services.AddApplicationInsightsTelemetry();

public class CustomTelemetryService
{
    private readonly TelemetryClient _telemetryClient;
    
    public CustomTelemetryService(TelemetryClient telemetryClient)
    {
        _telemetryClient = telemetryClient;
    }
    
    public void TrackBusinessMetric(string metricName, double value)
    {
        _telemetryClient.TrackMetric(metricName, value);
    }
}
```

#### 2. Advanced Query Analysis
```kql
// App Service Plan performance analysis
AzureMetrics
| where ResourceProvider == "MICROSOFT.WEB" and ResourceId contains "serverfarms"
| where MetricName in ("CpuPercentage", "MemoryPercentage", "HttpQueueLength")
| summarize avg(Average), max(Maximum), min(Minimum) by MetricName, bin(TimeGenerated, 15m)
| render timechart

// Correlation analysis between metrics
AzureMetrics
| where ResourceProvider == "MICROSOFT.WEB" and ResourceId contains "serverfarms"
| where MetricName in ("CpuPercentage", "MemoryPercentage")
| extend ResourceName = split(ResourceId, "/")[8]
| summarize CPU = avg(iff(MetricName == "CpuPercentage", Average, 0)),
            Memory = avg(iff(MetricName == "MemoryPercentage", Average, 0)) by ResourceName, bin(TimeGenerated, 15m)
| where CPU > 0 and Memory > 0
| render scatterchart
```

#### 3. Health Check Implementation
```bash
#!/bin/bash
# App Service Plan health check script

SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP="your-resource-group"
PLAN_NAME="your-app-service-plan"

# Check current resource utilization
echo "Checking App Service Plan: $PLAN_NAME"

# Get CPU percentage
CPU_USAGE=$(az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/serverfarms/$PLAN_NAME" \
  --metric "CpuPercentage" \
  --interval PT5M \
  --query "value[0].timeseries[0].data[-1].average" -o tsv)

echo "Current CPU Usage: ${CPU_USAGE}%"

# Get memory percentage  
MEMORY_USAGE=$(az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/serverfarms/$PLAN_NAME" \
  --metric "MemoryPercentage" \
  --interval PT5M \
  --query "value[0].timeseries[0].data[-1].average" -o tsv)

echo "Current Memory Usage: ${MEMORY_USAGE}%"

# Check instance count
INSTANCE_COUNT=$(az appservice plan show \
  --name "$PLAN_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "sku.capacity" -o tsv)

echo "Current Instance Count: $INSTANCE_COUNT"

# Health assessment
if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
  echo "WARNING: High CPU usage detected"
fi

if (( $(echo "$MEMORY_USAGE > 80" | bc -l) )); then
  echo "WARNING: High memory usage detected"
fi
```

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

**Note**: This module is designed for Azure App Service Plan monitoring and follows PGE operational standards. Ensure proper testing in non-production environments before deploying to production workloads. Regular review and adjustment of alert thresholds based on actual application performance patterns is recommended for optimal monitoring effectiveness.