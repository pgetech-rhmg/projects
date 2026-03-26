# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-09

### Added
- Initial release of network module
- VNet, subnets, NSGs, and route table creation
- Support for Infoblox-calculated and YAML-based subnet configuration
- SAF2.0 compliance tagging via workspace-info module
- Comprehensive documentation

### Security
- All subnets private by default
- Centralized routing via Hub-Palo firewall

---

## Semantic Versioning Guidelines

- **MAJOR** (x.0.0): Breaking changes - incompatible API changes
- **MINOR** (0.x.0): New features - backward-compatible additions  
- **PATCH** (0.0.x): Bug fixes - backward-compatible fixes
