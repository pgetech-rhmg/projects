account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"


AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal" #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner              = ["abc1", "def2", "ghi3"] #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205   #Order tag is required and must be a number between 7 and 9 digits

####################################################
#  AWS Backup vault
####################################################

vault_name = "vault-DB-apps" ## Also update the target_vault_name field of aws_backup_plan_rule

####################################################
#  AWS Backup plan
####################################################

aws_backup_plan_name = "backup-plan-condition-based"

aws_backup_plan_rule = [
  {
    rule_name         = "backup-plan-rule-condition-based"
    target_vault_name = "vault-DB-apps"      ## Should match with vault_name
    schedule          = "cron(0 12 * * ? *)" ## Runs daily at 12 PM UTC time
    lifecycle = {
      delete_after = 2 ## Tell AWS Backup how long to store your backups(in days). AWS Backup automatically deletes your backups at the end of this period to save storage costs for you.
    }
}]

####################################################
#  AWS Backup resource selection
####################################################

backup_selection_name = "backup-selection-condition-based"

## IAM Role ##
aws_service = ["backup.amazonaws.com"] ## The IAM role must assume this role.


####################################################
#  KMS key for backup vault
####################################################

#If an existing KMS key to be used, uncomment the below lines
#create_kms_key       = false  ## Change it to true if a new KMS key to be generated and comment out the variable existing_kms_key_arn
#existing_kms_key_arn = ""     ## provide the existing KMS key ARN
