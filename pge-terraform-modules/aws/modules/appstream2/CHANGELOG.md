# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2026-02-26

### Added
- **Domain Join Configuration Improvements**: 
  - Added unified `domain_join_info` object variable for both image builder and fleet modules
  - Supports optional organizational unit distinguished name parameter
  - Dynamic domain join configuration blocks that are conditionally created

### Changed
- **Fleet Module Domain Join**: 
  - **BREAKING CHANGE**: Replaced separate `directory_name` and `organizational_unit_distinguished_name` variables with unified `domain_join_info` object
  - Updated fleet module to use dynamic domain join configuration block

### Improved
- **Access Endpoint Configuration**: 
  - Enhanced VPC endpoint condition to handle both null and empty string cases (`var.vpce_id != null && var.vpce_id != ""`)

## [0.2.0] - 2026-02-26

### Added
- Added `lifecycle.ignore_changes` for `desired_instances` in fleet submodule to support AWS Application Auto Scaling

### Changed
- Made `endpoint_type` and `vpce_id` variables optional with `default = null`
- Converted `access_endpoint` block to dynamic block to allow image builders without VPC endpoints
- Made `enable_default_internet_access` dynamic: enabled when no VPC endpoint, disabled when using VPC endpoint

### Fixed
- Fixed autoscaling: Terraform no longer resets fleet instance count on apply, allowing AWS autoscaling to work correctly

## [0.1.0] - 2022-08-19

### Added
- Initial release of appstream2 module
- Image builder resource with VPC endpoint support
- Fleet submodule for streaming instances
- Stack submodule for user session configuration
- User and user_stack_association submodules for USERPOOL authentication
- Directory config submodule for Active Directory integration
- Fleet-stack association submodule
- Domain join support for image builders
