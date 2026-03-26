# Changelog

**IMPORTANT NOTICE:** Version 4.x releases (4.0.1 and 4.0.2) were experimental and have been **REVERTED**. The last stable version is 3.0.4. Do not use v4.x releases as they are no longer supported.

---

## 4.0.2 (REVERTED)

**Status:** This version was rolled back to 3.0.1
- Version number bump only
- Bump default Node version to latest LTS (22.x)
- **Breaking Change:** Continued use of mrad-common module for tagging (reverted in 3.0.1)

## 4.0.1 (REVERTED)

**Status:** This version was rolled back to 3.0.1
- Bump default Node version to latest LTS (22.x)
- Default runtime changed from `nodejs16.x` to `nodejs22.x`
- **Breaking Changes:**
  - Runtime change: Default Node.js runtime changed from 16.x to 22.x
  - Continued use of mrad-common module for tagging (reverted in 3.0.1)

## 3.0.5-rc15

**Status:** Release Candidate

- **lambda-sumo**: Add AWS-managed KMS support for S3 bucket encryption
  - New variable `use_aws_managed_s3_kms` (default: false) to use AWS-managed KMS (aws/s3) for S3 buckets
  - Separates S3 bucket encryption from Lambda environment variable encryption
  - Fixes KMS decrypt permission issues with TFC provisioning roles
  - Makes customer-managed KMS key creation conditional (only when needed)
  - **State Migration:** Added `moved` block for KMS module (rc14 → rc15 upgrade is safe)
  - Maintains backward compatibility: existing deployments continue with customer-managed KMS
  - Recommended for deployments where provisioning role lacks customer-managed KMS decrypt permissions

## 3.0.5-rc14

**Status:** Release Candidate

- **lambda-sumo**: Verified moved blocks for Lambda redeployment scenarios
  - Removed moved block for `aws_lambda_function` (no longer exists in state after deletion)
  - Retained moved blocks for S3, IAM, and log group resources (migrate existing infrastructure)
  - Supports clean redeployment when Lambda functions are deleted and recreated
  - No code changes from rc13 - state migration verification only

## 3.0.5-rc13

**Status:** Release Candidate

- **lambda-sumo**: Replace `lambda_s3_bucket` module with direct `aws_lambda_function` resource
  - Removes dependency on external module with problematic KMS validation blocks
  - Creates Lambda function directly using native Terraform resource
  - Eliminates "Invalid count argument" and "attribute 'kms_key_arn' is required" errors
  - Maintains 100% backward compatibility - no consumer changes required
  - Same inputs, outputs, and functionality as previous versions
  - Resource name kept as `lambda_function` to minimize state migration impact

## 3.0.5-rc12

**Status:** Release Candidate

- **lambda-sumo**: Use `local.kms_key_arn` directly in environment_variables
  - Changed from conditional merge to always passing both `variables` and `kms_key_arn` keys
  - `local.kms_key_arn` always provides a value (either external `var.kms_key_arn` or internal `module.kms_key.key_arn`)
  - Satisfies downstream `lambda_s3_bucket` module requirement that `kms_key_arn` attribute must be present
  - Resolves "attribute 'kms_key_arn' is required" validation error
  - Ensures consistent object structure for environment_variables at plan time

## 3.0.5-rc11

**Status:** Release Candidate

- **lambda-sumo**: Refined KMS key reference handling in environment_variables
  - Maintained conditional merge approach: `var.kms_key_arn != null ? { kms_key_arn = var.kms_key_arn } : {}`
  - Ensures Terraform can evaluate count conditions at plan time
  - Supports both internal KMS key creation (default) and external key references
  - Resolves "Invalid count argument" errors with dynamic KMS ARN values

## 3.0.5-rc10

**Status:** Release Candidate

- **lambda-sumo**: Fixed KMS key reference to use module output instead of data source
  - Reverted rc8 change: Changed back from `data.aws_kms_key.lambda_kms.arn` to `module.kms_key.key_arn`
  - Removed data source lookup that was causing "couldn't find resource" errors
  - The data source was attempting to look up a key that doesn't exist yet during first apply
  - Using the module output directly resolves the circular dependency
  - This is a bug fix - backward compatible with all existing consumers
  
## 3.0.5-rc9

**Status:** Release Candidate

- **lambda-sumo**: Fixed incorrect data source declaration in data.tf
  - Changed `data.aws_archive_file` to `data.archive_file`
  - Resolves "Invalid data source" error - archive_file is from the archive provider, not AWS provider
  - The archive provider was already correctly declared in the terraform required_providers block
  
## 3.0.5-rc8

**Status:** Release Candidate

- **lambda-sumo**: Fixed KMS key reference in environment_variables
  - Changed from using `module.kms_key.key_arn` (computed value) to `data.aws_kms_key.lambda_kms.arn` (data source lookup)
  - Resolves "Invalid count argument" error in downstream `lambda_s3_bucket` module
  - Data source looks up key by predictable alias: `alias/${lambda_name}-${TFC_CONFIGURATION_VERSION_GIT_BRANCH}-kms`
  - Allows Terraform to resolve KMS ARN at plan time instead of apply time

## 3.0.5-rc7

- **lambda-sumo**: Added internal KMS key creation to `lambda-sumo` module
  - The module now creates its own KMS key (similar to base `lambda` module)
  - When `kms_key_arn` is not provided by caller, internal key is used
  - Environment variables always include `kms_key_arn` (either passed or internal)
  - Resolves count dependency issues when KMS keys are not pre-created
  - Key name pattern: `${lambda_name}-${TFC_CONFIGURATION_VERSION_GIT_BRANCH}-kms`

## 3.0.5-rc6

- **Fix:** Always enable S3 Server Access Logging for Lambda source buckets
- **Resolves:** GuardDuty alert "Stealth:S3/ServerAccessLoggingDisabled" triggered when `disable_warmer = true`
- Changed `lambda-sumo` module to use `data.aws_s3_bucket.logging_bucket.id` instead of `local.target_bucket` (which was null when warmer disabled)
- Access logging now always targets the org-standard logging bucket (`ccoe-s3-accesslogs-spoke-...`) regardless of warmer configuration

- **Fix:** Conditionally merge `kms_key_arn` in base `lambda` module (modules/lambda/main.tf)
- **Resolves:** "Invalid count argument" error in downstream `lambda_s3_bucket` module when passing computed KMS ARN values
- Base lambda module now uses conditional merge pattern to only include `kms_key_arn` when explicitly provided, matching the `lambda-sumo` variant behavior

## 3.0.5-rc5

- **Fix:** Conditionally pass `kms_key_arn` to downstream `lambda_s3_bucket` module
- **Resolves:** "Invalid count argument" error when passing computed KMS ARN values from module outputs
- The `environment_variables.kms_key_arn` is now only included in the environment_variables map when a KMS key ARN is explicitly provided, preventing Terraform count validation from executing on unknown values
- This fix enables seamless integration with dynamically created KMS keys (e.g., from `pgetech/kms/aws` module)

## 3.0.5-rc4

- **Fix:** Decouple `disable_warmer` from S3 bucket logging count dependency
- **Breaking Change:** Removed `target_bucket` as a module parameter (now computed internally)
- Warmer S3 bucket name is now auto-derived from `lambda_name`, `aws_account`, and `TFC_CONFIGURATION_VERSION_GIT_BRANCH`
- When `disable_warmer = true`, warmer S3 bucket and provisioned concurrency are not created
- Updated documentation to clarify warmer configuration and bucket naming
- Fixes: "Invalid count argument" error when using `disable_warmer = true` with module versions 3.0.5-rc3 and earlier

## 3.0.5-rc3

- upgrade to mrad-sumo 3.0.9-rc2

## 3.0.5-rc2

- add missing aws_account param for latest mrad-sumo

## 3.0.5-rc1

- fix parameters and default values

## 3.0.4

- Version number correction (final stable version)
- Reverted mrad-common tagging changes back to `merge(var.tags, var.optional_tags)`
- Maintained all stability improvements from 3.0.x series

## 3.0.3

- Version bump only
- Intermediate version during tagging system fixes

## 3.0.2

- Remove obsolete `http_source_name` parameter from sumo_logger module call
- Add `account_num` parameter to sumo_logger module call with default value of `null`
- Fix typo: Changed `log_group_name = module.log_group.name` to `module.log_group.cloudwatch_log_group_name`
- Adjust consumer module required params and values

## 3.0.1

- Bump default Node version to latest LTS (22.x)

## 3.0.0

- Add Lambda name length validation and `ignore_name_length_check` override
- Revert to use of `var.tags` for tagging, rather than creating a nested
  `mrad-common` instance. This makes upgrading from 1.x to 3.x easier because
  developers do not have to change their module usage signature.

## 2.1.0

- upgrade aws provider 
- upgrade lambda_s3_bucket

## 2.0.2

- Revert AppConfig permissions and mrd-common integration
- Complete rollback of mrd-common module usage back to direct `var.tags`
- Remove mandatory `account_num` variable requirement
- Revert all tagging system changes introduced in v2.0.1

## 2.0.1

- Add mrd-common module integration for standardized tagging
- Add mandatory `account_num` variable for mrd-common module
- Replace all direct `var.tags` and `merge(var.tags, var.optional_tags)` usage with `module.mrd-common.tags`
- Standardize tagging across all resources (IAM roles, policies, S3 buckets, Lambda functions, log groups, sumo logger)
- Add AppConfig permissions support

## 2.0.0

- Add Lambda Insights support with region-specific layer ARNs
- Add `lambda_insights` variable to enable Lambda Insights for functions
- Rename `lambda_additional_iam_policy_arns` to `lambda_additional_iam_managed_policy_arns`
- Automatic attachment of CloudWatchLambdaInsightsExecutionRolePolicy when Lambda Insights is enabled
- Add comprehensive Lambda Insights layer ARN mapping for all AWS regions (including Gov Cloud and China)
- Enhanced layer management with conditional Lambda Insights layer inclusion
- Updated AWS region description to include Lambda Insights context

## 1.1.0

- Add `lambda_additional_iam_managed_policy_arns` variable to attach additional IAM
  policies to the Lambda function

## 1.0.2

- Add `disable_warmer` option to unblock new QA and Prod deployments

## 1.0.1

- Fix an issue with a stale KMS key being improperly used between S3 and Lambda,
  causing the build stage to fail

## 1.0.0

- Initial release of major version 1. No changes from 0.0.23.
