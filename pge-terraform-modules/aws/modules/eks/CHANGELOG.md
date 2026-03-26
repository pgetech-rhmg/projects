# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.4] - 2026-02-20

### Added
- On-the-fly Customer Managed Key (CMK) creation support for cluster and EBS encryption in both Auto Mode and Node Groups
- Documentation in Auto Mode example demonstrating how to achieve full encryption for Restricted/Confidential workloads

### Removed
- Removed dependency on AWS Systems Manager parameters for RFC 1918 CIDR references in both Auto Mode and Node Groups

### Fixed
- Auto Mode no longer references the non-existent `ebs_encrypt` KMS key that was missing in most accounts

---

## Semantic Versioning Guidelines

- **MAJOR** (x.0.0): Breaking changes - incompatible API changes
- **MINOR** (0.x.0): New features - backward-compatible additions
- **PATCH** (0.0.x): Bug fixes - backward-compatible fixes
