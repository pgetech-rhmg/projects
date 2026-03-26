account_num = "056672152820"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

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

name               = "test-model"
image              = "246618743249.dkr.ecr.us-west-2.amazonaws.com/sagemaker-xgboost:0.90-2-cpu-py3"
mode               = "SingleModel"
model_data_url     = "https://a0ks-test.s3.us-west-2.amazonaws.com/glue-ml/dblp_acm_labels.csv"
container_hostname = "Container"
environment        = { "name" = "aws" }
security_group_ids = ["sg-09b9d2b627613b47b"]
subnet_ids         = ["subnet-086169df2f630eb89"]

#variables for iam role
role_service    = ["sagemaker.amazonaws.com"]
iam_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess", "arn:aws:iam::aws:policy/AmazonSageMakerFeatureStoreAccess"]