###############################################################################
# Inputs (auto.tfvars)
###############################################################################


###############################################################################
# Organization & Account
###############################################################################

principal_orgid = "o-7vgpdbu22o"
aws_account_id  = "514712703977"
aws_region      = "us-west-2"


###############################################################################
# Application
###############################################################################

app_name    = "epic"
environment = "dev"

health_check_path = "/api/health"
app_executable    = "Epic.Api"


###############################################################################
# Tagging & Compliance
###############################################################################

appid              = 2102
notify             = ["rhmg@pge.com", "def2@pge.com", "ghi3@pge.com"]
owner              = ["rhmg", "def2", "ghi3"]
order              = 70056008
dataclassification = "Internal"
compliance         = ["None"]
cris               = "Low"


###############################################################################
# Networking
###############################################################################

network = {
  vpc_id              = "vpc-8c57a5f4"
  subnet_ids          = ["subnet-f9206980", "subnet-639df628", "subnet-1b085341"]
  main_route_table_id = "rtb-0772a07c"
}

api_domain_name        = "epic-api-dev.nonprod.pge.com"
private_hosted_zone_id = "Z1PO7XO596QKJW"
public_hosted_zone_id  = "Z184J8PCMR81S"


###############################################################################
# Secrets
###############################################################################

secrets_description = "Appsettings for Epic.API"

secrets = {
  # Legacy single-org keys — retained as the fallback source when no
  # GitHubSources entries are configured. Harmless alongside GitHubSources.
  "GITHUB_BASE_URL" = "https://github.com/pgetech"
  "GITHUB_TOKEN"    = "CHANGE_ME"
  "ADO_PAT"         = "CHANGE_ME"

  # Multi-org GitHub sources (org + API host + PAT config key). Keys use the
  # __ separator, normalized to : for .NET config by SecretsLoader. See
  # GitHubSourceRegistry. When any GitHubSources entry exists, the legacy
  # GITHUB_BASE_URL/GITHUB_TOKEN pair above is ignored.
  #
  # Both orgs are on public github.com and share the SAME PAT (GITHUB_TOKEN) —
  # the PAT owner just needs membership in both orgs. To split them later
  # (e.g. a GitHub App per install), point each source at its own TokenKey.
  "GitHubSources__pgetech__ApiBase"  = "https://api.github.com"
  "GitHubSources__pgetech__Org"      = "pgetech"
  "GitHubSources__pgetech__TokenKey" = "GITHUB_TOKEN"

  "GitHubSources__pgedc__ApiBase"  = "https://api.github.com"
  "GitHubSources__pgedc__Org"      = "PGEDigitalCatalyst"
  "GitHubSources__pgedc__TokenKey" = "GITHUB_TOKEN"

  # Default source used when a request/app doesn't name one.
  "GitHubDefaultSource" = "pgetech"
}


###############################################################################
# S3
###############################################################################

force_s3_destroy = true
