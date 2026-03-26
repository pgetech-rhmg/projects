# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.8] - 2026-03-17

### Fixed
- Fixed Lambda function recreation on every terraform plan/apply in codestar_notifications module
- Use filesha256() on actual source file to detect real code changes instead of archive timestamps

## [0.1.7] - 2024-12-03

### Added
- Initial tracked release
- codestar_notifications module for CodePipeline notifications
- gh_webhook module for GitHub webhook integration
