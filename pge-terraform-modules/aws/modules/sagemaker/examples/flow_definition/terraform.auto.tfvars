account_num = "056672152820"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "TF_Developers"

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]                                         #Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                          #Order must be between 7 and 9 digits
optional_tags      = { service = "sagemaker" }

name = "iac-test"

task_availability_lifetime_in_seconds = 1
task_count                            = 1
task_keywords                         = ["test"]
task_time_limit_in_seconds            = 3600
task_title                            = "test-iac-example"
workteam_arn                          = "arn:aws:sagemaker:us-west-2:056672152820:workteam/private-crowd/a0ks-test"

human_loop_activation_config = {
  human_loop_activation_conditions_config = {
    human_loop_activation_conditions = <<EOF
            {
                "Conditions": [
                {
                    "ConditionType": "Sampling",
                    "ConditionParameters": {
                    "RandomSamplingPercentage": 5
                    }
                }
                ]
            }
        EOF
  }
}

human_loop_request_source = {
  aws_managed_human_loop_request_source = "AWS/Textract/AnalyzeDocument/Forms/V1"
}

#human_task_ui
content = "sagemaker-human-task-ui-template.html"

#iam_role
policy_arns = ["arn:aws:iam::aws:policy/AmazonSageMakerFullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonAugmentedAIIntegratedAPIAccess"]
aws_service = ["sagemaker.amazonaws.com", "s3.amazonaws.com"]