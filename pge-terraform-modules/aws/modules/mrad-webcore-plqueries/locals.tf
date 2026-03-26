locals {
  short_name                 = var.short_name
  aws_account_id             = data.aws_caller_identity.current.account_id
  envname                    = local.account_to_environment[local.aws_account_id]
  subnet_id                  = local.subnet_qualifier[local.envname]
  github_webhook_event       = local.account_id_to_webhook_table[local.aws_account_id]
  github_filter_json_path    = local.account_id_to_github_jsonpath_table[local.aws_account_id]
  github_filter_match_equals = local.account_id_to_github_filter_table[local.aws_account_id]
  sonar_host                 = "https://sonarqube.io.pge.com"
  sonar_cli_download_type    = "PLAINTEXT"
  sonar_cli_download_url     = data.aws_ssm_parameter.sonar_bin.value
  sonar_project_key_prefix   = "webcore"
  suffix                     = lower(var.suffix)
  prefix                     = lower(var.prefix)
  codebuild_project_name     = "${local.prefix}-sonarqube-${local.suffix}"

  # lookup tables
  subnet_qualifier = {
    "Dev"  = "Dev-2",
    "QA"   = "QA",
    "Prod" = "Prod"
  }

  account_to_environment = {
    "990878119577" = "Dev",
    "471817339124" = "QA",
    "712640766496" = "Prod"
  }

  account_id_to_webhook_table = {
    "990878119577" = "push",
    "471817339124" = "push",
    "712640766496" = "release"
  }
  account_id_to_github_jsonpath_table = {
    "990878119577" = "$.ref",
    "471817339124" = "$.ref",
    "712640766496" = "$.release.draft"
  }
  account_id_to_github_filter_table = {
    "990878119577" = "refs/heads/{Branch}",
    "471817339124" = "refs/heads/{Branch}",
    "712640766496" = "false"
  }

}
