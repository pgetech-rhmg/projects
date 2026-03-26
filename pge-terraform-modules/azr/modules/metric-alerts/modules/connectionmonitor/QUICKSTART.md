# Connection Monitor Module - Quick Start

## ✅ Module Successfully Created!

The Connection Monitor module is now ready to use for Azure network connectivity monitoring.

### 📁 Module Location
```
/Alerting/modules/metricAlerts/connectionmonitor/
├── alerts.tf       # 6 connectivity alerts + diagnostic settings
├── variables.tf    # Configuration variables
├── README.md       # Full documentation
└── QUICKSTART.md   # This file
```

### 🎯 What This Module Monitors

**6 Connectivity Alerts:**
1. ✅ Checks Failed Warning (10% threshold, Severity 2)
2. 🔴 Checks Failed Critical (50% threshold, Severity 0)
3. ⚠️ Latency Warning (100ms, Severity 2)
4. 🔴 Latency Critical (500ms, Severity 1)
5. ❌ Test Result Failed (Severity 1)
6. ⚠️ Test Result Warning (Severity 2)

### �� How to Use

**Step 1: Create Connection Monitor (if not already exists)**
```bash
# Connection Monitors are created separately via Azure Portal or CLI
# They monitor connectivity between Azure resources or on-premises
```

**Step 2: Enable Module in main.tf**

Uncomment the connection monitor module section in `main.tf` (already added):
```hcl
module "connection_monitor_metric_alerts" {
  source                           = "./modules/metricAlerts/connectionmonitor"
  resource_group_name              = "rg-amba"
  action_group_resource_group_name = var.action_group_resource_group_name
  connection_monitor_names         = [
    "conn-monitor-webapp-to-sql",
    "conn-monitor-azure-to-onprem",
  ]
  
  depends_on = [module.action_groups]
}
```

**Step 3: Configure Connection Monitor Names**
Replace the example names with your actual Connection Monitor names.

**Step 4: Deploy**
```bash
terraform plan
terraform apply
```

### 📊 Use Cases

- **Azure ↔ On-Premises:** Monitor VPN/ExpressRoute connectivity
- **Multi-Region:** Track latency between Azure regions
- **Application Tiers:** Web → App → Database connectivity
- **External Services:** Azure → SaaS/API connectivity

### 🔧 Configuration Options

Key variables you can customize:
- `checks_failed_threshold` - Default: 10%
- `checks_failed_critical_threshold` - Default: 50%
- `latency_threshold_ms` - Default: 100ms
- `latency_critical_threshold_ms` - Default: 500ms

### ✅ Validation Status

```bash
terraform validate
# Success! The configuration is valid.
```

### 📖 Full Documentation

See `README.md` for:
- Detailed alert descriptions
- Troubleshooting guides
- Complete configuration examples
- Integration with other modules

---
**Created:** January 28, 2026
**Status:** ✅ Ready for Production
