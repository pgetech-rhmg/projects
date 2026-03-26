# Changelog

**IMPORTANT NOTICE:** Do not use v3.x releases , they are only to be used once we start our kinesis/firehose migration. The current stable version line is 2.x . 

## 3.0.9-rc2

- make old parameters optional

## 3.0.9-rc1

- fix sumologic provider

## 3.0.8

- **Enhancement**: Add explicit dependency on Firehose delivery stream active status to ensure proper resource ordering
- **Fix**: Prevent subscription filter creation before Firehose is fully active

## 3.0.7

- **Enhancement**: Reuse shared IAM role from `mrad-shared-infra` instead of creating per-consumer roles
- **Optimization**: Reduce IAM resource duplication across multiple consumers
- **Security**: Centralized IAM role management for better governance

## 3.0.6

- **Feature**: Create individual CloudWatch subscription filters for each consumer
- **Refactor**: Move IAM role creation to `mrad-shared-infra` for shared resource management
- **Enhancement**: Improved resource naming and tagging per consumer
- **Architecture**: Support for multi-consumer log aggregation pattern

## 3.0.5

- **Fix**: Add missing `depends_on` declarations for proper resource dependency management
- **Stability**: Ensure Firehose data source is evaluated before subscription filter creation

## 3.0.4

- **Fix**: Adjust resource tagging to align with organizational standards
- **Enhancement**: Improve tag consistency across resources

## 3.0.3

- **Feature**: Initial implementation of CloudWatch subscription filter for SumoLogic integration
- **Infrastructure**: Basic Firehose stream discovery via SSM parameters
- **Setup**: Core subscription filter creation with configurable log group targeting

## 3.0.2

- **Documentation**: Add comprehensive module documentation and usage examples
- **Testing**: Include test configurations and validation scenarios

## 3.0.1

- **Fix**: Correct IAM policy permissions for CloudWatch subscription filters
- **Security**: Ensure minimal required permissions for log delivery

## 3.0.0

- **Breaking Change**: Migrate from individual Lambda-based log shipping to shared Firehose architecture


### 2.5.x

- **Performance**: Optimize Lambda memory allocation and timeout settings
- **Monitoring**: Add CloudWatch metrics and alarms for Lambda function performance

### 2.4.x

- **Security**: Enhanced IAM policies with least-privilege access
- **Compliance**: Add support for VPC deployment and private endpoints
- **Logging**: Improved error handling and retry logic for failed deliveries

### 2.3.x

- **Feature**: Add support for custom log formatting and filtering
- **Integration**: Enhanced SumoLogic source configuration options
- **Documentation**: Comprehensive setup and troubleshooting guides

### 2.2.x

- **Fix**: Resolve memory leaks in long-running Lambda functions
- **Enhancement**: Add batch processing for high-volume log streams
- **Monitoring**: Implement detailed logging and metrics collection

### 2.1.x

- **Feature**: Support for multiple SumoLogic collectors and sources
- **Security**: Implement encryption for logs in transit
- **Performance**: Optimize cold start times and processing latency

### 2.0.x

- **Breaking Change**: Migrate to Terraform 0.12+ syntax
- **Architecture**: Refactor for improved maintainability and scalability
- **Testing**: Add comprehensive unit and integration tests

### 1.5.x

- **Stability**: Fix race conditions in resource creation
- **Documentation**: Add basic usage examples and API documentation

### 1.4.x

- **Feature**: Add support for custom SumoLogic source categories
- **Enhancement**: Improve error handling and logging

### 1.3.x

- **Fix**: Resolve IAM permission issues for log delivery
- **Security**: Implement basic encryption for sensitive configuration

### 1.2.x

- **Feature**: Add CloudWatch monitoring and alerting
- **Performance**: Optimize Lambda function resource allocation

### 1.1.x

- **Fix**: Correct SumoLogic endpoint configuration and authentication
- **Enhancement**: Add retry logic for failed deliveries

### 1.0.x

- **Initial Release**: Basic SumoLogic log shipping via Lambda functions
- **Infrastructure**: Core IAM roles, policies, and Lambda function setup
- **Integration**: Simple HTTP-based delivery to SumoLogic collectors


