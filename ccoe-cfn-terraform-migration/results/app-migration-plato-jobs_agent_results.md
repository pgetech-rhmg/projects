# Repository Assessment: app-migration-plato-jobs

## 1. Overview
Partial SAM template defining two Lambda functions (cdecdataimporter and swiftexport) with public API Gateway endpoints, two Lambda layers (Pyodbc and Common), and misconfigured outputs.

## 2. Architecture Summary
Serverless application using SAM with:
- Two Python 3.9 Lambda functions exposed via HTTP GET APIs
- Lambda layers for database connectivity (pyodbc) and shared utilities
- Implicit API Gateway deployment with CORS enabled

## 3. Identified Resources
- AWS::Serverless::Function (2x)
- AWS::Serverless::LayerVersion (2x)
- Implicit AWS::Serverless::Api resource

## 4. Issues & Risks
- **Security**: Public GET endpoints without authentication
- **Configuration**: 
  - Outputs reference non-existent "SnowdataFunction" resources
  - Hardcoded CORS AllowOrigin "*"
  - Missing explicit IAM roles (uses implicit permissions)
- **Reliability**: 
  - Lambda timeout set to maximum (1800s) without justification
  - No VPC configuration for database access

## 5. Technical Debt
- **Hardcoding**: CORS configuration and output descriptions
- **Modularization**: Layer paths use relative references outside template scope
- **Environment Separation**: No stage parameters or environment-specific configurations
- **Missing Resources**: Explicit IAM roles and policy documents

## 6. Terraform Migration Complexity
Moderate. Requires:
- Refactoring SAM transforms to native Terraform resources
- Decomposing implicit API Gateway into explicit resources
- Handling Lambda layer packaging
- Correcting broken output references

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - Lambda functions (with explicit IAM)
   - API Gateway resources
   - Lambda layers
2. Migrate global configurations first
3. Implement proper environment staging
4. Validate IAM permissions before deployment

