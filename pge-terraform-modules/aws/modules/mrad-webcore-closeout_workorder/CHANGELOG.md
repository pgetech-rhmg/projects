# CHANGELOG
## [0.0.13] - 2026-03-11

- feat: downgrade Lambda runtime from nodejs24.x to nodejs22.x (AWS provider 5.x constraint)

## [0.0.12] - 2026-03-10

- feat: bump pgetech/lambda/aws sub-module from 0.0.17 to 0.1.4 to support nodejs24.x runtime

## [0.0.11] - 2026-03-10

- feat: upgrade Lambda runtime from nodejs20.x to nodejs24.x

## [0.0.10] - 2026-02-17

- security: update SumoLogic OpenTelemetry layer from v1-17-2 to v2-0-0 to fix CVE-2023-44487
  - Addresses vulnerable gRPC version 1.58.2 in OpenTelemetry Collector
  - New layer includes OpenTelemetry Collector v0.138.0 with gRPC >= 1.58.3
  - Updated layer ARN: `arn:aws:lambda:us-west-2:663229565520:layer:sumologic-otel-lambda-nodejs-x86_64-v2-0-0:1`
  - Note: Using v2.0.0 instead of v2.0.1 to avoid external package dependency issues


## 0.0.9  

- **Fix**: schedule lambda fucntion every day 6 pm instead of 48 hours

## 0.0.8 

- **Fix**: Fixing Lambda ENV

## 0.0.7 

- **Fix**: Fixing Lambda ENV

## 0.0.6

- **Fix**: Fixing Lambda ENV

## 0.0.5

- **Fix**: Fixing Lambda Name

## 0.0.4 

- **Fix**: Fixing Lambda Name

## 0.0.3

- **Fix**: Fixing Lambda

## 0.0.2 

- **Fix**: Fixing Lambda ENV

## 0.0.1 

- Initial release

