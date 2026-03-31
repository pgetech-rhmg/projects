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
  "GITHUB_BASE_URL" = "https://github.com/pgetech"
  "GITHUB_TOKEN"    = "CHANGE_ME"
  "ADO_PAT"         = "CHANGE_ME"
}


###############################################################################
# S3
###############################################################################

force_s3_destroy = true
