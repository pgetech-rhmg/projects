# Changelog

## 2.1.1

- Use user-provided `var.tags` rather than constructing a new `mrad-common`
  instance for its tags
  - MRAD users can provide `var.tags = module.mrad-common.tags` to continue
    using `mrad-common` to provide tags
  - Non-MRAD users can provide a fully-custom `var.tags` value that reflects
    their group's billing

## 2.1.0

- Add `var.ci_type` to allow users to specify ECS mode for the CI stage

## 2.0.1

_Changelog missing: TODO @bciceron_

## 2.0.0

_Changelog missing: TODO @bciceron_

## 1.0.4

- Update `buildspec_wizscan` to include additional account name and number
  values

## 1.0.3

- removal of twistcli and adding in new wiz security scan

## 1.0.2

- Fix issue where IAM policy creation failed due to invalid `sid` (see
  [`sid_string`](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_grammar.html#policies-grammar-notes))

## 1.0.1

- Expand IAM permissions for all CodeBuild steps to allow access to:
  - all AWS Systems Manager Parameter Store values via both `GetParameter` and
    `GetParameters`
  - all ACM certificates via `acm:GetCertificate`

## 1.0.0

- Initial release of major version 1. No changes from 0.0.34.

## 0.0.32

- enables CI on commits and PRs by default. To disable, set
  `var.ci_enable = false`.

## 0.0.31

- Version 0.0.31 is a breaking change. Users are now required to instantiate the
- `github` provider as illustrated in the
- [example](examples/codepipeline_dockerbuild/main.tf).
