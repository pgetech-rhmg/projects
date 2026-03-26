# CHANGELOG

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.3] - 2026-03-18

### Fixed
- **OpenSearch Serverless**: Updated IAM principal ARN validation regex to support AWS SSO roles with multiple path segments
  - `data_access_principals`: Now accepts IAM roles with complex paths (e.g., `aws-reserved/sso.amazonaws.com/region/RoleName`)
  - `privileged_principals`: Now accepts IAM role paths with multiple segments; assumed-role ARNs are restricted to STS (`arn:aws:sts::...:assumed-role/...`) and no longer match `arn:aws:iam::...:assumed-role/...`
  - `public_access_principals`: Uses the same validation as `privileged_principals` (multi-segment IAM role paths; STS-only `assumed-role` ARNs)
  - Fixes validation errors for AWS Identity Center (SSO) IAM role ARNs like: `arn:aws:iam::<account-id>:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_AdministratorAccess`
  - Continues to support STS assumed role ARNs with email sessions: `arn:aws:sts::<account-id>:assumed-role/AWSReservedSSO_CloudAdminNonProdAccess_<id>/user@pge.com`
  - **Regex Pattern**: Changed from `/[a-zA-Z0-9+=,.@_-]+(/[a-zA-Z0-9+=,.@_-]+)?$` (max 2 segments) to `/[a-zA-Z0-9+=,.@_-]+(?:/[a-zA-Z0-9+=,.@_-]+)*$` (unlimited segments)
  - **Breaking Change**: None - this is backward compatible, existing configurations continue to work
  - **JIRA**: CLOUDCOE-16312

## [0.1.2] - 2026-03-10

### Added
- **New Submodule**: OpenSearch Serverless (AOSS) at `modules/opensearch-serverless/`
- OpenSearch Serverless collection support with three collection types:
  - VECTORSEARCH: For vector similarity search and ML/AI workloads
  - SEARCH: For full-text search and log analytics
  - TIMESERIES: For time-series data and observability
- Security policy management for OpenSearch Serverless:
  - Encryption policy with AWS-owned or customer-managed KMS keys
  - Network policy for public or VPC private access control
  - Data access policy for IAM principal permissions management
- **Multi-tier access control** (Amplify security pattern):
  - Single-tier mode: All principals get same permissions (default)
  - Multi-tier mode: Separate privileged and public access tiers
  - Privileged principals: Wildcard index access (admins, automation)
  - Public principals: Named index access only (SSO users, application roles)
  - Configurable via `use_multi_tier_access` variable
- High availability configuration with standby replicas (ENABLED/DISABLED)
- VPC endpoint integration for private access to collections
- **Production-validated index creation**:
  - Bedrock Knowledge Base vector index pattern (1536 dimensions)
  - HNSW algorithm with Faiss engine and L2 distance
  - FP16 encoding for storage optimization
- Comprehensive input validation:
  - Collection name format (3-22 characters, lowercase alphanumeric and hyphens)
  - Collection type enum validation
  - IAM principal ARN validation (IAM users, roles, and assumed roles)
  - KMS key ARN validation for customer-managed encryption
  - Permission list validation for data access and index operations
  - Data access principals validation with lifecycle preconditions
- Lifecycle preconditions for deployment safety:
  - Validates KMS key requirement when not using AWS-owned keys
  - Validates VPC endpoint requirement for private-only access
  - Validates at least one data access principal configured
- Complete output coverage for integration:
  - Collection attributes (ID, ARN, name, endpoints, type)
  - Policy names and versions (encryption, network, data access)
  - KMS key ARN for encryption tracking
  - Access mode (single-tier vs multi-tier)
  - Multi-tier configuration (privileged/public principals and index names)
- Example configuration at `examples/opensearch-serverless/`:
  - Public access with AWS-owned encryption (tested)
  - VPC private access with customer-managed KMS
  - SSM parameter integration for network configuration
  - Existing VPC endpoint reuse pattern
  - Random naming for unique collection names
  - Multi-tier access pattern example with complete guide
- Terraform test framework integration:
  - Test file: `tests/opensearch-serverless.tftest.hcl`
  - 9 test assertions validating deployment
  - Automated testing for CI/CD pipelines
  - All tests passing successfully
- Comprehensive documentation:
  - Submodule README with usage examples
  - 18+ detailed use cases with code examples
  - Module capabilities overview
  - Quick reference guide for common scenarios
  - Network configuration guide with troubleshooting
  - Multi-tier access control guide (`MULTI_TIER_EXAMPLE.md`)
  - Testing guide and validation status
  - TFC deployment verification document

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

---

## [0.1.1] - Previous Release

### Previous Changes
- Existing OpenSearch domain submodules and features
- Domain, domain policy, domain SAML options submodules
- Inbound/outbound connection submodules
- Package and package association submodules
- VPC endpoint submodule

---

## OpenSearch Serverless Technical Details (New in 0.1.2)

### Resource Dependencies
Resources are created in the following order (enforced by `depends_on`):
1. Encryption Policy (if enabled)
2. Network Policy (if enabled)
3. Data Access Policy (if enabled)
4. Collection (depends on all policies)

### Supported Collection Types
- **VECTORSEARCH**: For vector similarity search and ML/AI workloads
- **SEARCH**: For full-text search and log analytics
- **TIMESERIES**: For time-series data and observability

### Encryption Options
- **AWS-owned keys**: Default encryption at rest (no additional cost)
- **Customer-managed KMS**: Enhanced control with AWS KMS (additional cost)

### Network Access Patterns
- **Public Access**: Internet-accessible with IAM authentication
- **VPC Private Access**: Accessible only through VPC endpoints
- **Hybrid**: Public + VPC access (both enabled)

### High Availability
- **Enabled (ENABLED)**: Standby replicas in 3 Availability Zones
- **Disabled (DISABLED)**: Single-zone deployment (lower cost)

---

## Semantic Versioning Guidelines

- **MAJOR** (x.0.0): Breaking changes - incompatible API changes
  - Renamed variables/outputs
  - Removed resources
  - Changed required inputs
  - Changed resource behavior significantly

- **MINOR** (0.x.0): New features - backward-compatible additions
  - New optional variables
  - New resources (non-breaking)
  - New outputs
  - Enhanced functionality

- **PATCH** (0.0.x): Bug fixes - backward-compatible fixes
  - Bug fixes
  - Documentation updates
  - Security patches
  - Performance improvements

---

## Migration Guide

### From Manual AOSS Creation to This Module

If you have existing OpenSearch Serverless collections created manually:

1. **Import existing resources** (if keeping existing collection):
   ```bash
   terraform import module.opensearch_serverless.aws_opensearchserverless_collection.collection <collection-id>
   terraform import module.opensearch_serverless.aws_opensearchserverless_security_policy.encryption[0] <policy-name>
   terraform import module.opensearch_serverless.aws_opensearchserverless_security_policy.network[0] <policy-name>
   terraform import module.opensearch_serverless.aws_opensearchserverless_access_policy.data_access[0] <policy-name>
   ```

2. **Or recreate** (recommended for new deployments):
   - Export data if needed
   - Delete existing collection
   - Deploy using this module
   - Re-import data

---

## Testing Status (v0.1.2)

### OpenSearch Serverless Submodule - Validated Use Cases
- ✅ **Use Case 1**: Public access with AWS-owned encryption and VECTORSEARCH
  - Test framework: `tests/opensearch-serverless.tftest.hcl`
  - All 9 assertions passed successfully
  - Collection creation: ~60 seconds
  - Collection destruction: ~30 seconds
  - Status: **PRODUCTION READY**

- ✅ **Use Case 2**: Bedrock Knowledge Base index creation
  - Vector index with 1536 dimensions (OpenAI/Bedrock embeddings)
  - HNSW algorithm with Faiss engine, L2 distance, FP16 encoding
  - All Bedrock metadata fields configured
  - Index creation successful after policy propagation (120s wait time)
  - Status: **PRODUCTION READY**

### OpenSearch Serverless Submodule - Pending Validation
- ⏳ VPC private access with direct subnet values
- ⏳ VPC private access with SSM parameters
- ⏳ SEARCH collection type
- ⏳ TIMESERIES collection type
- ⏳ Customer-managed KMS encryption
- ⏳ High availability disabled (cost optimization)

---

## Known Issues (v0.1.2)

### Network Access Requirement (Documentation Updated)
- **Issue**: 401 Unauthorized errors when using VPC private access from local machine
- **Root Cause**: OpenSearch Serverless endpoint only accessible from within VPC
- **Solution**: Use `allow_public_access = true` for local testing, or run Terraform from inside VPC
- **Impact**: None - working as designed
- **Documentation**: Network access guide added to examples


### Deprecation Warning
- **Issue**: Warning about deprecated `data.aws_region.current.name` attribute
- **Impact**: None - functionality not affected
- **Resolution**: Will be addressed in VPC endpoint module update

### AWS Service Limitations
- Collection names are immutable after creation
- Policies must be created before collection
- Minimum 1 OCU per collection (cost consideration)
- VPC endpoints required for private access

---

## Support

For issues, questions, or contributions:
- **Team**: Cloud Center of Excellence (CCoE)
- **Contact**: Terraform Developers (ccoe-tf-developers)
- **Documentation**: See module README and use case guides

---

## References

- [OpenSearch Serverless Documentation](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/serverless.html)
- [Terraform AWS Provider - OpenSearch Serverless](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_collection)
- [PGE Terraform Standards](https://github.com/pgetech/pge-terraform-modules)
- [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
- [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
