# Repository Assessment: gis_geomartcloud_customercare_incremental_datasync

## 1. Overview
This CloudFormation template provisions two AWS Lambda functions for customer data synchronization operations (insert/update and delete) in a VPC-connected environment. It uses SSM Parameter Store for configuration values and includes basic tagging.

## 2. Architecture Summary
The solution deploys:
- Two Lambda functions (Python 3.7) with VPC connectivity
- Dependency on external IAM role (hardcoded ARN)
- PostgreSQL layer integration (psycopg2)
- Environment-specific configuration via SSM parameters

## 3. Identified Resources
- AWS::Lambda::Function (x2)
- AWS::SSM::Parameter::Value references (x7)

## 4. Issues & Risks
- **Security Risk**: Hardcoded IAM role ARN (account 412551746953) creates cross-account dependency
- **Configuration Gap**: No database resources defined - assumes external RDS/Aurora
- **Missing IAM**: Lambda execution role not defined in template
- **Error Handling**: No DLQ configuration for Lambda functions
- **Deprecated Runtime**: Python 3.7 reached EOL June 2023

## 5. Technical Debt
- **Inline Code**: Lambda code embedded as ZipFile strings (not S3 reference)
- **Parameter Redundancy**: Multiple SubnetID parameters instead of list type
- **Tight Coupling**: Hard dependency on external security group configuration
- **No Logging**: CloudWatch log retention not configured

## 6. Terraform Migration Complexity
Moderate. Key considerations:
- SSM parameters require aws_ssm_parameter data sources
- Hardcoded ARNs need parameterization
- Lambda inline code would convert to file-based deployment
- Missing IAM roles would require explicit resource creation

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - Lambda functions (with VPC config)
   - IAM roles (if added to template)
2. Parameterize all hardcoded values
3. Migrate SSM parameters to Terraform variables
4. Replace inline code with S3 bucket references
5. Validate using terraform plan with existing CloudFormation stack

