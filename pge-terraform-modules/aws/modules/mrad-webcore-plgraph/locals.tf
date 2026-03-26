locals {
  aws_account_id             = data.aws_caller_identity.current.account_id
  envname                    = local.account_id_to_envname[local.aws_account_id]
  subnet_id                  = local.account_id_to_envname[local.aws_account_id]
  suffix                     = var.suffix
  prefix                     = var.prefix
  swapenv                    = local.account_id_to_swapenv[local.aws_account_id]
  baseimage_name             = local.account_id_to_baseimage[local.aws_account_id]
  github_webhook_event       = local.account_id_to_webhook[local.aws_account_id]
  github_filter_json_path    = local.account_id_to_github_jsonpath[local.aws_account_id]
  github_filter_match_equals = local.account_id_to_github_filter[local.aws_account_id]
  sonar_host                 = "https://sonarqube.io.pge.com"
  sonar_cli_download_type    = "PLAINTEXT"
  sonar_cli_download_url     = data.aws_ssm_parameter.sonar_bin.value
  sonar_project_key_prefix   = "webcore"
  sonarqube_secret_name      = "webcore_sonar"

  account_id_to_baseimage = {
    "990878119577" = "pipeline_image",
    "471817339124" = "pipeline_image",
    "712640766496" = "pipeline_image"
  }

  account_id_to_swapenv = {
    "990878119577" = "swapdev",
    "471817339124" = "swapqa",
    "712640766496" = "swapprod"
  }

  account_id_to_envname = {
    "990878119577" = "Dev",
    "471817339124" = "QA",
    "712640766496" = "Prod"
  }

  account_id_to_webhook = {
    "990878119577" = "push",
    "471817339124" = "push",
    "712640766496" = "release"
  }

  account_id_to_github_jsonpath = {
    "990878119577" = "$.ref",
    "471817339124" = "$.ref",
    "712640766496" = "$.release.draft"
  }

  account_id_to_github_filter = {
    "990878119577" = "refs/heads/{Branch}",
    "471817339124" = "refs/heads/{Branch}",
    "712640766496" = "false"
  }

}
