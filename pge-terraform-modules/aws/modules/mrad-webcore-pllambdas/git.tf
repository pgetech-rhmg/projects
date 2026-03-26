resource "aws_codepipeline_webhook" "pipeline_webhook" {
  name            = "${local.pipeline_name}-webhook"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.pipeline.name

  authentication_configuration {
    secret_token = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["github"]
  }

  filter {
    json_path    = local.github_filter_json_path
    match_equals = local.github_filter_match_equals
  }

  tags = var.tags
}

resource "github_repository_webhook" "repo_webhook" {
  repository = var.repo_name
  configuration {
    url          = aws_codepipeline_webhook.pipeline_webhook.url
    content_type = "json"
    insecure_ssl = false
    secret       = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["github"]
  }

  events = [local.github_webhook_event]
}

