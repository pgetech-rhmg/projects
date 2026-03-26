account_num = "056672152820"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

#Tags
AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)

# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal" #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)

CRIS       = "Low" #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify     = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner      = ["abc1", "def2", "ghi3"] #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance = ["None"]
Order              = 8115205                                           #Order tag is required and must be a number between 7 and 9 digits

#sqs
sqs_name            = "users.fifo"
sqs_deadletter_name = "test-deadletter.fifo"

#kms 
kms_name        = "sqs-cmk-fifo"
kms_description = "cmk for encrypting sqs"