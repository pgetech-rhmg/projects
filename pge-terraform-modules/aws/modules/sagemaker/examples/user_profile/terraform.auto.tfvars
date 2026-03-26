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

#Supporting Resource
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"
ssm_parameter_vpc_id     = "/vpc/id"

#IAM
user_profile_role_service = ["sagemaker.amazonaws.com"]

#user_profile
name                                      = "test-user"
domain_id                                 = "d-g4dw003xouip"
notebook_output_option                    = "Allowed"
jupyter_server_app_settings_instance_type = "system"
tensor_board_app_settings_instance_type   = "ml.g4dn.xlarge"
kernel_gateway_app_settings_instance_type = "ml.g4dn.xlarge"
studio_lifecycle_config_app_type          = "JupyterServer"
studio_lifecycle_config_content           = "studio_lifecycle_config_content.sh"