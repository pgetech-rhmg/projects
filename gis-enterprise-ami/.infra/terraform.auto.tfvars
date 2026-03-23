###############################################################################
# Inputs (auto.tfvars)
###############################################################################


###############################################################################
# Organization & Account
###############################################################################

principal_orgid = "o-7vgpdbu22o"
aws_account_id  = "587401437202"
aws_region      = "us-west-2"


###############################################################################
# Application
###############################################################################

app_name       = "gis-enterprise-ami"
environment    = "dev"
arcgis_version = "11.5"


###############################################################################
# Tagging & Compliance
###############################################################################

appid              = 2102
notify             = ["rhmg@pge.com"]
owner              = ["rhmg"]
order              = 70056008
dataclassification = "Internal"
compliance         = ["None"]
cris               = "Medium"


###############################################################################
# Image Builder
###############################################################################

components = ["webadapter", "portal", "datastore", "server"]

# RHEL golden AMI — update this when a new golden image is published
source_ami_id = ""

instance_types = ["t3.medium"]

# Accounts to share built AMIs with (cross-account)
share_account_ids = []

# S3 bucket with ESRI installation files
esri_assets_bucket = ""

# Override default 30GB for portal (needs more disk)
ebs_volume_sizes = {
  portal = 60
}
