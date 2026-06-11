# epic-pipeline-module-azure-tags

Standard EPIC tag set for Azure resources. The module assembles a single `tags` map from PG&E governance inputs (AppID, owner, compliance, CRIS, etc.) and exposes it for downstream Azure modules to attach to every resource they create.

## Resources Created

This module creates no Azure resources. It only computes a `tags` map from inputs and returns it via output.

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `subscription_id` | `string` | Azure Subscription ID where the resource is provisioned. |
| `environment` | `string` | Deployment environment. One of: `dev`, `test`, `qa`, `prod`. |
| `appid` | `number` | AMPS Application ID (numeric). Rendered as `APP-<appid>` in the `AppID` tag. |
| `notify` | `list(string)` | Email addresses or DLs to notify on failure or maintenance. Each entry must be a valid email. |
| `owner` | `list(string)` | Exactly three LAN IDs: AMPS Director, Client Owner, IT Lead. |
| `order` | `number` | AMPS Order number. Must be 7 to 9 digits (1,000,000 to 999,999,999). |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `dataclassification` | `string` | `"Internal"` | One of `Public`, `Internal`, `Confidential`, `Restricted`, `Privileged`, `BCSI`, `BCSI-Confidential`, `BCSI-Restricted`. |
| `compliance` | `list(string)` | `["None"]` | Subset of `SOX`, `HIPAA`, `CCPA`, `BCSI`, `None`. |
| `cris` | `string` | `"Low"` | Cyber Risk Impact Score. One of `High`, `Medium`, `Low`. |

## Outputs

| Name | Type | Description |
|------|------|-------------|
| `tags` | `map(string)` | Tag map with keys: `ManagedBy`, `Team`, `SubscriptionID`, `AppID`, `Environment`, `DataClassification`, `CRIS`, `Notify`, `Owner`, `Compliance`, `Order`. List inputs (`notify`, `owner`, `compliance`) are joined with `_`. |

## Usage in a Terraform Project

Standard pattern from a project's `.infra/main.tf`. The tag module is instantiated once and its output is fed into every other Azure module.

```hcl
module "tags" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-tags.git?ref=main"

  subscription_id    = var.subscription_id
  environment        = var.environment
  appid              = var.appid
  compliance         = var.compliance
  cris               = var.cris
  dataclassification = var.dataclassification
  notify             = var.notify
  order              = var.order
  owner              = var.owner
}

module "app_service" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-app-service.git?ref=main"

  app_name    = "${var.app_name}-web"
  environment = var.environment
  tags        = module.tags.tags
  # ...
}
```

The governance inputs (`appid`, `owner`, `notify`, `order`, `compliance`, `cris`, `dataclassification`) are declared as variables in the project's `.infra/variables.tf` and supplied through `terraform.tfvars` or pipeline-injected `-var` flags. EPIC reads `.pipeline/epic.json` to resolve `subscription_id` and `environment` per run.

When a resource needs a `Name` tag in addition to the standard set, merge inline:

```hcl
tags = merge(module.tags.tags, { Name = "pge-epic-${var.app_name}-web-${var.environment}-app-service" })
```

## Usage from Another Module

When a higher-level composite module wraps this one, pass the governance variables through and re-export the resulting tag map so consumers of the composite still see a single `tags` output:

```hcl
module "tags" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-tags.git?ref=main"

  subscription_id    = var.subscription_id
  environment        = var.environment
  appid              = var.appid
  notify             = var.notify
  owner              = var.owner
  order              = var.order
  compliance         = var.compliance
  cris               = var.cris
  dataclassification = var.dataclassification
}

# Attach module.tags.tags to every resource the composite creates,
# then re-export:
output "tags" {
  value = module.tags.tags
}
```

## Requirements

| Component | Version |
|-----------|---------|
| Terraform | `>= 1.5.0` |

No providers are required — this module is pure local computation.

## Notes

- The `Notify`, `Owner`, and `Compliance` tag values are joined with underscores because Azure tag values are single strings. The module does not validate underscore conflicts inside individual entries.
- `appid` is a `number`; pass it as an unquoted integer, not a string. The `APP-` prefix is added by the module.
- `order` is emitted as a string in the tag map (Azure tag values are strings), even though the input type is `number`.
- The module only validates the inputs it owns. Resources still need to wire `tags = module.tags.tags` themselves; this module does not enforce attachment.
