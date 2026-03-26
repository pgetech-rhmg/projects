# Changelog

**IMPORTANT NOTICE:** Do not use v3.x releases, they are only to be used once we start our kinesis/firehose migration. The current stable version line is 2.x.

## 2.5.0-rc2

### Fixed

- Changed default `subnet_qualifier` for `Prod` from `"Prod"` to `"Prod-2"` and `QA` from `"QA"` to `"QA-2"` to route ECS Fargate tasks into the larger subnets (`MRAD-Prod-2-PrivateSubnet*`, `MRAD-QA-2-PrivateSubnet*`) and away from the nearly-exhausted smaller subnets — resolves AMMRAD-7416

## 2.5.0-rc1

### Added

- Added `secrets` variable to inject values from AWS Secrets Manager as container environment variables at task launch time
- Execution role automatically granted `secretsmanager:GetSecretValue` (scoped to provided ARNs) and `kms:Decrypt` when secrets are configured
- Supports both whole-secret injection and single JSON key extraction via `:JSON_KEY::` ARN suffix

### Fixed

- Removed unused `http` and `random` required_providers declarations
- Fixed `//` comment syntax to use `#` throughout `main.tf`
- Added missing `description` to `security_group_id`, `ecs_task_definition_family_map`, `ecs_cluster_arn`, `ecr_repo_urls` outputs
- Added missing `outputs.tf` to example module
- Added missing `description` and `type` to example variables; added tflint-ignore for `TFC_CONFIGURATION_VERSION_GIT_BRANCH` naming convention

## 2.4.5

### Fixed

- Fixed target group name exceeding 32-character AWS limit
- Adjusted naming scheme to reserve 6 characters for port suffix (dash + up to 5 digits)
- Target group names now use full 32-character limit for maximum name length

## 2.4.4

### Fixed

- Replaced random target group suffix with port number to fix `for_each` error during port changes
- Target group names now use the port directly instead of `random_string` resource, making the name known at plan time
- Resolves "for_each keys cannot be determined until apply" error when changing application port
- Port changes now work in a single `terraform apply` without requiring `-target` flags

## 2.4.3

### Changed

- Changed default value of `availability_zone_rebalancing` from `DISABLED` to `ENABLED`

## 2.4.2

### Fixed

- Added `lifecycle { create_before_destroy = true }` to target groups to prevent
  deletion errors during port changes
- Target groups now use 2-character random suffix keyed to port number to allow
  safe resource replacement
- Resolves issue where changing application port would fail due to target group
  being in use by listener

## 3.0.0-rc6

- Changed default `subnet_qualifier` for `Prod` from `"Prod"` to `"Prod-2"` and `QA` from `"QA"` to `"QA-2"` — resolves AMMRAD-7416

## 3.0.0-rc5

- upgrade to mrad-sumo 3.0.9-rc2

## 3.0.0-rc4

- use pin version for mrad-sumo

## 3.0.0-rc3

- incremental upgrade for mrad-sumo v3
- make availability_zone_rebalancing ENABLED by default

## 3.0.0-rc2

- incremental upgrade for mrad-sumo v2

## 3.0.0-rc1

- incremental upgrade for mrad-sumo v1

## 2.4.1

- Fixed release 2.4.0 to not include unfinished release candidate changes

## 2.4.0

### Added
- Added `force_lb` variable to override branch restrictions for Route53 DNS record creation

## 2.3.0.rc4

- fix mrad-sumo params

## 2.3.0.rc3

- fix sumologic provider

## 2.3.0.rc2

- use mrad-sumo 3.0.8

## 2.3.0.rc1

- use mrad-sumo 3.x

## 2.2.0

- publish 2.2.0 module from rc-version

## 2.1.0-rc7

- upgrade to ecs_service v0.1.4 with aws provider 5.0

## 2.1.0-rc6

- adjust validated_desired_count value to autoscaling_min_capacity when autoscaling enabled - ignore desired_count in that case

## 2.1.0-rc5

- Added `availability_zone_rebalancing` variable to control automatic task redistribution across AZs

## 2.1.0-rc4

- Fixed autoscaling target resource_id to use local cluster_name instead of non-existent ecs_cluster_name attribute

## 2.1.0-rc3

- Revert mrad-sumo changes from [#1871](https://github.com/pgetech/pge-terraform-modules/pull/1871) to fix issues with duplicate resources in mrad-sumo submodule

## 3.0.0 (REVERTED)

**Status:** This version was rolled back to 2.1.0-rc3
- feat: adjust mrad-ecs to mrad-sumo v3

## 2.1.0-rc2

- Fixed invalid cross-variable reference in `autoscaling_max_capacity` validation

## 2.1.0-rc1

### Added
- **Autoscaling Support**: Added optional CPU-based autoscaling for ECS services
  - New variables: `enable_autoscaling`, `autoscaling_min_capacity`, `autoscaling_max_capacity`, `autoscaling_target_cpu`, `autoscaling_scale_in_cooldown`, `autoscaling_scale_out_cooldown`
  - New outputs: `autoscaling_target_ids`, `autoscaling_policy_arns`, `autoscaling_enabled`
  - Backward compatible: autoscaling is disabled by default
  - Sensible defaults: 1-10 task range, 70% CPU target, 1-minute cooldowns

### Changed
- ECS service now uses validated desired count that respects autoscaling bounds when autoscaling is enabled

## 1.0.0

- Initial release of major version 1. No changes from 0.0.22.
