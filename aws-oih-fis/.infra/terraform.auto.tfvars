# AWS Account
account_num = "302263046280"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

# PG&E Required Tags (values from original CFN defaults)
AppID              = 3554
Environment        = "Dev"
DataClassification = "Internal"
CRIS               = "Low"
Notify             = ["bdg3@pge.com", "uvw2@pge.com", "xyz3@pge.com"]
Owner              = ["bdg3", "uvw2", "xyz3"]
Compliance         = ["None"]
Order              = 8115205

# FIS Configuration
s3_bucket_name = "oih-dev-fis-logs"
primary_az     = "us-west-2b"
secondary_az   = "us-west-2a"
tertiary_az    = "us-west-2c"

# Test Harness
vpc_id           = "vpc-REPLACE_ME"
test_subnet_id   = "subnet-REPLACE_ME"
test_subnet_cidr = "100.64.0.0/24"
