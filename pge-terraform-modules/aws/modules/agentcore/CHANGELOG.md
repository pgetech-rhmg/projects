# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2] - 2026-03-18
### Changed
- Regenerated submodule READMEs with descriptions and corrected provider version constraints (`awscc >= 1.0`, `time >= 0.9`, `random >= 3.6.0`) for `browser`, `core_interpreter`, `gateway`, `identity`, `memory`, and `runtime` submodules
- Removed unused `random` provider requirement from `examples/agent_runtime` README
- Pinned `workspace-info` module version to `0.1.0` in `modules/runtime/main.tf`

### Fixed
- Corrected provider version constraints in submodule READMEs (replaced `n/a` with explicit minimum versions)

## [0.1.1] - 2026-03-17
### Added
- Added `main.tf` entrypoint files for internal submodules: `browser`, `core_interpreter`, `gateway`, `identity`, and `memory`

### Changed
- Added missing provider version constraints in submodules (`awscc`, `random`, `time`) where resources are used
- Removed unused `random` provider declaration from `examples/agent_runtime/providers.tf`

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- Addressed CI validation findings for module structure and provider requirements

### Security
- N/A

## [0.1.0] - 2026-03-17
### Added
- Initial release of the `agentcore` module
- Runtime submodule and example configurations
- Module documentation generated with terraform-docs

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
