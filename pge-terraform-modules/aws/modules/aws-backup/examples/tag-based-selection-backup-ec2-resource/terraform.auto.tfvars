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

vault_name                 = "vault-webapp" ## Also update the target_vault_name field of aws_backup_plan_rule
create_vault_notifications = true           ## Module default value is false

backup_vault_events = ["BACKUP_JOB_COMPLETED"] ## The following AWS Backup events are supported: BACKUP_JOB_STARTED, BACKUP_JOB_COMPLETED, COPY_JOB_STARTED, COPY_JOB_SUCCESSFUL, COPY_JOB_FAILED, RESTORE_JOB_STARTED, RESTORE_JOB_COMPLETED, RECOVERY_POINT_MODIFIED

####################################################
#  AWS Backup plan
####################################################

aws_backup_plan_name = "backup-plan-webapp-tag-based"

aws_backup_plan_rule = [
  {
    rule_name         = "backup-plan-rule-tag-based"
    target_vault_name = "vault-webapp"       ## Should match with vault_name
    schedule          = "cron(0 12 * * ? *)" ## This will run daily at 12 PM UTC time
    start_window      = "60"                 ## Defines the period of time in minutes in which a backup needs to start.
    completion_window = "120"                ## Defines the period of time during which your backup must complete.
    lifecycle = {
      delete_after = 5 ## Tell AWS Backup how long to store your backups(in days). AWS Backup automatically deletes your backups at the end of this period to save storage costs for you.
    }
}]

####################################################
#  AWS Backup resource selection
####################################################

backup_selection_name = "backup-selection-tag-based"

## IAM Role ##
aws_service = ["backup.amazonaws.com"] ## The IAM role must assume this role.

## Resources will be selected based on these tags
selection_tags = [
  {
    type  = "STRINGEQUALS"
    key   = "application"
    value = "ccoe-web-app"
  }
]

####################################################
#  KMS key for backup vault
####################################################
kms_key         = "aws-backup-webapp-kms"
kms_description = "The description of the key as viewed in AWS console."
custom_kms_file = "kms_user_policy.json"

####################################################
#  EBS volume and EC2 instance
####################################################

#parameter store names
vpc_id_name     = "/vpc/id"
subnet_id1_name = "/vpc/2/privatesubnet1/id"
golden_ami_name = "/ami/linux/golden"

## Assigning the tags to EC2 for auto backup. It should match with the selection_tags
aws_backup_tags = { application = "ccoe-web-app" }
#Ebs variables
ebs_availability_zone = "us-west-2a"
ebs_size              = 8
ebs_type              = "gp2"
ebs_device_name       = "/dev/sdh"

#Ec2 variables
ec2_name          = "ec2test-aws-backup-test-aicg"
ec2_instance_type = "t2.micro"
ec2_az            = "us-west-2a"

#Security group variables
sg_name        = "ebs-sg-aws-backup-test-aicg"
sg_description = "Security group for example usage with EBS"


cidr_ingress_rules = [{
  from             = 5701,
  to               = 5703,
  protocol         = "tcp",
  cidr_blocks      = ["10.90.195.128/25"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE Ingress rules"
}]
cidr_egress_rules = [{
  from             = 0,
  to               = 65535,
  protocol         = "tcp",
  cidr_blocks      = ["10.90.108.0/23"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
}]

####################################################
#  SNS topic and subscription for backup vault
####################################################


snstopic_name         = "sns-aws-backup-tag-based" # Name of the SNS topic
snstopic_display_name = "sns-aws-backup-tag-based" # Display name of the SNS topic

endpoint = ["aicg@pge.com"] #Endpoint to send data to. The contents vary with the protocol. 
protocol = "email"          #Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application. Protocols email, email-json, http and https are also valid but partially supported.

sns_policy_file_name = "sns_access_policy.json" # Custom policy file name