account_num = "514712703977"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

AppID              = "1001"                           #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment        = "Dev"                            #Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                       #Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]         #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]                         #Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                          #Order must be between 7 and 9 digits
optional_tags      = { "service" = "appstream-2.0" }

#Supporting Resource
ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/privatesubnet3/id"

#IAM
role_service = ["appstream.amazonaws.com"]

#Fleet
name              = "ccoe-appstream2.0-test"
instance_type     = "stream.standard.small"
fleet_type        = "ALWAYS_ON"
desired_instances = 2
image_name        = "ArcPro_3_3_v2"

#Stack
description  = "AppStream 2.0 Stack for domain-joined streaming sessions - Managed by Terraform"
display_name = "ccoe-appstream-stack"

# Image Builder variables - Only uncomment when building custom images
# Image builders are used to install applications and create custom images
# Once the image is built and available, comment these out to save costs
# description                = "Image containing sample applications for Amazon AppStream2.0"
# display_name               = "tf-appstream-test"
# image_name_imagebuilder    = "AppStream-WinServer2016-05-30-2025"
# instance_type_imagebuilder = "stream.standard.large"
# appstream_agent_version    = "LATEST"
# endpoint_type              = "STREAMING"  # For image builder when uncommented

# Domain join configuration - Used by both image builder and fleet, comment out if the fleet or image builder do not require domain join
# domain_join_info = {
#   directory_name                         = "azure.pge.com"
#   organizational_unit_distinguished_name = "OU=AppStream,OU=Applications,OU=Prod,DC=azure,DC=pge,DC=com"
# }

# VPC endpoint configuration - Not used for internet access
# vpc_endpoint_type   = "Interface"
# service_name        = "com.amazonaws.us-west-2.appstream.streaming"
# private_dns_enabled = true


# User variables - Only needed for USERPOOL authentication
# authentication_type = "USERPOOL"
# user_name           = "tftestappstr2@pge.com"
# first_name          = "APPTEST"
# last_name           = "TF"
# enabled_user        = true

# Storage connector configuration - Not needed for domain-joined environment
# Users will access network resources through domain authentication and Group Policy
# domains             = ["azure.pge.com"]
# resource_identifier = "azure-domain-storage"
# enabled             = true
# settings_group      = "PersistSettingsGroup"

# Directory configuration - Only needed for directory_config module
# directory_name                   = "aws2.pgetesttf.com"
# organizational_unit_names        = ["OU=directory,DC=aws1.pgetesttf.com"]
# ssm_parameter_directory_username = "/directory/username"
# ssm_parameter_directory_password = "/directory/password"