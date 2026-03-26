# Repository Assessment: rds-aurora-mysql

## 1. Overview
The repository contains two CloudFormation templates that provision a secure, scalable Aurora MySQL database cluster with:
- Primary instance + 1 replica
- Parameter groups with audit logging
- Secrets Manager integration
- VPC-isolated security groups
- Autoscaling configuration
- SSM parameter exports

## 2. Architecture Summary
- **Core Services**: RDS Aurora MySQL, Secrets Manager, SSM Parameter Store, AutoScaling
- **Pattern**: Multi-AZ database cluster with automated scaling
- **Security**: Encryption at rest, IAM auth enabled, private subnet isolation
- **Observability**: CloudWatch logs export (audit/error/general/slowquery)

## 3. Identified Resources
- RDS::DBSubnetGroup
- EC2::SecurityGroup
- RDS::DBClusterParameterGroup
- RDS::DBParameterGroup
- SecretsManager::Secret
- SecretsManager::SecretTargetAttachment
- RDS::DBCluster
- RDS::DBInstance (primary + replica)
- SSM::Parameter (6x)
- AutoScalingPlans::ScalingPlan

## 4. Issues & Risks
- **Security**:
  - Hardcoded ARN region in rParamStoreDBClusterARn (us-west-2)
  - Missing VPC flow logs configuration
  - Security group allows entire subnet CIDRs (potential over-permission)
  - Master password stored as plaintext parameter
- **Configuration**:
  - DeletionProtection only on cluster, not instances
  - No backup window validation
  - Aurora 5.6 deprecated (conditionally used)
- **Reliability**:
  - Single replica (no cross-AZ failover)
  - No explicit DB failover priority configuration

## 5. Technical Debt
- **Parameter Sprawl**: 17 parameters with overlapping metadata
- **Hardcoded Values**: ARN region, monitoring role ARN
- **Modularization**: Single monolithic template
- **Environment Handling**: No dev/prod separation
- **IAM**: Hardcoded monitoring role ARN

## 6. Terraform Migration Complexity
Moderate. Requires:
- Mapping SSM parameter lookups to Terraform data sources
- Decomposing into modules (network/security/database/autoscaling)
- Handling Secrets Manager rotation
- Refactoring conditional logic
- Managing ARN construction differences

## 7. Recommended Migration Path
1. Create VPC/networking module (subnet groups)
2. Migrate security groups with data sources
3. Implement parameter groups as standalone resources
4. Convert database cluster with dependency chains
5. Add Secrets Manager resources
6. Implement AutoScaling configuration

