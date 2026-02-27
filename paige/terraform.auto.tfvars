###############################################################################
# Inputs (auto.tfvars)
###############################################################################

principal_orgid				= "o-7vgpdbu22o"
aws_account_id				= "514712703977"
app_name							= "paige"
aws_region						= "us-west-2"
environment						= "dev"

dataclassification      = "Public"
appid                   = 2102
cris                    = "Low"
notify                  = ["rhmg@pge.com", "def2@pge.com", "ghi3@pge.com"]
owner                   = ["rhmg", "def2", "ghi3"]
compliance              = ["None"]
order                   = 70056008

secrets = {
	"GITHUB_BASE_URL"					  = "https://github.com/pgetech",
	"GITHUB_TOKEN"						  = "CHANGE_ME",
	"PORTKEY_BASE_URL"				  = "https://aws-ai-gateway.nonprod.pge.com/v1",
	"PORTKEY_MODEL"						  = "@bedrock-dev/us.anthropic.claude-sonnet-4-5-20250929-v1:0",
	"PORTKEY_MODEL_CLASSIFIER"	= "@bedrock-dev/us.anthropic.claude-3-haiku-20240307-v1:0",
	"PORTKEY_API_KEY"						= "CHANGE_ME"
}

force_s3_destroy		= true
secrets_description	= "Appsettings for Paige.API"
health_check_path 	= "/api/health"

network = {
  vpc_id							= "vpc-8c57a5f4",
  subnet_ids					= ["subnet-f9206980", "subnet-639df628", "subnet-1b085341"],
  main_route_table_id = "rtb-0772a07c"
}

domain_name									= "paige-dev.nonprod.pge.com"
api_domain_name							= "paige-api-dev.nonprod.pge.com"
private_hosted_zone_id			= "Z1PO7XO596QKJW"
public_hosted_zone_id				= "Z184J8PCMR81S"
custom_domain_aliases				= ["paige-dev.nonprod.pge.com"]
