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
instance_type     = "t3.medium"


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

  # ADO REST auth: Entra ID service principal (client-credentials flow) — replaces
  # ADO_PAT. AdoService mints/caches bearer tokens for the Azure DevOps resource
  # via ClientSecretCredential (see Program.cs / AdoAuthHandler). Real values are
  # hand-set in Secrets Manager post-create; the module uses ignore_changes = all,
  # so applies never overwrite them — these placeholders only seed a from-scratch
  # recreate. ADO_PAT is retained (unused by code) for first-deploy rollback safety.
  "ADO_PAT"           = "CHANGE_ME"
  "ADO_TENANT_ID"     = "CHANGE_ME"
  "ADO_CLIENT_ID"     = "CHANGE_ME"
  "ADO_CLIENT_SECRET" = "CHANGE_ME"

  # GitHub App auth (bot identity, per-org install, short-lived installation
  # tokens). Shared across all App sources: GitHubService mints an RS256 app JWT
  # from these and exchanges it for a ~1h installation token per InstallationId
  # (see GitHubAppTokenProvider). Real values hand-set in Secrets Manager
  # (ignore_changes = all). PRIVATE_KEY is the PEM (newlines as \n or literal).
  "GITHUB_APP_ID"          = "CHANGE_ME"
  "GITHUB_APP_PRIVATE_KEY" = "CHANGE_ME"

  # Multi-org GitHub sources. Keys use the __ separator, normalized to : for
  # .NET config by SecretsLoader. See GitHubSourceRegistry. When any GitHubSources
  # entry exists, the legacy GITHUB_BASE_URL/GITHUB_TOKEN pair above is ignored.
  #
  # Per-source auth: a source with an InstallationId authenticates via the GitHub
  # App (above); a source with only a TokenKey uses that PAT. Both orgs are now on
  # the App (each has an InstallationId), so GITHUB_TOKEN is an unused fallback.
  "GitHubSources__pgetech__ApiBase"        = "https://api.github.com"
  "GitHubSources__pgetech__Org"            = "pgetech"
  "GitHubSources__pgetech__InstallationId" = "158059996"

  "GitHubSources__pgedc__ApiBase"        = "https://api.github.com"
  "GitHubSources__pgedc__Org"            = "PGEDigitalCatalyst"
  "GitHubSources__pgedc__InstallationId" = "158086222"

  # Default source used when a request/app doesn't name one.
  "GitHubDefaultSource" = "pgetech"
}


###############################################################################
# S3
###############################################################################

force_s3_destroy = true
