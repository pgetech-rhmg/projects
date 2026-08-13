# epic-pipeline-module-azure-service-bus

Provisions an Azure Service Bus namespace and its queues.

- Namespace SKU defaults to `Basic` (queues only; no topics/sessions).
- Each queue supports dead-lettering, delivery-count, lock-duration, and TTL —
  the settings needed for a retry-with-DLQ worker pattern.
- Exposes the namespace's default `RootManageSharedAccessKey` connection string
  as a sensitive output (wire it into Key Vault, not into app config directly).

## Usage

```hcl
module "service_bus" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-service-bus.git?ref=main"

  resource_group_name = data.azurerm_resource_group.main.name
  azure_region        = data.azurerm_resource_group.main.location
  namespace_name      = "myapp-servicebus"
  sku                 = "Basic"

  queues = [
    {
      name                                 = "provisioning-tasks"
      max_delivery_count                   = 5
      lock_duration                        = "PT1M"
      default_message_ttl                  = "P1D"
      dead_lettering_on_message_expiration = true
    },
  ]

  tags = module.tags.tags
}
```

## Notes

- `requires_session` and duplicate detection are **not** available on the Basic
  SKU — leave them off unless the namespace is Standard/Premium.
- `capacity` applies only to Premium; keep it `0` for Basic/Standard.
- Durations are ISO-8601: `PT1M` = 60 seconds, `P1D` = 1 day, `P14D` = 14 days.
