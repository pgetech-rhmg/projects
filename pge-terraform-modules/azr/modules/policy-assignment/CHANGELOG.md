# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-10

### Added
- Initial release of Azure Policy Assignment module
- Custom `azurerm_policy_definition` to enforce AppID tag on resource groups
- Subscription-scoped policy assignment for custom AppID tag enforcement
- Subscription-scoped policy assignments for configurable required tags (built-in policy `1e30110a-5ceb-460c-a204-c1c3969c6d62`)
- Subscription-scoped policy assignment for allowed Azure regions (built-in policy `e56962a6-4747-49cd-b67b-bf8b01975c4c`)
- Subscription-scoped audit policy for VMs without managed disks (built-in policy `06a78e20-9358-41c9-923c-fb736d382a4d`)
- Subscription-scoped policy for secure transfer enforcement on storage accounts (built-in policy `404c3081-a854-4457-ae30-26a93ef643f9`)
- `enforce` argument wired to all policy assignments via `var.enforcement_mode` (`Default` → `true`, `DoNotEnforce` → `false`)
- `tags` argument applied to all policy assignment resources using `local.module_tags` (workspace-info integration)
- SAF2.0 compliant tagging via `module.ws` workspace-info module merged with caller-supplied `var.tags`
- `terraform` block with `required_version` and `azurerm ~> 4.0` provider constraint
- Input variables for `partner_name`, `subscription_id`, `app_id`, `required_tags`, `enforcement_mode`, and `tags`
- Outputs for policy assignment IDs, display names, and custom policy definition ID
- Complete documentation

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- AppID tag enforcement denies non-compliant resource group deployments by default
- Allowed locations policy restricts deployments to approved US Azure regions
- Secure transfer enforcement policy mandates HTTPS-only access to storage accounts

---

## Semantic Versioning Guidelines

- **MAJOR** (x.0.0): Breaking changes - incompatible API changes
  - Renamed variables/outputs
  - Removed resources
  - Changed required inputs
  - Changed resource behavior significantly

- **MINOR** (0.x.0): New features - backward-compatible additions
  - New optional variables
  - New resources (non-breaking)
  - New outputs
  - Enhanced functionality

- **PATCH** (0.0.x): Bug fixes - backward-compatible fixes
  - Bug fixes
  - Documentation updates
