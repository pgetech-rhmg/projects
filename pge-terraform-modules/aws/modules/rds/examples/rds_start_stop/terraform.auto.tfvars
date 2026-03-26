aws_role    = "CloudAdmin"
account_num = "750713712981"
user        = "rb1c"
aws_region  = "us-west-2"

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal" #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BCSI (only one)
CRIS               = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner              = ["abc1", "def2", "ghi3"] #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]                 #Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                  #Order must be a  number between 7 and 9 Digits. This is used to identify the order in which the assets are created.


# /**********************************************IAM role*********************************************/
# Variables for IAM Role

role_service_rds_auto_start_stop    = ["lambda.amazonaws.com"]
iam_policy_arns_rds_auto_start_stop = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]

/********************************************** RDS Auto Start Stop service *********************************************/
## auto start stop variables, enable auto start and auto stop by setting autostart and autostop to "yes"
## when the value is set to "yes", the rds instance will be started and stopped as per the schedule defined in the schedule_rds_auto_start and schedule_rds_auto_stop variables
## the schedule_rds_auto_start and schedule_rds_auto_stop variables are in cron format
## the cron format is "cron(minute hour day month weekday)"
## for example, to start the rds instance every monday at 12:32 PM, set the schedule_rds_auto_start variable to "cron(32 12 ? * MON *)"
## UTC time is used for the cron schedule
## to stop the rds instance every sunday at 9:30 PM, set the schedule_rds_auto_stop variable to "cron(30 21 ? * SUN *)"
## the cron format is explained in detail at https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
## the autostart and autostop variables are optional, by default the values are set to "no"
## the schedule_rds_auto_start and schedule_rds_auto_stop variables are optional, by default the values are set to null
## these variables are used by rds-start-stop module which uses lambda and cloudwatch event to start and stop the rds instance as per the schedule


rds_auto_control_service_name = "ccoe-rds-auto-start-stop"
lambda_runtime                = "python3.11"
lambda_timeout                = 610
lambda_sg_description         = "Security group for python lambda function for Auto start stop the RDS Instance"
# 
schedule_rds_auto_start = "cron(32 12 ? * MON *)" ## UTC time is used for the cron schedule
schedule_rds_auto_stop  = "cron(40 21 ? * * *)"   ## UTC time is used for the cron schedule

##### vpce #####

service_name = "com.amazonaws.us-west-2.rds"

 