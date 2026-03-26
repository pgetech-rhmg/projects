# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.3] - 2026-03-10

### Added
- S3 target endpoint sub-module (modules/dms_endpoint_s3/)
- S3 target endpoint example (examples/dms-s3-target-endpoint/)
- Support for CSV and Parquet data formats
- GZIP compression support for S3 data
- Date-based partitioning for S3 folder organization
- Multiple date partition sequence options (YYYYMMDD, YYYYMMDDHH, etc.)
- Configurable CSV settings (delimiters, column headers, operation columns)
- Multiple encryption modes (SSE_S3, SSE_KMS, CSE_KMS)
- PGE IAM module integration for S3 access permissions
- SSM Parameter Store integration for secure credential management
- Combined source and target endpoint creation in single module

### Changed
- Updated all DMS examples to use standardized terraform.auto.tfvars format
- Improved variable consistency across all examples

---

## Previous Versions

### [0.1.2] and earlier
- Initial DMS module implementation  
- Basic endpoint configuration examples (manual and secrets-based)
- Manual endpoint management
- Core DMS replication functionality