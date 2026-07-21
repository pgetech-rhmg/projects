###############################################################################
# Organization & Account
#
# Same account as the EPIC Scan Agent (514712703977) — the shared self-hosted
# box that runs all PG&E pipeline tooling (SonarQube, Wiz, JFrog). The
# compliance stage runs on that agent and pulls this binary via `aws s3 cp`,
# so the artifact bucket lives in the same account.
###############################################################################

aws_account_id = "514712703977"
environment    = "dev"
aws_region     = "us-west-2"
org_id         = "o-7vgpdbu22o"


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
# Configuration
#
# The Scan Agent's instance role must be able to pull the binary. Org-wide read
# is already granted in the bucket policy; reader_role_arns adds the object-level
# permission (GetObject + kms:Decrypt) on the agent role itself. Get the exact
# ARN from the Scan Agent stack output `iam_role_name`:
#   arn:aws:iam::514712703977:role/<iam_role_name>
###############################################################################

custom_bucket_name = "pge-epic-compliance-reviewer"

# The EPIC scan agent's EC2 instance role — the identity the compliance stage's
# `aws s3 cp` runs as. Grants it GetObject + kms:Decrypt on this bucket.
reader_role_arns = ["arn:aws:iam::514712703977:role/pge-epic-scan-agent-dev-ec2-role"]


###############################################################################
# Artifact Upload
#
# Set these to publish a binary from Terraform. Pin the version in the key.
# Otherwise publish out-of-band from CI:  aws s3 cp <binary> s3://<bucket>/<key>
###############################################################################

# artifact_source = "../../epic-compliance/dist/epic-compliance-v1.0.0-linux-amd64"
# artifact_key    = "compliance/epic-compliance-v1.0.0-linux-amd64"
artifact_source = ""
artifact_key    = ""
