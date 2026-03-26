# Azure App Service Sites (Web Apps) - Metric Alerts Module

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

This Terraform module creates comprehensive monitoring alerts for **Azure App Service Sites** (Web Apps), providing proactive monitoring for web applications, APIs, and mobile app backends. The module monitors critical application-level metrics to ensure optimal user experience, performance, and availability.

Azure App Service Sites represent individual web applications running within App Service Plans. They host application code, handle HTTP requests, and serve content to users. This module focuses on application-specific metrics rather than infrastructure metrics, complementing the Server Farms monitoring module.

## Features

- **Dual Platform Support**: Monitors both Windows and Linux App Service sites with unified configuration
- **Performance Monitoring**: Response time tracking with warning and critical thresholds
- **Error Detection**: HTTP 4xx and 5xx error monitoring with different severity levels
- **Availability Tracking**: Health check status monitoring for service availability
- **Request Volume Monitoring**: Request rate tracking for capacity planning and anomaly detection
- **Resource Utilization**: CPU time and I/O operations monitoring for performance optimization
- **Real-Time Alerting**: 1-5 minute evaluation frequency for critical application metrics
- **Per-Application Monitoring**: Individual alerts for each web application
- **Cost-Effective Alerting**: Metric alerts at $0.10 per month per alert rule
- **Enterprise Integration**: Built-in support for PGE operational procedures
- **Compliance Ready**: SOX, HIPAA, PCI-DSS, and regulatory compliance support

### Key Monitoring Capabilities
- **User Experience**: Response time monitoring to ensure optimal user experience
- **Error Classification**: Separate monitoring for client errors (4xx) vs. server errors (5xx)
- **Availability Assurance**: Health check monitoring for service uptime
- **Performance Bottlenecks**: CPU and I/O monitoring for resource optimization
- **Traffic Analysis**: Request volume monitoring for scaling and capacity decisions
- **Application Health**: Comprehensive view of application performance and reliability

## Prerequisites

- **Terraform**: Version >= 1.0
- **Azure Provider**: Version >= 3.0
- **Azure Permissions**: 
  - `Microsoft.Insights/metricAlerts/write`
  - `Microsoft.Insights/actionGroups/read`
  - `Microsoft.Web/sites/read`
- **Action Group**: Pre-configured action group for alert notifications
- **App Service Sites**: Existing Azure App Service web applications to monitor

## Usage

### Basic Configuration

```hcl
module "sites_alerts" {
  source = "./modules/metricAlerts/sites"
  
  # Resource Configuration
  resource_group_name               = "rg-production-web"
  action_group_resource_group_name  = "rg-monitoring"
  action_group                      = "pge-operations-actiongroup"
  
  # Web Applications to Monitor
  windows_site_names = [
    "webapp-prod-frontend-001",
    "webapp-prod-api-001"
  ]
  
  linux_site_names = [
    "webapp-prod-backend-001",
    "webapp-prod-mobile-api-001"
  ]
  
  # Environment Tags
  tags = {
    Environment        = "Production"
    Application        = "WebApplications"
    Owner             = "web-development@pge.com"
    CostCenter        = "IT-Development"
    Compliance        = "SOX"
    DataClassification = "Internal"
  }
}
```

### Advanced Configuration with Custom Thresholds

```hcl
module "sites_alerts_high_performance" {
  source = "./modules/metricAlerts/sites"
  
  # Resource Configuration
  resource_group_name               = "rg-production-web"
  action_group_resource_group_name  = "rg-monitoring"
  windows_site_names               = ["webapp-prod-critical"]
  
  # High-Performance Thresholds
  availability_threshold           = 99.9    # Stricter availability requirements
  response_time_threshold          = 2       # Lower response time tolerance
  response_time_critical_threshold = 5       # Aggressive critical threshold
  
  # Error Monitoring (Zero-Tolerance Environment)
  http_4xx_threshold              = 5        # Lower client error tolerance
  http_5xx_threshold              = 1        # Immediate server error alerting
  
  # Traffic and Performance
  request_rate_threshold          = 5000     # Higher traffic capacity
  cpu_time_threshold             = 30       # Lower CPU time tolerance
  
  tags = {
    Environment = "Production"
    Tier        = "Critical"
    SLA         = "99.9%"
    Owner       = "platform-reliability@pge.com"
  }
}
```

### Environment-Specific Configurations

#### Development Environment
```hcl
# Development Web Apps - Relaxed Thresholds
availability_threshold           = 95       # More tolerance for outages
response_time_threshold          = 10       # Higher response time tolerance
response_time_critical_threshold = 30       # Very high critical threshold
http_4xx_threshold              = 50       # Higher error tolerance for testing
http_5xx_threshold              = 20       # More server error tolerance
request_rate_threshold          = 100      # Lower traffic expectations
```

#### Staging Environment
```hcl
# Staging Web Apps - Moderate Thresholds
availability_threshold           = 98       # Production-like availability
response_time_threshold          = 7        # Moderate response time
response_time_critical_threshold = 15       # Reasonable critical threshold
http_4xx_threshold              = 20       # Moderate error tolerance
http_5xx_threshold              = 10       # Some server error tolerance
request_rate_threshold          = 500      # Medium traffic capacity
```

#### Production Environment
```hcl
# Production Web Apps - Strict Thresholds
availability_threshold           = 99       # High availability requirement
response_time_threshold          = 5        # Fast response time
response_time_critical_threshold = 10       # Quick critical response
http_4xx_threshold              = 10       # Low client error tolerance
http_5xx_threshold              = 5        # Very low server error tolerance
request_rate_threshold          = 1000     # High traffic capacity
```

### Application Type-Specific Configurations

#### Public-Facing Websites
```hcl
# Public websites - User experience focused
availability_threshold           = 99.5     # High availability for users
response_time_threshold          = 3        # Fast user experience
response_time_critical_threshold = 8        # User patience threshold
http_4xx_threshold              = 15       # Some client errors acceptable
http_5xx_threshold              = 3        # Low server error tolerance
```

#### Internal APIs
```hcl
# Internal APIs - System integration focused
availability_threshold           = 99       # High availability for systems
response_time_threshold          = 5        # API response requirements
response_time_critical_threshold = 15       # System timeout thresholds
http_4xx_threshold              = 10       # Authentication/authorization errors
http_5xx_threshold              = 2        # Critical for system reliability
```

#### E-commerce Applications
```hcl
# E-commerce - Business critical
availability_threshold           = 99.9     # Revenue protection
response_time_threshold          = 2        # Fast checkout experience
response_time_critical_threshold = 5        # Conversion rate protection
http_4xx_threshold              = 5        # Low error tolerance
http_5xx_threshold              = 1        # Immediate server error response
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `action_group_resource_group_name` | `string` | Resource group containing the action group |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | `string` | `"rg-amba"` | Resource group for App Service sites |
| `action_group` | `string` | `"pge-operations-actiongroup"` | Action group for notifications |
| `location` | `string` | `"West US 3"` | Azure region for resources |
| `windows_site_names` | `list(string)` | `[]` | List of Windows App Service site names |
| `linux_site_names` | `list(string)` | `[]` | List of Linux App Service site names |

### Alert Thresholds

| Variable | Type | Default | Description | Recommended Range |
|----------|------|---------|-------------|-------------------|
| `availability_threshold` | `number` | `99` | Availability percentage | 95-99.9% |
| `response_time_threshold` | `number` | `5` | Response time in seconds | 1-10 seconds |
| `response_time_critical_threshold` | `number` | `10` | Critical response time in seconds | 5-30 seconds |
| `http_4xx_threshold` | `number` | `10` | HTTP 4xx errors per minute | 5-100 |
| `http_5xx_threshold` | `number` | `5` | HTTP 5xx errors per minute | 1-50 |
| `request_rate_threshold` | `number` | `1000` | Requests per minute | 100-10K |
| `cpu_time_threshold` | `number` | `60` | CPU time in seconds | 30-300 |

### Tags Configuration

```hcl
tags = {
  AppId              = "123456"                      # Application identifier
  Env                = "Production"                  # Environment designation
  Owner              = "web-development@pge.com"    # Team responsible
  Compliance         = "SOX"                         # Compliance requirement
  Notify             = "webapp-oncall@pge.com"      # Notification contact
  DataClassification = "Internal"                    # Data sensitivity
  CostCenter         = "IT-Development"              # Billing allocation
  CRIS               = "CRIS-12345"                 # Change request ID
  SLA                = "99%"                        # Service level agreement
}
```

## Alert Details

### 1. Response Time Alert (Warning)
- **Alert Name**: `site-response-time-{site-name}`
- **Metric**: `AverageResponseTime`
- **Threshold**: 5 seconds (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT1M (1 minute)
- **Window**: PT5M (5 minutes)
- **Aggregation**: Average

**What this alert monitors**: Average response time for HTTP requests to the web application, indicating performance from the user's perspective.

**What to do when this alert fires**:
1. **Performance Analysis**: Check application performance metrics and identify slow endpoints
2. **Resource Review**: Verify App Service Plan resources (CPU, memory) are adequate
3. **Database Performance**: Review database query performance and connection pooling
4. **External Dependencies**: Check external service calls and API response times
5. **Scaling Assessment**: Consider vertical or horizontal scaling if resource-constrained

### 2. Response Time Alert (Critical)
- **Alert Name**: `site-response-time-critical-{site-name}`
- **Metric**: `AverageResponseTime`
- **Threshold**: 10 seconds (configurable)
- **Severity**: 0 (Critical)
- **Frequency**: PT1M (1 minute)
- **Window**: PT5M (5 minutes)
- **Aggregation**: Average

**What this alert monitors**: Critical response time threshold indicating severe performance degradation affecting user experience.

**What to do when this alert fires**:
1. **Immediate Response**: Investigate application and infrastructure health immediately
2. **Scaling Action**: Scale up App Service Plan or scale out instances immediately
3. **Performance Profiling**: Use Application Insights to identify performance bottlenecks
4. **Health Check**: Verify application health and all critical dependencies
5. **Incident Management**: Activate incident response procedures and stakeholder communication

### 3. HTTP 4xx Error Alert
- **Alert Name**: `site-http-4xx-{site-name}`
- **Metric**: `Http4xx`
- **Threshold**: 10 errors/minute (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Total

**What this alert monitors**: Client-side HTTP errors (400-499) including authentication failures, not found errors, and bad requests.

**What to do when this alert fires**:
1. **Error Analysis**: Review application logs to identify specific 4xx error patterns
2. **Client Investigation**: Check if errors are from legitimate users or potential attacks
3. **Authentication Review**: Verify authentication and authorization configurations
4. **API Documentation**: Ensure API documentation matches actual endpoints and requirements
5. **Security Assessment**: Investigate for potential security scanning or brute force attacks

### 4. HTTP 5xx Error Alert
- **Alert Name**: `site-http-5xx-{site-name}`
- **Metric**: `Http5xx`
- **Threshold**: 5 errors/minute (configurable)
- **Severity**: 1 (Critical)
- **Frequency**: PT1M (1 minute)
- **Window**: PT5M (5 minutes)
- **Aggregation**: Total

**What this alert monitors**: Server-side HTTP errors (500-599) indicating application or infrastructure failures.

**What to do when this alert fires**:
1. **Immediate Investigation**: Check application health and error logs immediately
2. **Dependency Check**: Verify database connectivity and external service availability
3. **Resource Analysis**: Check CPU, memory, and storage resources on App Service Plan
4. **Code Review**: Identify recent deployments that may have introduced issues
5. **Rollback Consideration**: Consider rolling back recent changes if errors correlate with deployments

### 5. Request Rate Alert
- **Alert Name**: `site-request-rate-{site-name}`
- **Metric**: `Requests`
- **Threshold**: 1,000 requests/minute (configurable)
- **Severity**: 3 (Medium)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Total

**What this alert monitors**: High volume of incoming HTTP requests, indicating increased traffic or potential traffic spikes.

**What to do when this alert fires**:
1. **Traffic Analysis**: Determine if traffic increase is legitimate or anomalous
2. **Performance Monitoring**: Monitor response times and error rates during high traffic
3. **Scaling Preparation**: Prepare for auto-scaling or manual scaling if needed
4. **Capacity Planning**: Evaluate current capacity against traffic patterns
5. **DDoS Assessment**: Investigate potential DDoS attacks if traffic is suspicious

### 6. CPU Time Alert
- **Alert Name**: `site-cpu-time-{site-name}`
- **Metric**: `CpuTime`
- **Threshold**: 60 seconds (configurable)
- **Severity**: 2 (High)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Total

**What this alert monitors**: Total CPU time consumed by the application, indicating processing intensity and resource utilization.

**What to do when this alert fires**:
1. **CPU Analysis**: Identify CPU-intensive operations and processes within the application
2. **Code Optimization**: Review and optimize algorithms, loops, and computational logic
3. **Caching Implementation**: Implement caching to reduce CPU-intensive operations
4. **Resource Scaling**: Consider upgrading to higher CPU tiers or scaling out instances
5. **Performance Profiling**: Use profiling tools to identify CPU hotspots in application code

### 7. Availability Alert
- **Alert Name**: `site-availability-{site-name}`
- **Metric**: `HealthCheckStatus`
- **Threshold**: 99% (configurable)
- **Severity**: 1 (Critical)
- **Frequency**: PT1M (1 minute)
- **Window**: PT5M (5 minutes)
- **Aggregation**: Average

**What this alert monitors**: Application availability based on health check results, indicating service uptime and accessibility.

**What to do when this alert fires**:
1. **Service Health**: Immediately check if the application is accessible and responsive
2. **Health Check Configuration**: Verify health check endpoints are properly configured
3. **Infrastructure Status**: Check App Service Plan and underlying infrastructure health
4. **Dependency Verification**: Ensure all critical dependencies (databases, APIs) are available
5. **Failover Procedures**: Activate disaster recovery procedures if necessary

### 8. IO Read Operations Alert
- **Alert Name**: `site-io-read-ops-{site-name}`
- **Metric**: `IoReadOperationsPerSecond`
- **Threshold**: 100 operations/second (fixed)
- **Severity**: 3 (Medium)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: High rate of disk read operations, indicating intensive file access or potential I/O bottlenecks.

**What to do when this alert fires**:
1. **I/O Pattern Analysis**: Identify applications or processes causing high read operations
2. **File Access Optimization**: Optimize file access patterns and implement caching
3. **Storage Performance**: Consider using faster storage tiers or external storage services
4. **Application Review**: Review application logic for unnecessary file system operations
5. **Caching Strategy**: Implement file caching and optimize data access patterns

### 9. IO Write Operations Alert
- **Alert Name**: `site-io-write-ops-{site-name}`
- **Metric**: `IoWriteOperationsPerSecond`
- **Threshold**: 100 operations/second (fixed)
- **Severity**: 3 (Medium)
- **Frequency**: PT5M (5 minutes)
- **Window**: PT15M (15 minutes)
- **Aggregation**: Average

**What this alert monitors**: High rate of disk write operations, indicating intensive logging, file creation, or data persistence operations.

**What to do when this alert fires**:
1. **Write Operation Analysis**: Identify sources of high write activity (logging, file uploads, etc.)
2. **Logging Optimization**: Optimize application logging levels and output destinations
3. **Data Storage Strategy**: Consider external storage services for large data operations
4. **Batch Processing**: Implement batching for multiple write operations
5. **Storage Scaling**: Evaluate storage tier upgrades or external storage solutions

## Severity Levels

### Severity 0 (Critical) - Immediate Action Required
- **Response Time Critical**: Severe performance degradation affecting all users

**Response Time**: Immediate (< 5 minutes)
**Escalation**: Page on-call engineer, activate incident response

### Severity 1 (Critical) - Service Impact
- **HTTP 5xx Errors**: Server errors indicating application or infrastructure failure
- **Availability**: Service unavailability or health check failures

**Response Time**: 5 minutes
**Escalation**: Immediate notification to on-call engineer and development team

### Severity 2 (High) - Performance Impact
- **Response Time Warning**: Performance degradation affecting user experience
- **HTTP 4xx Errors**: Client errors potentially indicating authentication or API issues
- **CPU Time**: High resource utilization affecting performance

**Response Time**: 15 minutes
**Escalation**: Notification to development team and on-call engineer

### Severity 3 (Medium) - Monitoring and Capacity
- **Request Rate**: Traffic volume monitoring for capacity planning
- **IO Operations**: Resource utilization monitoring for optimization

**Response Time**: 30 minutes
**Escalation**: Standard operational notification

## Cost Analysis

### Alert Costs (Monthly)
- **9 Metric Alerts per Web App**: 9 × $0.10 = **$0.90 per web application**
- **Multi-Application Deployment**: Scales linearly with web application count
- **Action Group**: FREE (included)

### Cost Examples by Environment

#### Small Web Application Portfolio (5 Web Apps)
- **Monthly Alert Cost**: $4.50
- **Annual Alert Cost**: $54.00

#### Medium Enterprise Web Platform (20 Web Apps)
- **Monthly Alert Cost**: $18.00
- **Annual Alert Cost**: $216.00

#### Large Multi-Tenant Platform (100 Web Apps)
- **Monthly Alert Cost**: $90.00
- **Annual Alert Cost**: $1,080.00

#### Enterprise Application Suite (500 Web Apps)
- **Monthly Alert Cost**: $450.00
- **Annual Alert Cost**: $5,400.00

### Return on Investment (ROI)

#### Cost of Web Application Issues
- **User Experience Impact**: 2-5 second delays reduce conversion by 20-50%
- **E-commerce Revenue**: $10,000-100,000/hour lost revenue during outages
- **Customer Support**: 3x increase in support tickets during performance issues
- **Brand Reputation**: Long-term customer loss due to poor experience
- **SLA Violations**: Penalty costs and contract implications
- **Development Time**: 4-8 hours average incident response without monitoring

#### Alert Value Calculation
- **Monthly Alert Cost**: $0.90 per web application
- **Prevented Revenue Loss**: $50,000/month for typical e-commerce application
- **Cost Avoidance**: $50,000/month per application
- **ROI**: 5,555,456% (($50,000 - $0.90) / $0.90 × 100)

#### Additional Benefits
- **User Experience Protection**: Maintain optimal performance for user satisfaction
- **Proactive Issue Resolution**: Identify and resolve issues before user impact
- **Performance Optimization**: Data-driven decisions for application improvements
- **Capacity Planning**: Right-size resources based on actual usage patterns
- **Competitive Advantage**: Maintain performance edge over competitors

### App Service Pricing Context
- **Free Tier**: $0/month (limited features)
- **Basic B1**: $0.075/hour ($54.75/month)
- **Standard S1**: $0.10/hour ($73/month)
- **Premium P1V3**: $0.20/hour ($146/month)

**Alert Cost as % of App Service Cost**: 1.6% - 2.4% of monthly hosting costs

## Best Practices

### Deployment Best Practices

#### 1. Environment-Specific Configuration
```hcl
# Production Environment - Strict monitoring
availability_threshold    = 99
response_time_threshold   = 3
http_5xx_threshold       = 2

# Staging Environment - Moderate monitoring  
availability_threshold    = 98
response_time_threshold   = 7
http_5xx_threshold       = 10

# Development Environment - Relaxed monitoring
availability_threshold    = 95
response_time_threshold   = 15
http_5xx_threshold       = 50
```

#### 2. Application Type-Specific Thresholds
- **Public Websites**: Lower response time thresholds (2-3 seconds)
- **Internal APIs**: Moderate thresholds (5-7 seconds)
- **Batch Processing**: Higher thresholds (10-15 seconds)
- **E-commerce**: Strictest thresholds (1-2 seconds)

#### 3. Multi-Region Deployment
- Configure region-specific action groups
- Adjust thresholds for cross-region latency
- Implement geo-failover monitoring

### Application Development Best Practices

#### 1. Performance Optimization
```csharp
// Implement response caching
services.AddResponseCaching();
services.AddMemoryCache();

[ResponseCache(Duration = 300)]
public IActionResult GetProducts()
{
    // Cached endpoint implementation
    return Ok(products);
}

// Use async patterns
public async Task<IActionResult> GetDataAsync()
{
    var data = await _dataService.GetAsync();
    return Ok(data);
}

// Implement compression
services.AddResponseCompression(options =>
{
    options.Providers.Add<GzipCompressionProvider>();
    options.EnableForHttps = true;
});
```

#### 2. Error Handling and Monitoring
```csharp
// Implement global error handling
public class GlobalExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionMiddleware> _logger;
    
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception occurred");
            await HandleExceptionAsync(context, ex);
        }
    }
    
    private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.StatusCode = 500;
        context.Response.ContentType = "application/json";
        
        var response = new { error = "An error occurred", details = exception.Message };
        await context.Response.WriteAsync(JsonSerializer.Serialize(response));
    }
}

// Implement health checks
services.AddHealthChecks()
    .AddDbContext<ApplicationDbContext>()
    .AddUrlGroup(new Uri("https://api.dependency.com/health"), "external-api");

app.MapHealthChecks("/health");
```

#### 3. Application Insights Integration
```csharp
// Configure Application Insights
services.AddApplicationInsightsTelemetry();

// Custom telemetry tracking
public class TelemetryService
{
    private readonly TelemetryClient _telemetryClient;
    
    public void TrackCustomEvent(string eventName, Dictionary<string, string> properties)
    {
        _telemetryClient.TrackEvent(eventName, properties);
    }
    
    public void TrackPerformanceMetric(string metricName, double value)
    {
        _telemetryClient.TrackMetric(metricName, value);
    }
}

// Track business metrics
public class OrderController : ControllerBase
{
    public async Task<IActionResult> CreateOrder(Order order)
    {
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            var result = await _orderService.CreateAsync(order);
            
            _telemetryService.TrackCustomEvent("OrderCreated", new Dictionary<string, string>
            {
                ["OrderId"] = result.Id.ToString(),
                ["UserId"] = User.Identity.Name,
                ["Amount"] = order.Amount.ToString()
            });
            
            return Ok(result);
        }
        finally
        {
            stopwatch.Stop();
            _telemetryService.TrackPerformanceMetric("OrderCreation.Duration", 
                stopwatch.ElapsedMilliseconds);
        }
    }
}
```

### Monitoring Best Practices

#### 1. Baseline Establishment
- Monitor applications for 2-4 weeks to establish performance baselines
- Identify traffic patterns, peak usage times, and seasonal variations
- Document normal vs. exceptional performance characteristics

#### 2. Synthetic Monitoring Integration
```bash
# Create availability test in Application Insights
az monitor app-insights web-test create \
  --resource-group "rg-monitoring" \
  --application-insights "app-insights-prod" \
  --name "webapp-availability-test" \
  --location "West US 2" \
  --test-locations "us-west-2" \
  --frequency 300 \
  --timeout 30 \
  --url "https://webapp-prod.azurewebsites.net/health"
```

#### 3. Custom Dashboards
```json
{
  "dashboard": {
    "title": "Web Application Performance Dashboard",
    "panels": [
      {
        "title": "Response Time",
        "query": "AzureMetrics | where MetricName == 'AverageResponseTime' | render timechart"
      },
      {
        "title": "Error Rate",
        "query": "AzureMetrics | where MetricName in ('Http4xx', 'Http5xx') | render timechart"
      },
      {
        "title": "Request Volume", 
        "query": "AzureMetrics | where MetricName == 'Requests' | render timechart"
      }
    ]
  }
}
```

### Security and Compliance Best Practices

#### 1. Secure Configuration
```csharp
// Implement security headers
services.AddHsts(options =>
{
    options.Preload = true;
    options.IncludeSubDomains = true;
    options.MaxAge = TimeSpan.FromDays(365);
});

// Configure authentication
services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = "https://your-authority.com";
        options.RequireHttpsMetadata = true;
    });

// Input validation
[ApiController]
public class ProductsController : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> CreateProduct([FromBody] CreateProductRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }
        
        // Business logic
        return Ok();
    }
}
```

#### 2. Compliance Implementation
- **SOX**: Maintain change control and audit logs for application deployments
- **HIPAA**: Implement encryption and access controls for PHI handling
- **PCI-DSS**: Secure payment processing with proper data handling
- **GDPR**: Implement data retention and privacy controls

### Auto-Scaling Integration

#### 1. Performance-Based Scaling
```json
{
  "autoscaleProfile": {
    "name": "Performance-based scaling",
    "capacity": {
      "minimum": "2",
      "maximum": "20",
      "default": "3"
    },
    "rules": [
      {
        "metricTrigger": {
          "metricName": "AverageResponseTime",
          "threshold": 3.0,
          "operator": "GreaterThan",
          "timeAggregation": "Average",
          "timeWindow": "PT5M"
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
          "metricName": "Http5xx",
          "threshold": 5,
          "operator": "GreaterThan",
          "timeAggregation": "Total",
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
  }
}
```

## Troubleshooting

### Common Issues and Solutions

#### 1. High Response Time Alerts
**Symptoms**: Response time alerts firing during normal application usage

**Possible Causes**:
- Insufficient App Service Plan resources
- Database performance issues or connection pool exhaustion
- External service dependencies causing delays
- Inefficient application code or memory leaks

**Troubleshooting Steps**:
```bash
# Check current response time trends
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/sites/{app-name}" \
  --metric "AverageResponseTime" \
  --interval PT5M

# Monitor App Service Plan metrics
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/serverfarms/{plan-name}" \
  --metric "CpuPercentage,MemoryPercentage" \
  --interval PT5M

# Check application logs
az webapp log tail --name {app-name} --resource-group {rg}
```

**Resolution**:
- Use Application Insights to identify slow dependencies and operations
- Optimize database queries and implement connection pooling
- Scale up App Service Plan or scale out instances
- Implement caching strategies to reduce backend load
- Profile application code for performance bottlenecks

#### 2. High HTTP 5xx Error Rate
**Symptoms**: Server error alerts with application failures

**Possible Causes**:
- Application bugs or unhandled exceptions
- Database connectivity issues
- Resource exhaustion (CPU, memory, connections)
- Recent deployment introducing issues

**Troubleshooting Steps**:
```bash
# Monitor error trends and patterns
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/sites/{app-name}" \
  --metric "Http5xx" \
  --interval PT1M

# Check application health
az webapp show --name {app-name} --resource-group {rg} --query "state"

# Review recent deployments
az webapp deployment list --name {app-name} --resource-group {rg}
```

**Resolution**:
- Review application error logs for specific error patterns
- Check database connectivity and query performance
- Verify resource utilization on App Service Plan
- Consider rolling back recent deployments if errors correlate
- Implement better error handling and logging in application code

#### 3. Availability Issues
**Symptoms**: Health check failures and availability alerts

**Possible Causes**:
- Application startup issues or crashes
- Health check endpoint configuration problems
- Dependency service unavailability
- Resource constraints preventing proper operation

**Troubleshooting Steps**:
```bash
# Check application status and health
az webapp show --name {app-name} --resource-group {rg} --query "state,availabilityState"

# Test health check endpoint directly
curl -I https://{app-name}.azurewebsites.net/health

# Check dependency services
# Verify database connectivity, external APIs, etc.
```

**Resolution**:
- Verify health check endpoint is properly implemented and accessible
- Check application startup logs for initialization issues
- Ensure all dependencies are available and responsive
- Review resource constraints and scale if necessary
- Implement proper health check logic that validates critical dependencies

#### 4. High Request Rate Without Performance Impact
**Symptoms**: Request rate alerts during legitimate traffic spikes

**Possible Causes**:
- Successful marketing campaigns or viral content
- Legitimate business growth in user traffic
- Seasonal traffic patterns
- Bot traffic or web scraping activity

**Troubleshooting Steps**:
```bash
# Analyze request patterns and sources
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/sites/{app-name}" \
  --metric "Requests,AverageResponseTime,Http4xx,Http5xx" \
  --interval PT5M

# Check performance during high traffic
# Review user agent patterns in logs
# Analyze geographic distribution of requests
```

**Resolution**:
- Adjust request rate thresholds based on legitimate traffic patterns
- Implement auto-scaling to handle legitimate traffic growth
- Configure CDN and caching to reduce backend load
- Implement rate limiting for suspicious traffic patterns
- Monitor performance metrics during high traffic to ensure system health

### Performance Optimization Strategies

#### 1. Application-Level Optimization
```csharp
// Implement output caching
[OutputCache(Duration = 600, VaryByParam = "category")]
public IActionResult GetProducts(string category)
{
    // Cached controller action
    var products = _productService.GetByCategory(category);
    return View(products);
}

// Use connection pooling
services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString, builder =>
        builder.CommandTimeout(30)
               .EnableRetryOnFailure()));

// Implement background services
services.AddHostedService<BackgroundTaskService>();

public class BackgroundTaskService : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            // Perform background processing
            await ProcessQueuedItems();
            await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
        }
    }
}
```

#### 2. Infrastructure Optimization
```bash
# Enable Application Insights
az webapp config appsettings set \
  --name {app-name} \
  --resource-group {rg} \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY={key}

# Configure always on for production
az webapp config set \
  --name {app-name} \
  --resource-group {rg} \
  --always-on true

# Enable HTTP/2
az webapp config set \
  --name {app-name} \
  --resource-group {rg} \
  --http20-enabled true
```

#### 3. Advanced Monitoring Setup
```csharp
// Implement custom performance counters
public class CustomPerformanceMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IMetrics _metrics;
    
    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();
            
            _metrics.Measure.Timer.Time("http_request_duration", stopwatch.Elapsed, 
                new MetricTags("endpoint", context.Request.Path));
            
            _metrics.Measure.Counter.Increment("http_requests_total", 
                new MetricTags("status_code", context.Response.StatusCode.ToString()));
        }
    }
}
```

### Health Check Implementation

```bash
#!/bin/bash
# Web application health check script

SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP="your-resource-group"
APP_NAME="your-web-app"

echo "Checking Web Application: $APP_NAME"

# Check application state
APP_STATE=$(az webapp show \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "state" -o tsv)

echo "Application State: $APP_STATE"

# Test health endpoint
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://$APP_NAME.azurewebsites.net/health")
echo "Health Check Status: $HEALTH_STATUS"

# Check recent error rates
ERROR_5XX=$(az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$APP_NAME" \
  --metric "Http5xx" \
  --interval PT5M \
  --query "value[0].timeseries[0].data[-1].total" -o tsv)

echo "Recent 5xx Errors: ${ERROR_5XX:-0}"

# Check response time
RESPONSE_TIME=$(az monitor metrics list \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$APP_NAME" \
  --metric "AverageResponseTime" \
  --interval PT5M \
  --query "value[0].timeseries[0].data[-1].average" -o tsv)

echo "Average Response Time: ${RESPONSE_TIME:-N/A} seconds"

# Health assessment
if [ "$APP_STATE" != "Running" ]; then
  echo "CRITICAL: Application is not running"
  exit 2
fi

if [ "$HEALTH_STATUS" -ne 200 ]; then
  echo "WARNING: Health check endpoint returned $HEALTH_STATUS"
fi

if [ "$ERROR_5XX" != "null" ] && (( $(echo "$ERROR_5XX > 0" | bc -l) )); then
  echo "WARNING: Server errors detected in last 5 minutes"
fi

if [ "$RESPONSE_TIME" != "null" ] && (( $(echo "$RESPONSE_TIME > 10" | bc -l) )); then
  echo "WARNING: High response time detected"
fi

echo "Health check completed"
```

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

**Note**: This module is designed for Azure App Service Sites (Web Apps) monitoring and follows PGE operational standards. Ensure proper testing in non-production environments before deploying to production workloads. Regular review and adjustment of alert thresholds based on actual application performance patterns and user expectations is recommended for optimal monitoring effectiveness.