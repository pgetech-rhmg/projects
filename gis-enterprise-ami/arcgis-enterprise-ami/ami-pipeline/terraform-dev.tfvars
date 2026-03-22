# main tags
app_id              = "3605"                   #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
environment         = "Dev"                    #Dev, Test, QA, Prod (only one)
data_classification = "Internal"               #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
cris                = "Medium"                 #"Cyber Risk Impact Score High, Medium, Low (only one)"
notify              = ["grn0@pge.com"]         #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
owner               = ["grn0", "KDMd", "G1CR"] #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
compliance          = ["None"]
name                = "imagebuilder-rhel-arcgis-portal" #"Name of the project which will be used as a prefix for every resource."
order               = "8221088"                         #"A numeric value that defines the order of importance for this resource relative to other resources you may have."

optional_tags = {
  AppName   = "Enterprise" #AppName in AMPS
  DRTier    = "Tier 1"     #DRTier value in AMPS d d
  MCP       = "NoMCP"      #MCP Value in AMPS
  org       = "Information Technology"
  CreatedBy = "b5kn@pge.com" ### LanID of the person who created this
}

# AWS Configuration
aws_region  = "us-west-2"
account_num = "587401437202"
aws_role    = "CloudAdmin"

# new variables

source_bucket        = "arcgis-installation-files"
esri_assets_location = "s3://elevate-installer/esri/esri-aes-pge-sftwr/"
base_ami_name_filter = "amzn2-ami-hvm-*-x86_64-gp2"
instance_types       = ["t3.medium"]

# ArcGIS component versions
# webadapter_version = "11.2"
# portal_version      = "11.2"
# datastore_version   = "11.2"
# server_version      = "11.2"
arcgis_version = "11.5"

# Account IDs to share AMIs with
share_account_ids = [
  "387224042170",
  "587401437202"
]

# Pipeline configuration
tfc_workspace_path      = "pgetech/dev-entgis-arcgis-enterprise-sandbox"
tfc_api_token_secret_id = "Terraform/api-key"

# Test mode - set to true to skip image builder and use existing AMIs
test_mode = true

# TFC dry run mode (set to false when TFC integration is ready)
tfc_dry_run = false

source_ami_id = "ami-09e66bea60a8542d9"

test_instance_type = "t3.xlarge"