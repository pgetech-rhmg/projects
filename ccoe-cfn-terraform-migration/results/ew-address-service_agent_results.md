# Repository Assessment: ew-address-service

## 1. Overview
The repository contains CloudFormation templates for the "EW Data Service" - a data ingestion pipeline that processes CSV files from S3, splits them into JSON shards, indexes into Elasticsearch, and includes scaling/management capabilities.

## 2. Architecture Summary
- **Data Flow**: CSV files → S3 → Lambda (splitter) → S3 (splits) → Lambda (indexer) → Elasticsearch
- **Core Services**: S3, Lambda, Elasticsearch, VPC, IAM, CloudWatch Events
- **Patterns**: Event-driven architecture, serverless processing, VPC-isolated Elasticsearch

## 3. Identified Resources
- 4x S3 Buckets (CSV, splits, code, logs)
- 1x Elasticsearch Domain (v6.8)
- 7x Lambda Functions (splitter, indexer, template mgr, alias swapper, scaler, scanner)
- 3x IAM Roles (Lambda execution, EC2 SSM, ES service-linked)
- 1x VPC with 3 private subnets
- 1x EC2 instance (utility)
- 1x CloudWatch Events Rule

## 4. Issues & Risks
- **Security**:
  - Elasticsearch domain uses overly permissive access policy (Principal: "*")
  - IAM roles contain wildcard resource permissions ("*")
  - EC2 instance uses default SSH key pair
  - S3 buckets lack explicit encryption configuration
  - Lambda functions have VPC access but no egress controls
- **Configuration**:
  - Elasticsearch v6.8 is deprecated (EOL Feb 2021)
  - Hardcoded AMI ID in util-ec2.yaml
  - Missing dead-letter queues for Lambda functions
  - No lifecycle policies on S3 buckets

## 5. Technical Debt
- **Modularization**:
  - Single monolithic repository with no nested stacks
  - Lambda functions share common configuration patterns
- **Hardcoding**:
  - AMI IDs, VPC CIDRs, and subnet configurations
  - Default parameter values embedded in templates
- **Environment Management**:
  - No environment separation (dev/prod)
  - Missing standardized tagging strategy
  - No parameter namespaces

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources (S3, Lambda, IAM)
- VPC configuration would require CIDR block refactoring
- Lambda layer ARN construction needs string interpolation
- Service-linked roles require special handling
- Would need to decompose into Terraform modules

## 7. Recommended Migration Path
1. Establish Terraform environment (backend, providers)
2. Migrate network stack (VPC/subnets) first
3. Create IAM module for roles/policies
4. Migrate S3 buckets with proper encryption
5. Convert Lambda functions using zipfile() resources
6. Implement Elasticsearch with updated version
7. Validate all !ImportValue references

