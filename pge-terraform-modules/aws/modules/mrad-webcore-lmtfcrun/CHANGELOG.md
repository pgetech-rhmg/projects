# CHANGELOG
## [0.0.8] - 2026-03-11

- feat: downgrade Lambda runtime from nodejs24.x to nodejs22.x (AWS provider 5.x constraint)

## [0.0.7] - 2026-03-10

- feat: bump pgetech/lambda/aws sub-module from 0.0.17 to 0.1.4 to support nodejs24.x runtime

## [0.0.6] - 2026-03-10

- feat: upgrade Lambda runtime from nodejs20.x to nodejs24.x

## [0.0.5] - 2026-02-17

- security: update SumoLogic OpenTelemetry layer from v1-17-2 to v2-0-0 to fix CVE-2023-44487
  - Addresses vulnerable gRPC version 1.58.2 in OpenTelemetry Collector
  - New layer includes OpenTelemetry Collector v0.138.0 with gRPC >= 1.58.3
  - Updated layer ARN: `arn:aws:lambda:us-west-2:663229565520:layer:sumologic-otel-lambda-nodejs-x86_64-v2-0-0:1`
  - Note: Using v2.0.0 instead of v2.0.1 to avoid external package dependency issues


## [0.0.4] - 2024-10-17

- feat: OTEL_RESOURCE_ATTRIBUTES values

## [0.0.3] - 2024-10-11

- feat: opentelemetry layers

## [0.0.2] - 2024-10-07

- feat: sumo logger

## [0.0.1] - 2024-09-16

- Initial release
