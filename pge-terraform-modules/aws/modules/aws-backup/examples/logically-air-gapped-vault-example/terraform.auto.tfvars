# aws_profile        = "CloudAdmin_nonprod"
# aws_role    = "CloudAdmin" #TODO: remove before final submit, change to CloudAdmin
# account_num = "891377001063"
aws_region  = "us-west-2"


AppID              = "2102"                                           #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment        = "Dev"                                            #Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["sul3@pge.com", "B5DB@pge.com", "UXT5@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["sul3", "UXT5", "B5DB"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"                        #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["SOX"]

optional_tags = {
  pge_team = "ccoe-tf-developers"
}

####################################################
#  AWS Backup vault
####################################################

logically_air_gapped_vault_name = "logically-air-gapped-vault-891377001063"
create_vault_policy             = true
vault_iam_policy                = "vault_access_policy.json"
max_retention_days              = 365
min_retention_days              = 7
 