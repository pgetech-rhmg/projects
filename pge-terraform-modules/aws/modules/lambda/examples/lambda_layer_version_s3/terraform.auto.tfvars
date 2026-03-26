account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

#Tags
AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205 #Order must be between 7 and 9 digits"

#Lambda_layer_version
layer_version_layer_name               = "simple_layer"
layer_version_compatible_architectures = "x86_64"
layer_version_description              = "Description of what your Lambda Layer does"
layer_version_compatible_runtimes      = ["python3.9", "nodejs14.x"]

layer_version_permission_action       = "lambda:GetLayerVersion"
layer_version_permission_statement_id = "dev-account"
layer_version_permission_principal    = "*"

#aws_s3_bucket
s3_bucket_name = "lambdabucketexample"


#aws_s3_bucket_object
bucket_object_key    = "deployment_artifact.zip"
bucket_object_source = "lambda_function.zip"

#Kms
kms_name        = "lambda-layer-cmk-key"
kms_description = "CMK for encrypting lambda layer"

