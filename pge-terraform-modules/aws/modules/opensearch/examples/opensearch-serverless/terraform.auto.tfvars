##### General Configuration #####
account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "TF_Developers"
app_prefix  = "myapp" # Change to your application prefix (3-10 chars)

##### PGE Required Tags #####
AppID       = "APP-1001" # Identify the application this asset belongs to by its AMPS APP ID. Format = APP-####
Environment = "Dev"      # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["mzrk@pge.com", "r0k6@pge.com", "s7aw@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["MZRK", "R0K6", "S7AW"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Lead
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                          # Order must be between 7 and 9 digits

##### Optional Tags #####
optional_tags = {}

##### OpenSearch Serverless Configuration #####
collection_type         = "VECTORSEARCH" # SEARCH, TIMESERIES, or VECTORSEARCH
enable_standby_replicas = true           # High availability

##### Network Configuration #####

# Option 1: Public Access (Not recommended for production)
allow_public_access = true
create_vpce         = false

# Option 2: VPC Private Access with SSM Parameters (Recommended for production - PGE Standard)
# Uncomment and configure SSM parameter names:
# allow_public_access            = false
# create_vpce                    = true
# use_ssm_for_network            = true
# vpc_id_ssm_parameter           = "/network/vpc/id"
# subnet_ids_ssm_parameter       = "/network/subnets/private"
# security_group_ids_ssm_parameter = "/network/security-groups/opensearch"

# Option 3: VPC Private Access with Direct Values (Alternative to SSM)
# Uncomment and configure the following for VPC access:
# allow_public_access = false
# create_vpce         = true
# use_ssm_for_network = false
# vpc_id              = "vpc-0123456789abcdef0"
# subnet_ids = [
#   "subnet-0123456789abcdef0",
#   "subnet-0123456789abcdef1",
#   "subnet-0123456789abcdef2"
# ]
# security_group_ids = ["sg-0123456789abcdef0"]

# Option 4: Use Existing VPC Endpoint
# Uncomment if you have an existing VPCE:
# allow_public_access = false
# create_vpce         = false
# vpce_ids            = ["vpce-0123456789abcdef0"]

##### Access Control #####

# IAM principals that can access the collection
# Leave empty to default to current user/role (for testing)
data_access_principals = []

# Example: Grant access to specific roles
# data_access_principals = [
#   "arn:aws:iam::123456789012:role/BedrockKnowledgeBaseRole",
#   "arn:aws:iam::123456789012:role/ApplicationRole"
# ]

# Collection-level permissions (leave as default unless you have specific needs)
data_access_permissions = [
  "aoss:CreateCollectionItems",
  "aoss:DeleteCollectionItems",
  "aoss:UpdateCollectionItems",
  "aoss:DescribeCollectionItems"
]

# Index-level permissions (leave as default unless you have specific needs)
index_permissions = [
  "aoss:CreateIndex",
  "aoss:DeleteIndex",
  "aoss:UpdateIndex",
  "aoss:DescribeIndex",
  "aoss:ReadDocument",
  "aoss:WriteDocument"
]
