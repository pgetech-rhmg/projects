# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2026-03-23

### Changed
- **Breaking**: Updated subnet sizing from /26 (64 IPs) to /27 (32 IPs per subnet)
  - Compute, private endpoint, ADO agents, and reserved subnets now use /27 instead of /26  
  - More efficient IP allocation for typical workload requirements
- Consolidated Terraform configuration by moving `terraform` block from `versions.tf` to `main.tf`
- Improved PowerShell script output messages for cleaner logs
- Streamlined error handling messages in deployment script

### Fixed
- Added missing headers definition for Function App authentication (`$headers` variable)
- Corrected subnet calculation logic to use NewBits 5 for /27 subnets

### Removed
- Deleted standalone `versions.tf` file (moved content to `main.tf`)
- Removed verbose error handling instructions from deployment script output

## [0.1.0] - 2026-02-27

### Added
- infoblox-cidr module for private function app



### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

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
  - Security updates
  - Performance improvements
