# aws_profile        = "CloudAdmin_nonprod"
# aws_role    = "CloudAdmin" #TODO: remove before final submit, change to CloudAdmin
# account_num = "891377001063"
aws_region = "us-west-2"


AppID              = "2102"                                           #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment        = "Dev"                                            #Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["sul3@pge.com", "B5DB@pge.com", "UXT5@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["sul3", "UXT5", "B5DB"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"                        #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["SOX"]
Order              = 8115205

optional_tags = {
  pge_team = "ccoe-tf-developers"
}

#Iam_role 
 
restore_iam_aws_service = ["backup.amazonaws.com"]
policy_arns_list        = ["arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores", "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"]
#iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess"]

#Restore Testing 
restore_plan_name_s3        = "RestoreTestingPlanS3"
algorithm                   = "RANDOM_WITHIN_WINDOW"
include_vaults              = ["arn:aws:backup:us-west-2:891377001063:backup-vault:logically-air-gapped-vault-891377001063"]
recovery_point_types        = ["SNAPSHOT"]
recovery_point_types_efs    = ["CONTINUOUS"]
schedule_expression         = "cron(0 12 ? * * *)"
resource_selection_name_s3  = "RestoreTestingS3Assignment"
resource_type_s3            = "S3"
resource_arns               = ["*"]