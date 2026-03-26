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

name = "provisioned-endpoint-config-tf-test"
# Provisioned endpoint_configuration supports Either data capture config or async config. Please disable data capture config or async config before apply.
initial_instance_count = 1
instance_type          = "ml.t2.medium"
model_name             = "IAC-TEST"
variant_name           = "variant-1"

async_inference_config = {
  client_config = {
    max_concurrent_invocations_per_instance = 1
  }
  output_config = {
    s3_output_path = "s3://a0ks-test/sftp-test/"
    notification_config = {
      error_topic   = "arn:aws:sns:us-west-2:056672152820:sns_topic-test"
      success_topic = "arn:aws:sns:us-west-2:056672152820:sns_topic_test-11"
    }
  }
}