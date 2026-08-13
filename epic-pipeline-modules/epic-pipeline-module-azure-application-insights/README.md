# epic-pipeline-module-azure-application-insights

Provisions a workspace-based Azure Application Insights component.

- Requires a Log Analytics `workspace_id` (classic workspace-less App Insights is
  retired). Pair it with `epic-pipeline-module-azure-log-analytics`.
- Exposes both the legacy instrumentation key and the modern connection string
  as sensitive outputs.

## Usage

```hcl
module "app_insights" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-application-insights.git?ref=main"

  resource_group_name = data.azurerm_resource_group.main.name
  azure_region        = data.azurerm_resource_group.main.location
  name                = "myapp-appinsights"
  workspace_id        = module.log_analytics.workspace_id

  tags = module.tags.tags
}
```

Wire `connection_string` into `APPLICATIONINSIGHTS_CONNECTION_STRING` (preferred)
and/or `instrumentation_key` into `APPINSIGHTS_INSTRUMENTATIONKEY`.
