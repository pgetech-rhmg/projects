# CHANGELOG
## [0.0.18] - 2026-03-11

- feat: downgrade Lambda runtime from nodejs24.x to nodejs22.x (AWS provider 5.x constraint)

## [0.0.17] - 2026-03-10

- feat: bump pgetech/lambda/aws sub-module from 0.0.17 to 0.1.4 to support nodejs24.x runtime

## [0.0.16] - 2026-03-10

- feat: upgrade Lambda runtime from nodejs20.x to nodejs24.x

## [0.0.15] - 2026-02-17

- security: update SumoLogic OpenTelemetry layer from v1-17-2 to v2-0-0 to fix CVE-2023-44487
  - Addresses vulnerable gRPC version 1.58.2 in OpenTelemetry Collector
  - New layer includes OpenTelemetry Collector v0.138.0 with gRPC >= 1.58.3
  - Updated layer ARN: `arn:aws:lambda:us-west-2:663229565520:layer:sumologic-otel-lambda-nodejs-x86_64-v2-0-0:1`
  - Note: Using v2.0.0 instead of v2.0.1 to avoid external package dependency issues

## [0.0.14] - 2025-09-29

- feat: updated sumo lambda version
## [0.0.13] - 2025-09-26

- feat: updated sumo lambda version
## [0.0.12] - 2025-09-25

- feat: updated sumo lambda version
## [0.0.11] - 2024-10-17

- feat: OTEL_RESOURCE_ATTRIBUTES values

## [0.0.10] - 2024-10-11

- feat: opentelemetry layers

## [0.0.9] - 2024-10-10

- feat: sumo logging

## [0.0.8] - 2024-10-02

- feat: change zipfile name

## [0.0.7] - 2024-08-12

- feat: use parameter for cloudutils layer version

## [0.0.6] - 2024-08-08

- feat: use SHA256 checksum to detect Lambda code changes
- feat: updated cloud-utilities layer version

## [0.0.5] - 2024-06-24

- fix: get bucket name from local.envname

## [0.0.4] - 2024-06-14

- fix: incorrect aws_role used in KMS key policy

## [0.0.3] - 2024-06-14

- fix: missing tags on 2 resources

## [0.0.2] - 2024-06-13

- fix: use local.envname for cloudutils data layer

## [0.0.1] - 2024-06-11

- Initial release
