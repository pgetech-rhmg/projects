account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

# Tags
AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]
Order              = 8115205                                           #Order tag is required and must be a number between 7 and 9 digits

# Environment
name           = "nonprod"
description    = "A well thought out description of the environment."
application_id = "3jcwgsa"
monitors = [
  {
    alarm_arn      = "arn:aws:cloudwatch:us-west-2:750713712981:alarm:TargetTracking-springapp-aicg-asg-ecs-ec2-AlarmLow-12e28ff6-3e7a-469c-93e6-3f5ca7707f8b"
    alarm_role_arn = "arn:aws:iam::750713712981:role/CloudAdmin"
  },
  {
    alarm_arn      = "arn:aws:cloudwatch:us-west-2:750713712981:alarm:TargetTracking-springapp-aicg-asg-ecs-ec2-AlarmHigh-0a0dc473-be61-4dcb-9975-0ba855424671"
    alarm_role_arn = "arn:aws:iam::750713712981:role/CloudAdmin"
  }
]

