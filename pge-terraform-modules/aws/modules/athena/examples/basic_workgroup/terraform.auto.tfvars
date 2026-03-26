############################
# TAGS (PGE STANDARD)
############################
AppID              = "2102"
Environment        = "Dev"
DataClassification = "Internal"
CRIS               = "Low"
Notify             = ["atcv@pge.com"]
Owner              = ["atcv", "s3kv", "a2vb"]
Compliance         = ["None"]
Order              = 8115205

optional_tags = {}
############################
# CORE
############################
aws_region            = "us-west-2"
account_num           = "801458782278"
aws_role              = "LoggingAdmin"
athena_workgroup_name = "dev-wg-basic"
results_bucket_name   = "athena-results-dev-ninja"