# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-08

### Added
- Initial release of the App Service module migrated from child-workspaces
- Root module for deploying Azure Linux App Service with multi-runtime support:
  - .NET (6.0, 7.0, 8.0, 9.0)
  - Python (3.8, 3.9, 3.10, 3.11, 3.12)
  - Node.js (16-lts, 18-lts, 20-lts)
  - Java (8, 11, 17, 21 with Tomcat 10.0)
- Support for both System Assigned and User Assigned Managed Identities
- Configurable app settings and connection strings
- Application Insights integration
- VNet integration support with image pull from private registries
- Lifecycle management with ignore_changes for production stability
- Health check configuration with eviction time
- HTTPS-only enforcement
- PGE FinOps tagging integration using workspace-info module
- Automatic tagging with pge_team, tfc_wsname, tfc_wsid

### Features
- Terraform >= 1.1.0 compatibility for TFC Cloud
- Azure Resource Manager provider ~> 4.0
- Dynamic identity blocks supporting system and user-assigned identities
- Dynamic connection strings for database configurations
- Site configuration with health check path and runtime settings
- Proper module structure with separated variables, outputs, and main files

### Documentation
- Comprehensive README with usage examples
- Terraform-docs generated documentation

### Testing
- Module validated with terraform fmt, init, and validate

### Migration Notes
- Migrated from azure-lz-mgd-app-infra/terraform/child-workspaces/modules/app-service
- Enhanced with PGE FinOps tagging via workspace-info module v0.1.0
- Follows standard Terraform module structure for pge-terraform-modules registry

[0.1.0]: https://github.com/pgetech/pge-terraform-modules/releases/tag/azr-app-service-v0.1.0
