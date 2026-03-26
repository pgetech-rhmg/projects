account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"


AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal" #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BCSI (only one)
CRIS               = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner              = ["abc1", "def2", "ghi3"] #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205 #Order must be between 7 and 9 digits"

####################################################
# Creating Maintenance-Window and optional targets
####################################################

scan_maintenance_window_name     = "PGE-ScanPatches-aicg"
scan_maintenance_window_schedule = "cron(0 0/4 * * ? *)" ### run every 4 hours
scan_maintenance_window_duration = 3
scan_maintenance_window_cutoff   = 1

#### maintenance-window-target ####
scan_maintenance_window_target_resource_type = "INSTANCE" ### Valid values are INSTANCE and RESOURCE_GROUP"
scan_maintenance_windows_targets = [{
  key    = "tag:Patch Group"
  values = ["Dev"]
}]

#########################################
# Maintenance-Window Task - Run Command
#########################################

scan_maintenance_window_task_name = "scan-task-run-command"
scan_maintenance_window_task_type = "RUN_COMMAND"
scan_maintenance_window_task_arn  = "AWS-RunPatchBaseline"
scan_task_target_key              = "InstanceIds"
scan_task_run_command_parameters = [
  {
    name   = "Operation"
    values = ["Scan"]
  },
  {
    name   = "RebootOption"
    values = ["NoReboot"]
  }
]

scan_maintenance_window_task_max_concurrency = 2
scan_maintenance_window_task_max_errors      = 1

cloudwatch_output_enabled = true ### set it false, if cloudwatch logging is not required.

#########################################
# Maintenance-Window Task - Automation 
#########################################

automation_maintenance_window_task_name     = "install-task-automation"
automation_maintenance_window_task_type     = "AUTOMATION"
automation_maintenance_window_task_arn      = "CCOE-Patch-Automation"
automation_task_target_key                  = "InstanceIds"
automation_maintenance_window_task_priority = 5

automation_task_invocation_automation_parameters = [
  {
    document_version = "$LATEST"
    auto_parameters = [
      {
        name   = "Operation"
        values = ["Install"]
      },
      {
        name   = "RebootOption"
        values = ["Reboot"]
      }
    ]
  }
]

automation_maintenance_window_task_max_concurrency = 2
automation_maintenance_window_task_max_errors      = 1


#########################################
# Maintenance-Window Task - Lambda 
#########################################

lambda_maintenance_window_task_name     = "task-lambda"
lambda_maintenance_window_task_type     = "LAMBDA"
lambda_maintenance_window_task_arn      = "arn:aws:lambda:us-west-2:750713712981:function:remoteip-test"
lambda_maintenance_window_task_priority = 10

#########################################

### KMS ###
kms_key         = "pge-ssm-kms-aicg"
kms_description = "The description of the key as viewed in AWS console."

### S3 ###
bucket_name          = "ssm-patch-manager-s3-aicg"
output_s3_key_prefix = "scan"


### sns_iam_role ###
sns_iam_name        = "sns_ssm_patch_manager_role"
sns_iam_aws_service = ["ssm.amazonaws.com"]

# sns_notification_enabled = true
snstopic_name         = "sns_ssm_mw_ccoe_example" # Name of the SNS topic
snstopic_display_name = "sns_ssm_mw_ccoe_example" # Display name of the SNS topic

endpoint = ["aicg@pge.com"] #Endpoint to send data to. The contents vary with the protocol. 
protocol = "email"          #Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application. Protocols email, email-json, http and https are also valid but partially supported.


