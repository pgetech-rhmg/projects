AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification               = "Internal"               #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS                             = "Medium"                 #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify                           = ["v3cb@pge.com"]         #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner                            = ["v3cb", "a2vb", "s81m"] #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance                       = ["None"]
name                             = "ccoe-al2023-imagebuilder"
build_version                    = "1.0.0"
test_version                     = "1.0.0"
aws_region                       = "us-west-2"
parent_image_ssm_path            = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
vpc_id                           = "/vpc/id"
account_num                      = "750713712981"
aws_role                         = "CloudAdmin"
delete_on_termination_img_recipe = true
pipeline_status                  = "ENABLED"
platform                         = "Linux"
ami_name                         = "ccoe-al2023-ami"
vpc_cidr                         = "/vpc/cidr"
force_destroy_s3_bucket          = true
log_policy                       = "s3_log_policy.json"
bucket_name                      = "imagebuilder-logs-s3-bucket"
notification_email               = ["v3cb@pge.com"]
launch_permission_user_ids       = ["750713712981"]
receipients                      = ["v3cb@pge.com"]
sender                           = "v3cb@pge.com"
target_accounts_table            = "linux-ami-test-target-accounts"
aws_owned_component_arn          = ["arn:aws:imagebuilder:us-west-2:aws:component/amazon-cloudwatch-agent-linux/1.0.1/1"]
stack_set_name                   = "dev-linux-al2023-stackset"
distribution_regions             = ["us-east-1", "us-west-1"]
ami_parameter_store              = "/ccoe/ami/al2023/ami-id"
Order                            = "8115205"
ami_parameter_store_status       = "/ccoe/ami/al2023/ami-id/status"
recipe_version                   = "0.0.4"
