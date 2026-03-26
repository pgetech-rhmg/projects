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
optional_tags      = { pge_team = "ccoe-tf-developers" }


####################################################
#  AWS Backup vault
####################################################

vault_name                 = "vault-aurora-postgres"
create_vault_notifications = true                                                               # SNS notification - Module default value is false
backup_vault_events        = ["BACKUP_JOB_COMPLETED", "COPY_JOB_SUCCESSFUL", "COPY_JOB_FAILED"] ## The following AWS Backup events are supported: BACKUP_JOB_STARTED, BACKUP_JOB_COMPLETED, COPY_JOB_STARTED, COPY_JOB_SUCCESSFUL, COPY_JOB_FAILED, RESTORE_JOB_STARTED, RESTORE_JOB_COMPLETED, RECOVERY_POINT_MODIFIED

replica_vault_name = "replica-vault-aurora-postgres"
####################################################
#  AWS Backup plan
####################################################

aws_backup_plan_name = "backup-plan-tag-based-postgres"

backup_rule_name              = "backup-plan-rule-tag-based-postgres"
backup_rule_schedule          = "cron(0 6 * * ? *)" ## Runs daily at 6 AM UTC time
backup_rule_start_window      = "60"                ## Defines the period of time in minutes in which a backup needs to start.
backup_rule_completion_window = "180"               ## Defines the period of time during which your backup must complete.
backup_rule_delete_after      = 3                   ## Tell AWS Backup how long to store your backups(in days). AWS Backup automatically deletes your backups at the end of this period to save storage costs for you.

destination_vault_delete_after = 3 ## Tell AWS Backup how long to store your backups(in days). AWS Backup automatically deletes your backups at the end of this period to save storage costs for you.

####################################################
#  AWS Backup resource selection
####################################################

backup_selection_name = "selection-tag-based-postgres"

## IAM Role ##
aws_service = ["backup.amazonaws.com"] ## The IAM role must assume this role.

## Resources will be selected based on these tags
selection_tags = [
  {
    type  = "STRINGEQUALS"
    key   = "application"
    value = "ccoe-postgres"
  },
  {
    type  = "STRINGEQUALS"
    key   = "component"
    value = "rds"
  }
]

####################################################
#  KMS key for backup vault
####################################################

#If an existing KMS key to be used, uncomment the below lines
create_kms_key               = false                                                                         ## Change it to true if a new KMS key to be generated and comment out the variable existing_kms_key_arn
existing_kms_key_arn         = "arn:aws:kms:us-west-2:750713712981:key/mrk-390793a8afd34ea9a41d4ce31b5b9341" ## provide an existing multi-region KMS key ARN
existing_replica_kms_key_arn = "arn:aws:kms:us-east-1:750713712981:key/mrk-390793a8afd34ea9a41d4ce31b5b9341" ## provide the replicated multi-region KMS key ARN of the destination region


####################################################
#  SNS topic and subscription for backup vault
####################################################


snstopic_name         = "sns_aws_backup_example" # Name of the SNS topic
snstopic_display_name = "sns_aws_backup_example" # Display name of the SNS topic

endpoint = ["aicg@pge.com"] #Endpoint to send data to. The contents vary with the protocol. 
protocol = "email"          #Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application. Protocols email, email-json, http and https are also valid but partially supported.

sns_policy_file_name = "sns_access_policy.json" # Custom policy file name