# CHANGELOG
## [0.1.15] - 2026-03-11

- feat: downgrade Lambda runtime from nodejs24.x to nodejs22.x (AWS provider 5.x constraint)

## [0.1.14] - 2026-03-10

- feat: bump pgetech/lambda/aws sub-module from 0.0.17 to 0.1.4 to support nodejs24.x runtime

## [0.1.13] - 2026-03-10

- feat: upgrade Lambda runtime from nodejs20.x to nodejs24.x

## [0.1.12] - 2026-02-17

- security: update SumoLogic OpenTelemetry layer from v1-17-2 to v2-0-0 to fix CVE-2023-44487
  - Addresses vulnerable gRPC version 1.58.2 in OpenTelemetry Collector
  - New layer includes OpenTelemetry Collector v0.138.0 with gRPC >= 1.58.3
  - Updated layer ARN: `arn:aws:lambda:us-west-2:663229565520:layer:sumologic-otel-lambda-nodejs-x86_64-v2-0-0:1`
  - Note: Using v2.0.0 instead of v2.0.1 due to external package dependency issues

## [0.1.10] - 2025-09-29

- fix: update sumo module version##
## [0.1.9] - 2025-09-29

- fix: update sumo module version##
## [0.1.8] - 2025-09-26

- fix: update sumo module version##
[0.1.7] - 2025-09-26

- fix: update sumo module version
## [0.1.6] - 2025-08-26

- fix: added missing lambda environment variables

## [0.1.5] - 2025-08-26

- fix: replace contains() with try() as we don't want to modify the default values

## [0.1.4] - 2025-08-26

- fix: replacing lookup() with contains() as is not compatible with maps that are not simple string key/value(s)

## [0.1.3] - 2025-08-26

- fix: aws_s3_object tags have required keys but are limited to 10 max

## [0.1.2] - 2025-08-25

- fix: added missing tags to aws_s3_object

## [0.1.1] - 2025-08-25

- fix: typo

## [0.1.0] - 2025-08-25

- feat: s3 lambda deployment changes

## [0.0.9] - 2025-07-23

- feat: replace branch with suffix

## [0.0.8] - 2024-10-17

- feat: OTEL_RESOURCE_ATTRIBUTES values

## [0.0.7] - 2024-10-11

- feat: opentelemetry layers

## [0.0.6] - 2024-10-08

- feat: adding sumologic opentelemetry layer and config

## [0.0.5] - 2024-08-12

- feat: use parameter for cloudutils layer version

## [0.0.4] - 2024-08-08

- feat: use SHA256 checksum to detect Lambda code changes
- feat: updated cloud-utilities layer version

## [0.0.3] - 2024-06-24

- fix: get bucket name from local.envname

## [0.0.2] - 2024-06-13

- fix: use local.envname for cloudutils data layer

## [0.0.1] - 2024-06-11

- Initial release
