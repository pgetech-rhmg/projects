# Repository Assessment: ew-data-services-tank

## 1. Overview
The repository contains CloudFormation templates for a multi-environment data ingestion pipeline using containerized workloads. Core components include ECR repositories, S3 buckets, CodePipeline/CodeBuild CI/CD, Lambda automation, and AutoScaling infrastructure. The solution appears designed for emergency web services with compliance tagging requirements.

## 2. Architecture Summary
- **CI/CD Pipeline**: Uses CodePipeline + CodeBuild to build Docker containers from GitHub sources and push to ECR
- **Container Management**: ECR repositories store container images with SSM parameter tracking
- **Data Flow**: S3 buckets handle configuration storage, artifact management, and Elasticsearch snapshot replication
- **Automation**: Lambda functions manage Elasticsearch snapshots, CloudFormation updates, and AMI copying
- **Compute**: AutoScaling groups deploy containers using EC2 launch templates with environment-specific configurations
- **Security**: SNS topics for notifications, KMS encryption for S3/Lambda, and VPC-enabled Lambda functions

## 3. Identified Resources
- ECR::Repository (2)
- S3::Bucket (7) + BucketPolicies (6)
- SNS::Topic (4) + TopicPolicies (2) + Subscription (2)
- IAM::Role (8) + Policies (5) + InstanceProfile (1)
- Lambda::Function (5) + Permissions (2)
- CodePipeline::Pipeline (3)
- CodeBuild::Project (3)
- SecretsManager::Secret (4)
- SSM::Parameter (15)
- AutoScaling::AutoScalingGroup (1)
- EC2::LaunchTemplate (1)
- Events::Rule (1)

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies (e.g., `s3:*`, `ec2:*`, `logs:*` on multiple resources)
  - Hardcoded AWS account ID in 01-setup.yml (`pAccount: 164755717202`)
  - Missing VPC configuration for Lambda in 01-setup.yml
  - Public GitHub token parameter in 01-setup.yml (`pGitHubToken: NoEcho: False`)
  - Lambda execution role in 06-asg.yml allows `ec2:DescribeVolumues` (typo in action name)
  - Disabled S3 block public access configuration in 05-pipeline-setup.yml uses uppercase booleans

- **Reliability**:
  - AutoScalingGroup in 06-asg.yml has `MinInstancesInService: 0` during updates
  - Missing error handling in Lambda inline code (01-setup.yml)
  - Hardcoded region values in multiple templates

- **Compliance**:
  - Uses deprecated `python3.7` runtime (EOL March 2024)
  - Missing lifecycle policies on S3 buckets
  - Inconsistent tagging implementation across resources

## 5. Technical Debt
Not Observed

## 6. Terraform Migration Complexity
Not Observed

## 7. Recommended Migration Path
Not Observed

