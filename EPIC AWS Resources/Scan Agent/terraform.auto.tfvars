###############################################################################
# Organization & Account
###############################################################################

aws_account_id = "514712703977"
environment    = "dev"
aws_region     = "us-west-2"

###############################################################################
# Agent Host
###############################################################################

instance_type    = "m5.large"
root_volume_size = 60

# Shared EPIC nonprod VPC + the subnet epic-api's app server runs in (proven
# outbound egress to GitHub/ADO). Override if you stand up a dedicated subnet.
# A dedicated egress-only security group is created by the stack — see main.tf.
vpc_id    = "vpc-8c57a5f4"
subnet_id = "subnet-f9206980"

# TODO: ARNs of the scan secrets the agent reads at runtime (Wiz creds, GitHub PAT).
# Leave empty [] if the agent will not pull secrets from Secrets Manager.
scan_secret_arns = []

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
