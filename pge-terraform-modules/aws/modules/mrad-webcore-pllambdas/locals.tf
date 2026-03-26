locals {
  aws_account_id             = data.aws_caller_identity.current.account_id
  envname                    = local.account_to_environment[local.aws_account_id]
  subnet_id                  = local.subnet_qualifier[local.envname]
  github_webhook_event       = local.account_id_to_webhook[local.aws_account_id]
  github_filter_json_path    = local.account_id_to_github_jsonpath[local.aws_account_id]
  github_filter_match_equals = local.account_id_to_github_filter[local.aws_account_id]
  sonar_host                 = "https://sonarqube.io.pge.com"
  sonar_cli_download_type    = "PLAINTEXT"
  sonar_cli_download_url     = data.aws_ssm_parameter.sonar_bin.value
  sonar_project_key_prefix   = "webcore"
  node_env                   = lower(var.node_env)
  suffix                     = lower(var.suffix)
  prefix                     = lower(var.prefix)
  short_name                 = lower(var.short_name)
  pipeline_name              = "${local.prefix}-lambda-${local.short_name}-${local.suffix}"

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

  repo_data = {
    "Engage-PTT-Second-Pass-Update" = {
      "org"          = "PGEDigitalCatalyst"
      "node_version" = "22"
      "short_name"   = "pttup"
    }
    "Engage-Workorder-AtRisk-Sync" = {
      "org"          = "PGEDigitalCatalyst"
      "node_version" = "22"
      "short_name"   = "atrisk"
    }
    "Engage-Workorder-Status-GIS-Sync" = {
      "org"          = "PGEDigitalCatalyst"
      "node_version" = "22"
      "short_name"   = "gissync"
    }
    "Engage-WSG-Seed" = {
      "org"          = "PGEDigitalCatalyst"
      "node_version" = "22"
      "short_name"   = "gisseed"
    }
    "Engage-DB-Scheduler" = {
      "org"          = "PGEDigitalCatalyst"
      "node_version" = "22"
      "short_name"   = "dbsched"
    }
    "Engage-TFC-Runner" = {
      "org"          = "PGEDigitalCatalyst"
      "node_version" = "22"
      "short_name"   = "tfcrun"
    }
    "Engage-NLB-Manager" = {
      "org"          = "PGEDigitalCatalyst"
      "node_version" = "22"
      "short_name"   = "nlbman"
    }
    "Engage-Auto-Closeout-Workorder-lambda" = {
      "org"          = "PGEDigitalCatalyst"
      "node_version" = "22"
      "short_name"   = "closeout-workorder"
    }
    "Engage-Neptune-Scale" = {
      "org"          = "PGEDigitalCatalyst"
      "node_version" = "22"
      "short_name"   = "scale"
    }
  }

}