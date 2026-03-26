resource "aws_codepipeline_webhook" "pipeline_webhook" {
  # only create when not in production
  count           = data.aws_caller_identity.current.account_id == "712640766496" ? 0 : 1
  name            = "${lower(local.prefix)}-graph-${lower(local.suffix)}"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.pipeline.name
  tags            = var.tags

  authentication_configuration {
    secret_token = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["github"]
  }

  filter {
    json_path    = local.github_filter_json_path
    match_equals = local.github_filter_match_equals
  }
}

resource "github_repository_webhook" "repo_webhook" {
  # only create when not in production
  count      = data.aws_caller_identity.current.account_id == "712640766496" ? 0 : 1
  repository = var.repo_name

  configuration {
    url          = aws_codepipeline_webhook.pipeline_webhook[0].url
    content_type = "json"
    insecure_ssl = true
    secret       = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["github"]
  }

  events = [local.github_webhook_event]
}
