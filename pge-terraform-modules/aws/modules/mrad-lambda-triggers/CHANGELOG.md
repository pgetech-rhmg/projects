# Changelog

## 3.0.0-rc6

- fix provider
- fix module path
- fix version string

## 3.0.0-rc5
- fix provider

## 3.0.0-rc4
- upgrade mrad-sumo

## 3.0.0-rc3
- fix: use the tags parameter from the consumer

## 3.0.0-rc2
- fix mrad-common path

## 3.0.0-rc1
- incremental upgrade to mrad-sumo v2

## 2.2.0
- Add support for custom filter patterns and disambiguator for Sumo sources
- Upgrade dependency: mrad-sumo v1.8.x
- Improved tagging convention (merge tags and optional_tags)
- Bugfix: ensure Lambda permissions are correctly scoped for API Gateway triggers

## 2.1.0
- Support for multiple Lambda triggers per API Gateway
- Add optional `http_source_name` parameter for Sumo source customization
- Upgrade dependency: mrad-sumo v1.7.x

## 2.0.0
- Major refactor for compatibility with CCoE SAF2.0 modules
- Initial support for mrad-sumo v1.x
- Add tagging and environment variable threading for all submodules
- Improved documentation and examples

## 1.0.0
- Initial release: Lambda trigger module for API Gateway
- Basic integration with mrad-sumo v1.x
- Supports tagging, environment threading, and CloudWatch log group creation