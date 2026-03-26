account_num        = "056672152820"
aws_region         = "us-west-2"
aws_role           = "CloudAdmin"
kms_role           = "TF_Developers"
template_file_name = "kms_user_policy.json"

#Tags
AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205                                           #Order tag is required and must be a number between 7 and 9 digits
optional_tags = { service = "neptune" }


#common variable for name for all resources
name = "example"

#vaiable values for cluster
skip_final_snapshot = "true"
engine_version      = "1.1.0.0"

#cluster instance variables

instance_class = "db.t3.medium"

#cluster_endpoint argument values
neptune_cluster_endpoint_type = "READER"

#variable values for cluster parameter 
neptune_streams_value      = "0"
neptune_lookup_cache_value = "0"
neptune_result_cache_value = "0"
neptune_ml_iam_role_value  = "arn:aws:iam::056672152820:role/service-role/AWSNeptuneNotebookRole-test-neptune"
neptune_ml_endpoint_value  = "vpce-0df3dd90ed9a550f2"

#instance parameter variables name
neptune_dfe_query_engine_value = "viaQueryHint"
neptune_query_timeout_value    = 180000


#subnet group variables - parameter store names

ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"