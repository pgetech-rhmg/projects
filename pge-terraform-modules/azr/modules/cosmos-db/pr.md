# CCOE pull request
```
NOTE: pull request should be from a branch in the format <your-lanid>/cloudcoe-####,
e.g: b1v6/cloudcoe-2769, otherwise pr-lint will not allow you to submit a pull request
```

## Title
feat: add new Azure Cosmos DB Terraform module with SQL API support

## Description
This PR introduces a new Terraform module for Azure Cosmos DB (cosmos-db) under `/azr/modules/`. This module provides a standardized, secure, and PG&E-compliant way to deploy Azure Cosmos DB instances with SQL API.

**Associated User Story:** CLOUDCOE-16230  
**Jira Link:** https://jirapge.atlassian.net/browse/CLOUDCOE-16230

### Key Features:
- Azure Cosmos DB account creation with SQL API support
- RBAC-based authentication (local authentication disabled by default)
- Configurable consistency levels (default: BoundedStaleness)
- Support for both serverless and provisioned capacity modes
- Automated backup configuration with flexible intervals and retention policies
- SQL database and container provisioning with partition key support
- Security-first defaults (public network access disabled, RBAC enforced)
- Lifecycle protection to prevent accidental resource deletion
- Integration with PG&E tagging standards and TFC workspace tracking
- Comprehensive documentation and examples

### Dependencies:
- Azure provider ~> 4.0
- PG&E utils module (workspace-info) v0.1.0

## Type of change

- [x] New feature (non-breaking change which adds functionality)
- [x] This change requires a documentation update

## How Has This Been Tested?

This module has been tested using Terraform native testing framework and manual validation:

- [x] **Terraform validation**: `terraform validate` passed successfully
- [x] **Terraform test**: Native Terraform tests created in `tests/cosmos-sql.tftest.hcl`
- [x] **Terraform fmt**: Code formatted according to Terraform standards
- [x] **Manual testing**: Example configuration tested in `examples/cosmos-sql/`
- [x] **Documentation**: Auto-generated using terraform-docs
- [x] **Security review**: RBAC enabled, local auth disabled, public access disabled by default

**Test Configuration:**
- Terraform version: 1.5+
- Azure provider version: ~> 4.0
- Test environment: Azure development subscription
- Capacity mode tested: Serverless (default)
- Consistency level tested: BoundedStaleness (default)

## Release Notes

```xml
<releaseNotes>
    <module>
        <name>azr/modules/cosmos-db</name>
        <version>0.1.0</version>
        <item>Initial release of Azure Cosmos DB Terraform module</item>
        <item>Support for Azure Cosmos DB with SQL API</item>
        <item>RBAC-based authentication with disabled local authentication</item>
        <item>Serverless and provisioned capacity mode support</item>
        <item>Configurable backup policies with Periodic backup type</item>
        <item>SQL database and container provisioning with partition key configuration</item>
        <item>Security-first defaults: public access disabled, lifecycle protection enabled</item>
        <item>Comprehensive tagging with PG&E standards and TFC workspace integration</item>
        <item>Includes examples, tests, and auto-generated documentation</item>
    </module>
</releaseNotes>
```


## Checklist:

- [x] My code follows the style guidelines of this project
- [x] I have performed a self-review of my own code
- [x] I have commented my code, particularly in hard-to-understand areas
- [x] I have incremented the module version in `module.info`
- [x] I have made corresponding changes to the documentation
- [x] My changes generate no new warnings
- [x] I have added tests that prove my fix is effective or that my feature works
- [x] New and existing unit tests pass locally with my changes
- [x] Any dependent changes have been merged and published in downstream modules
