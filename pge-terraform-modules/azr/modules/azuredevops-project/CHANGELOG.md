# Changelog

All notable changes to the `azuredevops-project` module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2026-03-24

### Added
- Per-partner Azure AD security group integration via YAML manifest:
  - `read_write_groups` variable for Azure AD groups granted contributor access
  - `read_only_groups` variable for Azure AD groups granted reader access
  - Automatic Azure AD group synchronization using `azuredevops_group_entitlement` resources
- Global readers group management with lifecycle ignore changes for external group modifications
- Additional built-in group data sources: Contributors, Readers, and Project Valid Users

### Changed
- Project description default value changed from "Deployed via Managed App Infra" to empty string for flexibility
- Updated `readers_group_descriptor` variable description for clarity
- Added `azurerm` and `azuread` provider version requirements for comprehensive Azure integration
- Removed Terraform minimum version requirement to allow broader compatibility

### Enhanced
- Improved security group management with proper Azure AD synchronization
- Better separation of global vs per-partner access control patterns

## [0.1.0] - 2026-03-06

### Added
- Initial release of the Azure DevOps Project module
- Azure DevOps project creation with configurable features:
  - Boards
  - Repositories
  - Pipelines
  - Test Plans
  - Artifacts
- Managed Identity (MI2) integration for OIDC service connections
- Project permissions management:
  - MI2 admin permissions for automated service connection access
  - Azure AD admin group integration with Project Administrators
  - Azure AD readers group integration with Readers built-in group
- Support for project visibility settings (private/public)
- Configurable version control (Git/TFVC)
- Work item template selection (Agile, Scrum, Basic, CMMI)

### Security
- Direct principal-based permissions to avoid conflicts with ADO built-in groups
- Managed Identity (MI2) gets scoped admin access for automation workflows

### Notes
- Group management via Terraform is intentionally limited to avoid conflicts with Azure DevOps built-in groups
- GitHub pipeline configuration is handled separately at the ado-automation level to prevent circular dependencies
- Microsoft-hosted agent pool (Azure Pipelines) is automatically available in new projects

---

## Module Information

| Attribute | Value |
|-----------|-------|
| Module Path | `azr/modules/azuredevops-project` |
| Provider | `microsoft/azuredevops ~> 1.0` |
| Dependencies | `azuread ~> 2.0` |
| Author | PG&E Cloud COE |
