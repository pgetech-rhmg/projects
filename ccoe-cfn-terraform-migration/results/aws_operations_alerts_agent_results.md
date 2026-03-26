# Repository Assessment: aws_operations_alerts

## 1. Overview
The repository contains CloudFormation templates for AWS operational alerting infrastructure. It establishes CloudWatch alarms, EventBridge rules, SNS topics, and email subscriptions to monitor EC2 instances and send notifications to operations teams.

## 2. Architecture Summary
- **Core Components**: CloudWatch Alarms, EventBridge Rules, SNS Topics, Email Subscriptions
- **Data Flow**: 
  - CloudWatch metrics trigger alarms → SNS notifications
  - EC2 state changes trigger EventBridge → SNS notifications
  - SNS topics deliver messages to email endpoints
- **Environment Handling**: Uses Prod/QA environments with separate SNS topics

## 3. Identified Resources
- AWS::CloudWatch::Alarm
- AWS::Events::Rule
- AWS::SNS::Topic
- AWS::SNS::TopicPolicy
- AWS::SNS::Subscription

## 4. Issues & Risks
- **Security**:
  - Overly permissive SNS policy (Principal: "*" in multiple statements)
  - Missing encryption settings for SNS topics
  - No validation on email parameter input
  - Hardcoded SharedServicesAccountId (686137062481)
- **Configuration**:
  - No alarm actions for InsufficientData state
  - Fixed evaluation period (1 minute) may not suit all metrics
  - No dead-letter queue configuration

## 5. Technical Debt
- **Hardcoding**: SharedServicesAccountId parameter default
- **Modularization**: Single monolithic template instead of nested stacks
- **Parameterization**: Missing parameters for:
  - SNS protocol types
  - Alarm thresholds
  - Evaluation periods
- **Environment Handling**: Uses string literals ("Prod/QA") instead of mappings

## 6. Terraform Migration Complexity
Moderate. Key challenges:
- SNS policy conversion requires HCL syntax adjustments
- Fn::Sub expressions need Terraform interpolation
- Nested stacks would require module restructuring
- EventBridge syntax differs slightly between CFN and Terraform

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - SNS topics (with proper policy structure)
   - CloudWatch alarms
   - EventBridge rules
   - SNS subscriptions
2. Migrate parameters to Terraform variables with validation
3. Replace Fn::If with Terraform conditionals
4. Implement environment separation via workspaces
5. Validate SNS policies against AWS best practices

