# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-04

### Added
- Initial release of Terraform Cloud (TFC) Workspace module
- Creation of TFC workspace with:
  - Workspace name, description, execution mode, and project association
  - Organization and workspace references for WS3 data sources
- Team access management including:
  - Granting admin or read access to specified teams
  - Creating a temporary team for the requesting user
  - Adding the user to the temporary team
- Variable set integration including:
  - Applying OIDC variable set to workspace (if provided)
  - Attaching optional Azure DevOps secrets variable set (shared PAT/env vars)
- Azure authentication support using:
  - Managed Identity (OIDC) for Terraform Cloud runs
  - Removal of ARM_* variables (replaced by OIDC runtime variables)
  - Automatic use of TFC_AZURE_RUN_* environment variables
- Azure DevOps provider authentication support:
  - Optional PAT injection for WS3 use cases
- Partner configuration variable ingestion:
  - Terraform variables sourced from partner config inputs
- Standardized tagging and metadata injection for workspace-level resources

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- Enforced OIDC-based authentication to eliminate static cloud credentials
- Scoped Azure DevOps PAT usage to WS3-only scenarios
