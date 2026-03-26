aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"

AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
optional_tags      = { service = "waf-v2" }
Order              = 8115205 #Order tag is required and must be a number between 7 and 9 digits

# Common variable name for resources
name = "example"

wafv2_ip_set_description        = "Waf ipset testing"
wafv2_ip_set_ip_address_version = "IPV4"
wafv2_ip_set_addresses          = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
