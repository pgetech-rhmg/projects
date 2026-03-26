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
aws_region  = "us-west-2"
account_num = "801458782278"
aws_role    = "LoggingAdmin"

athena_workgroup_name = "dev-wg"
output_location       = "s3://athena-results-dev-testing/queries/"

glue_database_name = "dev_db"
glue_table_name    = "users"

data_bucket = "source-data-bucket-testing"
data_prefix = "users/"

columns = [
  { name = "id", type = "int" },
  { name = "name", type = "string" }
]
