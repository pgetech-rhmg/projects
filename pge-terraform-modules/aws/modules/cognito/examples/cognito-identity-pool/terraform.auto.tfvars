aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"


# Tag variables

AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]
Order              = 8115205                                          #Order must be between 7 and 9 digits

## IAM variables
name = "Cognito_DefaultAuthenticatedRole"
## Cognito identity pool variables

identity_pool_name = "cognito-identity-pool-ccoe"

allow_classic_flow           = false
openid_connect_provider_arns = ["arn:aws:iam::750713712981:oidc-provider/itiampingdev.cloud.pge.com"]