# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-04

### Added
- Initial release of TFC Workspace Settings module
- Support for configuring workspace settings via TFC API including:
  - Auto-apply behavior for run triggers
  - Verification of applied workspace settings
  - Parsing and exposing workspace metadata for downstream modules
- Run trigger creation for WS2 → WS3 automation workflows:
  - Trigger WS3 runs automatically when WS2 completes successfully
  - Support for linking source and destination workspaces
- Workspace settings introspection:
  - Read and expose workspace attributes for external modules
  - Provide structured outputs for automation pipelines
- Standardized module metadata including author, module path, and creation date

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- Ensures workspace settings are applied using authenticated TFC API calls
- Avoids storing sensitive configuration in state by using API-based updates
